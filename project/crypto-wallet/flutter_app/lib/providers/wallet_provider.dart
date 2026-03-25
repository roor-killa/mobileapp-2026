import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/virement_response.dart';
import '../services/api_client.dart';
import '../utils/nodex_synthetic_banking.dart';

class Wallet {
  final String id;
  final String blockchain;
  final String address;
  double balance;
  final String symbol;
  final String name;
  final String icon;
  Wallet({required this.id, required this.blockchain, required this.address, required this.balance, required this.symbol, required this.name, required this.icon});
}

class Transaction {
  final String id;
  final String type; // send, receive, swap, buy, bank_send, bank_receive
  final String symbol;
  final double amount;
  final double? eurValue;
  final String description;
  final String status; // confirmed, pending, failed
  final DateTime date;
  final String? toSymbol;
  final double? toAmount;
  Transaction({required this.id, required this.type, required this.symbol, required this.amount, this.eurValue, required this.description, this.status = 'confirmed', required this.date, this.toSymbol, this.toAmount});
}

const _chainMeta = {
  'ETH': {'name': 'Ethereum', 'icon': 'E', 'cgId': 'ethereum'},
  'SOL': {'name': 'Solana', 'icon': 'S', 'cgId': 'solana'},
  'ALGO': {'name': 'Algorand', 'icon': 'A', 'cgId': 'algorand'},
  'BTC': {'name': 'Bitcoin', 'icon': 'B', 'cgId': 'bitcoin'},
};

/// Solde de départ en euros (affiché au premier chargement)
const double _soldeDepartEur = 2000.0;

class WalletProvider with ChangeNotifier {
  final _api = ApiClient();
  List<Wallet> _wallets = [];
  Map<String, double> _prices = {};
  Map<String, double> _changes24h = {};
  List<Transaction> _transactions = [];
  bool _loading = false;
  double _eurBalance = _soldeDepartEur;
  /// Dernier userId chargé - pour isoler le solde EUR par utilisateur
  String? _lastUserId;

  static const _prefsKeyPrefix = 'nodex_eur_balance_';

  List<Wallet> get wallets => _wallets;
  Map<String, double> get prices => _prices;
  Map<String, double> get changes24h => _changes24h;
  List<Transaction> get transactions => _transactions;
  bool get loading => _loading;
  double get eurBalance => _eurBalance;

  String? _myIban;
  String? _myPseudonym;
  /// Nom du titulaire (RIB), renvoyé par l’API à partir du compte en base.
  String? _myHolderName;
  List<Map<String, dynamic>> _virementsHistory = [];
  String? get myIban => _myIban;
  String? get myPseudonym => _myPseudonym;
  String? get myHolderName => _myHolderName;
  List<Map<String, dynamic>> get virementsHistory => _virementsHistory;

  /// Diagnostic : teste la connexion backend et l'auth.
  Future<String> testConnection() async {
    try {
      final r = await http.get(Uri.parse('${ApiConfig.baseUrl}/health')).timeout(const Duration(seconds: 5));
      if (r.statusCode != 200) return 'Backend: erreur ${r.statusCode}';
      final me = await _api.get('/virements/me');
      if (me.statusCode == 200) {
        final d = jsonDecode(me.body) as Map<String, dynamic>;
        return 'OK. Titulaire: ${d['holderName'] ?? d['name'] ?? '?'} | IBAN: ${d['iban'] ?? '?'} | Pseudo: ${d['pseudonym'] ?? '?'}';
      }
      if (me.statusCode == 401) return 'Session expirée. Déconnectez-vous et reconnectez-vous.';
      return 'Auth: ${me.statusCode}';
    } catch (e) {
      return 'Erreur: ${e.toString().length > 100 ? e.toString().substring(0, 100) : e}';
    }
  }

  double get totalBalanceEur {
    double total = _eurBalance;
    for (final w in _wallets) {
      total += w.balance * (_prices[w.symbol] ?? 0);
    }
    return total;
  }

  double get totalCryptoEur {
    double total = 0;
    for (final w in _wallets) {
      total += w.balance * (_prices[w.symbol] ?? 0);
    }
    return total;
  }


  void addTransaction(Transaction tx) {
    _transactions.insert(0, tx);
    notifyListeners();
  }

