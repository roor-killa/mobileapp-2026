import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/models/user_model.dart';
import '../core/constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  final _api     = ApiService.instance;
  final _storage = StorageService.instance;

  // ─── Vérifier si l'utilisateur est déjà connecté ─────────────────────────
  Future<bool> checkAuth() async {
    final token = await _storage.getToken();
    if (token == null) return false;
    try {
      final res = await _api.get(ApiConstants.me);
      if (res['success'] == true) {
        _user = UserModel.fromJson(res['user']);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    await _storage.deleteToken();
    return false;
  }

  // ─── Connexion ────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final res = await _api.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });
      if (res['success'] == true) {
        await _storage.saveToken(res['token']);
        _user = UserModel.fromJson(res['user']);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return false;
  }

  // ─── Inscription ──────────────────────────────────────────────────────────
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String pin,
  }) async {
    _setLoading(true);
    try {
      final res = await _api.post(ApiConstants.register, {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'pin': pin,
      });
      if (res['success'] == true) {
        await _storage.saveToken(res['token']);
        _user = UserModel.fromJson(res['user']);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return false;
  }

  // ─── Déconnexion ──────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _api.post(ApiConstants.logout, {});
    } catch (_) {}
    await _storage.deleteToken();
    _user = null;
    notifyListeners();
  }

  // ─── Mise à jour locale du solde (après transfert) ────────────────────────
  void updateBalance(double newBalance) {
    if (_user != null) {
      _user = _user!.copyWith(balance: newBalance);
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
