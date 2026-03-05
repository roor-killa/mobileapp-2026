import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/crypto.dart';

class CryptoProvider extends ChangeNotifier {
  Map<String, double> _prices = {};
  Map<String, double> _balances = {};
  List<CryptoTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  Map<String, double> get prices => _prices;
  Map<String, double> get balances => _balances;
  List<CryptoTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger les prix des cryptos
  Future<void> loadPrices() async {
    try {
      final response = await ApiService.getCryptoPrices();
      if (response.containsKey('prices')) {
        _prices = Map<String, double>.from(response['prices']);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Charger les soldes crypto de l'utilisateur
  Future<void> loadBalances(String userId) async {
    try {
      final response = await ApiService.getCryptoBalance(userId);
      if (response.containsKey('balances')) {
        _balances = Map<String, double>.from(response['balances']);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Charger l'historique des transactions crypto
  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.getCryptoHistory(userId);
      if (response.containsKey('transactions')) {
        _transactions = (response['transactions'] as List)
            .map((t) => CryptoTransaction.fromJson(t))
            .toList();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Acheter de la crypto
  Future<Map<String, dynamic>> buyCrypto({
    required String userId,
    required String crypto,
    required double amountBKN,
    String? walletAddress,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.buyCrypto(
        userId: userId,
        crypto: crypto,
        amountBKN: amountBKN,
        walletAddress: walletAddress,
      );

      if (result['success'] == true) {
        await loadBalances(userId);
        await loadHistory(userId);
      } else {
        _error = result['error'] ?? 'Erreur lors de l\'achat';
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Vendre de la crypto
  Future<Map<String, dynamic>> sellCrypto({
    required String userId,
    required String crypto,
    required double amountCrypto,
    String? walletAddress,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.sellCrypto(
        userId: userId,
        crypto: crypto,
        amountCrypto: amountCrypto,
        walletAddress: walletAddress,
      );

      if (result['success'] == true) {
        await loadBalances(userId);
        await loadHistory(userId);
      } else {
        _error = result['error'] ?? 'Erreur lors de la vente';
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Obtenir le solde d'une crypto spécifique
  double getBalance(String crypto) {
    return _balances[crypto] ?? 0.0;
  }

  // Estimer le montant de crypto pour un montant BKN donné
  double estimateCrypto(String crypto, double bknAmount) {
    final price = _prices[crypto] ?? 1.0;
    if (price <= 0) return 0.0;
    return bknAmount / price;
  }

  // Estimer le montant BKN pour un montant crypto donné
  double estimateBKN(String crypto, double cryptoAmount) {
    final price = _prices[crypto] ?? 1.0;
    return cryptoAmount * price;
  }

  // Calculer la valeur totale du portefeuille en BKN
  double get totalPortfolioValueInBKN {
    double total = 0.0;
    _balances.forEach((crypto, amount) {
      total += estimateBKN(crypto, amount);
    });
    return total;
  }

  // Calculer la valeur totale du portefeuille en EUR
  double get totalPortfolioValueInEUR {
    return totalPortfolioValueInBKN; // 1 BKN = 1 EUR
  }

  // Vérifier si l'utilisateur a une crypto spécifique
  bool hasCrypto(String crypto) {
    return (_balances[crypto] ?? 0.0) > 0;
  }

  // Obtenir la liste des cryptos possédées
  List<String> get ownedCryptos {
    return _balances.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList();
  }

  // Rafraîchir toutes les données
  Future<void> refreshAll(String userId) async {
    await Future.wait([
      loadPrices(),
      loadBalances(userId),
      loadHistory(userId),
    ]);
  }

  // Effacer les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Réinitialiser le provider (pour la déconnexion)
  void reset() {
    _prices = {};
    _balances = {};
    _transactions = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}