import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/api_client.dart';

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

class WalletProvider with ChangeNotifier {
  final _api = ApiClient();
  List<Wallet> _wallets = [];
  Map<String, double> _prices = {};
  Map<String, double> _changes24h = {};
  List<Transaction> _transactions = [];
  bool _loading = false;
  double _eurBalance = 2500.0;

  List<Wallet> get wallets => _wallets;
  Map<String, double> get prices => _prices;
  Map<String, double> get changes24h => _changes24h;
  List<Transaction> get transactions => _transactions;
  bool get loading => _loading;
  double get eurBalance => _eurBalance;

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

  void _loadDemoWallets() {
    _wallets = [
      Wallet(id: 'w-eth', blockchain: 'ETH', address: '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD18', balance: 1.2450, symbol: 'ETH', name: 'Ethereum', icon: 'E'),
      Wallet(id: 'w-sol', blockchain: 'SOL', address: '7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU', balance: 15.80, symbol: 'SOL', name: 'Solana', icon: 'S'),
      Wallet(id: 'w-algo', blockchain: 'ALGO', address: 'ALGO7XKXTG2CW87D97TXJSDPBD5JBKHETQA83TZRUJOSGAS', balance: 250.0, symbol: 'ALGO', name: 'Algorand', icon: 'A'),
      Wallet(id: 'w-btc', blockchain: 'BTC', address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh', balance: 0.0520, symbol: 'BTC', name: 'Bitcoin', icon: 'B'),
    ];
    if (_transactions.isEmpty) {
      _transactions = [
        Transaction(id: 't1', type: 'receive', symbol: 'ETH', amount: 0.5, eurValue: 1625, description: 'Reçu de 0x8a2f...3e91', date: DateTime.now().subtract(const Duration(hours: 2))),
        Transaction(id: 't2', type: 'send', symbol: 'SOL', amount: -3.0, eurValue: 435, description: 'Envoyé à 7xKX...gAsU', date: DateTime.now().subtract(const Duration(hours: 8))),
        Transaction(id: 't3', type: 'buy', symbol: 'BTC', amount: 0.012, eurValue: 744, description: 'Achat par carte Visa', date: DateTime.now().subtract(const Duration(days: 1))),
        Transaction(id: 't4', type: 'swap', symbol: 'ETH', amount: -0.1, toSymbol: 'SOL', toAmount: 8.5, description: 'Échange ETH → SOL', date: DateTime.now().subtract(const Duration(days: 1, hours: 6))),
        Transaction(id: 't5', type: 'bank_receive', symbol: 'EUR', amount: 500, eurValue: 500, description: 'Virement reçu - Jean Dupont', date: DateTime.now().subtract(const Duration(days: 2))),
        Transaction(id: 't6', type: 'bank_send', symbol: 'EUR', amount: -150, eurValue: 150, description: 'Virement vers FR76...890', date: DateTime.now().subtract(const Duration(days: 3))),
        Transaction(id: 't7', type: 'receive', symbol: 'ALGO', amount: 100, eurValue: 32, description: 'Reçu de ALGO7X...GAS', date: DateTime.now().subtract(const Duration(days: 4))),
        Transaction(id: 't8', type: 'buy', symbol: 'ETH', amount: 0.25, eurValue: 812.50, description: 'Achat par carte Visa', date: DateTime.now().subtract(const Duration(days: 5))),
        Transaction(id: 't9', type: 'send', symbol: 'BTC', amount: -0.005, eurValue: 310, description: 'Envoyé à bc1q...0wlh', date: DateTime.now().subtract(const Duration(days: 7))),
        Transaction(id: 't10', type: 'bank_receive', symbol: 'EUR', amount: 2000, eurValue: 2000, description: 'Virement reçu - Salaire', date: DateTime.now().subtract(const Duration(days: 10))),
      ];
    }
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

  void bankSend(String name, String iban, double amount) {
    _eurBalance -= amount;
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
      if (_prices.isEmpty) {
        _prices = {'ETH': 3250.0, 'SOL': 145.0, 'ALGO': 0.32, 'BTC': 62000.0};
        _changes24h = {'ETH': 2.1, 'SOL': -1.3, 'ALGO': 0.8, 'BTC': 1.5};
      }
    }
  }

  Future<void> fetch() async {
    _loading = true;
    notifyListeners();
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
      } else {
        if (_wallets.isEmpty) _loadDemoWallets();
      }
    } catch (_) {
      if (_wallets.isEmpty) _loadDemoWallets();
    }
    _loading = false;
    notifyListeners();
  }
}
