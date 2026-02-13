import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<dynamic> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransactions(String userId, {int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await ApiService.getHistorique(userId, limit: limit);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> transfer({
    required String expediteurId,
    required String destinataire,
    required double montant,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.transferer(
      expediteurId: expediteurId,
      destinataire: destinataire,
      montant: montant,
    );

    _isLoading = false;
    
    if (result['success']) {
      await loadTransactions(expediteurId);
      notifyListeners();
      return true;
    } else {
      _error = result['data']['error'] ?? 'Erreur inconnue';
      notifyListeners();
      return false;
    }
  }

  Future<bool> vendre({
    required String userId,
    required double montant,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.vendre(
      userId: userId,
      montant: montant,
    );

    _isLoading = false;
    
    if (result['success']) {
      await loadTransactions(userId);
      notifyListeners();
      return true;
    } else {
      _error = result['data']['error'] ?? 'Erreur lors de la vente';
      notifyListeners();
      return false;
    }
  }

  Future<bool> acheter({
    required String userId,
    required double montant,
    required String methode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.acheter(
      userId: userId,
      montant: montant,
      methode: methode,
    );

    _isLoading = false;
    
    if (result['success']) {
      await loadTransactions(userId);
      notifyListeners();
      return true;
    } else {
      _error = result['data']['error'] ?? 'Erreur lors de l\'achat';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}