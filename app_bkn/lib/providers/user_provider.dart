import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentUser;
  double _solde = 0.0;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get currentUser => _currentUser;
  double get solde => _solde;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await ApiService.getUser(userId);
      if (_currentUser != null) {
        _solde = _currentUser!['solde']?.toDouble() ?? 0.0;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshSolde() async {
    if (ApiService.currentUserId == null) return;
    
    final newSolde = await ApiService.getSolde(ApiService.currentUserId!);
    _solde = newSolde;
    if (_currentUser != null) {
      _currentUser!['solde'] = newSolde;
    }
    notifyListeners();
  }

  Future<bool> updateSolde(double montant, {bool isAddition = true}) async {
    if (isAddition) {
      _solde += montant;
    } else {
      if (_solde < montant) return false;
      _solde -= montant;
    }
    
    if (_currentUser != null) {
      _currentUser!['solde'] = _solde;
    }
    
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _solde = 0.0;
    ApiService.clearSession();
    notifyListeners();
  }

  void setError(String message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}