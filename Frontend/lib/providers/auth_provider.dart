import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel?  _user;
  String?     _errorMessage;
  bool        _loading = false;

  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool       get loading      => _loading;
  bool       get isAuth       => _status == AuthStatus.authenticated;

  // ─── Initialisation au démarrage ─────────────────────────────────────────

  Future<void> checkAuth() async {
    final token = await _api.getToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      _user   = await _api.getMe();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await _api.clearToken();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ─── Inscription ─────────────────────────────────────────────────────────

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String pin,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      final data = await _api.register(
        firstName: firstName,
        lastName:  lastName,
        email:     email,
        password:  password,
        pin:       pin,
        phone:     phone,
      );
      _user   = UserModel.fromJson(data['user']);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Connexion ───────────────────────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final data = await _api.login(email: email, password: password);
      _user   = UserModel.fromJson(data['user']);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Déconnexion ─────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _api.logout();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Rafraîchir le profil ─────────────────────────────────────────────────

  Future<void> refreshUser() async {
    try {
      _user = await _api.getMe();
      notifyListeners();
    } catch (_) {}
  }

  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}