  void sendCrypto(String walletId, double amount, String toAddress) {
    final w = _wallets.firstWhere((w) => w.id == walletId);
    w.balance -= amount;
    final price = _prices[w.symbol] ?? 0;
    addTransaction(Transaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      type: 'send',
      symbol: w.symbol,
      amount: -amount,
      eurValue: amount * price,
      description: 'Envoyé à ${toAddress.length > 12 ? "${toAddress.substring(0, 6)}...${toAddress.substring(toAddress.length - 4)}" : toAddress}',
      date: DateTime.now(),
    ));
  }

  void buyCrypto(String walletId, double eurAmount) {
    final w = _wallets.firstWhere((w) => w.id == walletId);
    final price = _prices[w.symbol] ?? 1;
    final cryptoAmount = eurAmount / price;
    w.balance += cryptoAmount;
    _eurBalance -= eurAmount * 1.015;
    _saveEurBalance();
    addTransaction(Transaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      type: 'buy',
      symbol: w.symbol,
      amount: cryptoAmount,
      eurValue: eurAmount,
      description: 'Achat par carte Visa',
      date: DateTime.now(),
    ));
  }

  void swapCrypto(int fromIdx, int toIdx, double fromAmount) {
    final from = _wallets[fromIdx];
    final to = _wallets[toIdx];
    final fromPrice = _prices[from.symbol] ?? 1;
    final toPrice = _prices[to.symbol] ?? 1;
    final toAmount = fromAmount * fromPrice / toPrice;
    from.balance -= fromAmount;
    to.balance += toAmount;
    addTransaction(Transaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      type: 'swap',
      symbol: from.symbol,
      amount: -fromAmount,
      toSymbol: to.symbol,
      toAmount: toAmount,
      eurValue: fromAmount * fromPrice,
      description: 'Échange ${from.symbol} → ${to.symbol}',
      date: DateTime.now(),
    ));
  }

  /// Virement local uniquement (vers IBAN externe - simulation).
  void bankSend(String name, String iban, double amount) {
    _eurBalance -= amount;
    _saveEurBalance();
    addTransaction(Transaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      type: 'bank_send',
      symbol: 'EUR',
      amount: -amount,
      eurValue: amount,
      description: 'Virement vers ${name.isNotEmpty ? name : iban}',
      date: DateTime.now(),
    ));
  }

  static bool _isTransientNetworkError(Object e) {
    final s = e.toString();
    return s.contains('SocketException') ||
        s.contains('Connection refused') ||
        s.contains('Failed host lookup') ||
        s.contains('TimeoutException') ||
        s.contains('Network is unreachable');
  }

  /// Virement vers un compte NodEX (via API - IBAN, pseudonyme ou email).
  /// Retourne null si succès, sinon le message d'erreur.
  Future<String?> bankSendToNodEX(String toIdentifier, double amount) async {
    if (amount <= 0) return 'Montant invalide';
    if (amount > _eurBalance) return 'Solde insuffisant';
    if (toIdentifier.trim().isEmpty) return 'Indiquez l\'IBAN ou le pseudonyme du destinataire';

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        if (kDebugMode) debugPrint('[Virement] Envoi vers $toIdentifier: $amount € (tentative ${attempt + 1})');
        final res = await _api.post('/virements/send', {
          'toIdentifier': toIdentifier.trim(),
          'amount': amount,
        });
        if (res.statusCode == 200 || res.statusCode == 201) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final virement = VirementResponse.fromJson(data);
          if (!virement.success || virement.newBalance < 0) return 'Réponse serveur invalide';
          if (kDebugMode) debugPrint('[Virement] Succès - nouveau solde: ${virement.newBalance}');
          _eurBalance = virement.newBalance;
          _saveEurBalance();
          addTransaction(Transaction(
            id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
            type: 'bank_send',
            symbol: 'EUR',
            amount: -amount,
            eurValue: amount,
            description: 'Virement vers $toIdentifier',
            date: DateTime.now(),
          ));
          notifyListeners();
          _refreshVirementsHistory();
          return null;
        }
        if (res.statusCode == 401 && attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 400));
          continue;
        }
        String msg = 'Erreur serveur (${res.statusCode})';
        try {
          final err = jsonDecode(res.body) as Map<String, dynamic>;
          final m = err['message'];
          if (m is String) msg = m;
          else if (m is List && m.isNotEmpty) msg = m.first.toString();
        } catch (_) {}
        if (kDebugMode) debugPrint('[Virement] Erreur ${res.statusCode}: ${res.body}');
        return msg;
      } catch (e) {
        if (kDebugMode) debugPrint('[Virement] Exception: $e');
        if (attempt == 0 && _isTransientNetworkError(e)) {
          await Future<void>.delayed(const Duration(milliseconds: 600));
          continue;
        }
        final s = e.toString();
        if (_isTransientNetworkError(e)) {
          return 'Connexion au serveur NodEX impossible. Vérifiez le réseau et l’adresse dans Réglages → Serveur & assistant.';
        }
        return 'Erreur : ${s.length > 120 ? s.substring(0, 120) : s}';
      }
    }
    return 'Échec du virement après nouvelle tentative.';
  }

  /// Charge le solde EUR depuis SharedPreferences pour un utilisateur.
  Future<double> _loadEurBalanceForUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefsKeyPrefix$userId';
      final val = prefs.getDouble(key);
      return val ?? _soldeDepartEur;
    } catch (_) {
      return _soldeDepartEur;
    }
  }

  /// Sauvegarde le solde EUR pour l'utilisateur courant.
  Future<void> _saveEurBalance() async {
    final uid = _lastUserId;
    if (uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('$_prefsKeyPrefix$uid', _eurBalance);
    } catch (_) {}
  }

  /// Réinitialise le provider (appelé à la déconnexion).
  void resetForLogout() {
    _wallets = [];
    _transactions = [];
    _lastUserId = null;
    _eurBalance = _soldeDepartEur;
    _myIban = null;
    _myPseudonym = null;
    _myHolderName = null;
    _virementsHistory = [];
    notifyListeners();
  }

  Future<void> _fetchTransactions() async {
    _transactions = [];
    for (final w in _wallets) {
      try {
        final res = await _api.get('/wallets/${w.id}/transactions');
        if (res.statusCode == 200) {
          final list = jsonDecode(res.body) as List;
          for (final e in list) {
            final m = e as Map<String, dynamic>;
            final amt = (m['amount'] as num?)?.toDouble() ?? 0.0;
            final type = m['type'] ?? 'send';
            final price = _prices[m['tokenSymbol'] ?? w.symbol] ?? 0.0;
            _transactions.add(Transaction(
              id: m['id']?.toString() ?? '',
              type: type,
              symbol: m['tokenSymbol'] ?? w.symbol,
              amount: type == 'send' ? -amt : amt,
              eurValue: price > 0 ? amt * price : null,
              description: type == 'send' ? 'Envoyé à ${_shortenAddr(m['toAddress'] ?? '')}' : 'Reçu de ${_shortenAddr(m['fromAddress'] ?? '')}',
              status: m['status'] ?? 'confirmed',
              date: m['createdAt'] != null ? DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
            ));
          }
        }
      } catch (_) {}
    }
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  static String _shortenAddr(String addr) {
    if (addr.length <= 12) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  /// 4 portefeuilles locaux (solde 0) quand le backend ne fournit pas la liste.
  void _seedDemoWallets(String userId) {
    final h = userId.hashCode.abs();
    _wallets = _chainMeta.entries.map((e) {
      final symbol = e.key;
      final meta = e.value;
      final addr = symbol == 'BTC' ? 'bc1${(h + symbol.hashCode).toRadixString(16)}demo' : '0x${(h + symbol.hashCode).toRadixString(16).padLeft(8, '0')}';
      return Wallet(
        id: 'demo-$h-$symbol',
        blockchain: meta['name']!,
        address: addr,
        balance: 0,
        symbol: symbol,
        name: meta['name']!,
        icon: meta['icon']!,
      );
    }).toList();
  }

  Future<void> _fetchPricesFromCoinGecko() async {
    try {
      final ids = _chainMeta.values.map((m) => m['cgId']!).join(',');
      final url = 'https://api.coingecko.com/api/v3/simple/price?ids=$ids&vs_currencies=eur&include_24hr_change=true';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _prices = {};
        _changes24h = {};
        for (final entry in _chainMeta.entries) {
          final cgId = entry.value['cgId']!;
          final symbol = entry.key;
          if (data[cgId] != null) {
            _prices[symbol] = (data[cgId]['eur'] as num?)?.toDouble() ?? 0;
            _changes24h[symbol] = (data[cgId]['eur_24h_change'] as num?)?.toDouble() ?? 0;
          }
        }
      }
    } catch (_) {
      // Pas de données fictives - garder vide si l'API échoue
    }
  }

  /// Rafraîchit uniquement l'historique des virements (après envoi réussi).
  Future<void> _refreshVirementsHistory() async {
    try {
      final hRes = await _api.get('/virements/history');
      if (hRes.statusCode == 200) {
        final list = jsonDecode(hRes.body) as List;
        _virementsHistory = list.map((e) => (e as Map<String, dynamic>)).toList();
        _mergeVirementsIntoTransactions();
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Fusionne les virements dans _transactions pour "Dernières transactions" et Historique.
  void _mergeVirementsIntoTransactions() {
    _transactions.removeWhere((t) => t.type == 'bank_send' || t.type == 'bank_receive');
    for (final v in _virementsHistory) {
      final id = v['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      final type = v['type'] as String?;
      final amt = (v['amount'] as num?)?.toDouble() ?? 0.0;
      final dateStr = v['date'] as String?;
      final other = v['otherPseudonym'] as String? ?? '';
      final date = dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now();
      final isReceived = type == 'received';
      _transactions.add(Transaction(
        id: id,
        type: isReceived ? 'bank_receive' : 'bank_send',
        symbol: 'EUR',
        amount: isReceived ? amt : -amt,
        eurValue: amt,
        description: isReceived
            ? (other.isNotEmpty ? 'Reçu de $other' : 'Virement reçu')
            : (other.isNotEmpty ? 'Envoyé à $other' : 'Virement envoyé'),
        status: 'confirmed',
        date: date,
      ));
    }
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  /// Charge les wallets et le solde EUR. Passe [userId] pour isoler le solde par utilisateur.
  Future<void> fetch([String? userId]) async {
    _loading = true;
    notifyListeners();

    // Si l'utilisateur a changé, charger son solde EUR et oublier l’ancien RIB
    if (userId != null && userId != _lastUserId) {
      _lastUserId = userId;
      _myIban = null;
      _myPseudonym = null;
      _myHolderName = null;
      _eurBalance = await _loadEurBalanceForUser(userId);
    }

    await _fetchPricesFromCoinGecko();
    try {
      final wRes = await _api.get('/wallets');
      if (wRes.statusCode == 200) {
        final data = jsonDecode(wRes.body);
        final list = data is Map ? (data['wallets'] ?? data) : data;
        _wallets = (list as List).map((e) {
          final m = e as Map<String, dynamic>;
          final chain = m['symbol'] ?? m['chain'] ?? '';
          final meta = _chainMeta[chain] ?? {'name': chain, 'icon': '?'};
          final b = m['balance'];
          final balance = b is num ? b.toDouble() : (double.tryParse(b?.toString() ?? '0') ?? 0.0);
          return Wallet(id: m['id']?.toString() ?? '', blockchain: m['blockchain'] ?? m['chain'] ?? chain, address: m['address'] ?? '', balance: balance, symbol: chain, name: meta['name']!, icon: meta['icon']!);
        }).toList();
        await _fetchTransactions();
      } else {
        _wallets = [];
        _transactions = [];
      }
    } catch (_) {
      _wallets = [];
      _transactions = [];
    }
    // Portefeuilles de démo si l’API ne répond pas (401, backend arrêté) — pour afficher ETH/BTC/SOL/ALGO
    final uid = userId ?? _lastUserId;
    if (_wallets.isEmpty && uid != null) {
      _seedDemoWallets(uid);
    }
    // Toujours charger virements (me + history) — même si /wallets a échoué (Laravel)
    await _fetchVirementsAndMerge();
    _applySyntheticRibIfMissing(userId ?? _lastUserId);
    _loading = false;
    notifyListeners();
  }

  /// IBAN / pseudo identiques à la base si l’API ne répond pas : le RIB reste utilisable.
  void _applySyntheticRibIfMissing(String? appwriteId) {
    if (appwriteId == null || appwriteId.isEmpty) return;
    final iban = _myIban?.trim() ?? '';
    if (iban.isNotEmpty) return;
    _myIban = nodexSyntheticIban(appwriteId);
    _myPseudonym ??= nodexSyntheticPseudonym(appwriteId);
  }

  /// Charge virements/me, virements/history et fusionne dans _transactions.
  Future<void> _fetchVirementsAndMerge() async {
    try {
      final bRes = await _api.get('/virements/me');
      if (bRes.statusCode == 200) {
        final data = jsonDecode(bRes.body) as Map<String, dynamic>;
        final apiBalance = (data['balanceEur'] as num?)?.toDouble();
        if (apiBalance != null) {
          _eurBalance = apiBalance;
          _saveEurBalance();
        }
        _myIban = data['iban']?.toString();
        _myPseudonym = data['pseudonym']?.toString();
        _myHolderName = data['holderName']?.toString() ?? data['name']?.toString();
      }
    } catch (_) {
      try {
        final bRes = await _api.get('/virements/balance');
        if (bRes.statusCode == 200) {
          final data = jsonDecode(bRes.body) as Map<String, dynamic>;
          final apiBalance = (data['balanceEur'] as num?)?.toDouble();
          if (apiBalance != null) {
            _eurBalance = apiBalance;
            _saveEurBalance();
          }
        }
      } catch (_) {}
    }
    try {
      final hRes = await _api.get('/virements/history');
      if (hRes.statusCode == 200) {
        final list = jsonDecode(hRes.body) as List;
        _virementsHistory = list.map((e) => (e as Map<String, dynamic>)).toList();
        _mergeVirementsIntoTransactions();
      }
    } catch (_) {}
  }
}
