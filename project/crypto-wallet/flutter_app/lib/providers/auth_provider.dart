import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../services/auth_service_supabase.dart';

class AuthProvider with ChangeNotifier {
  final AuthServiceSupabase _auth = AuthServiceSupabase();
  User? _user;
  bool _loading = true;

  User? get user => _user;
  bool get isLoading => _loading;
  bool get isAuthenticated => _user != null;

  /// Envoie le JWT Supabase au client API pour que le backend reçoive le token.
  void _syncTokenToApi() {
    final token = _auth.accessToken;
    if (token != null) ApiClient().setToken(token);
  }

  Future<void> checkAuth() async {
    _loading = true;
    notifyListeners();
    try {
      _user = await _auth.getCurrentUser();
      if (_user != null) _syncTokenToApi();
    } catch (_) {
      _user = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _user = await _auth.login(email, password);
    _syncTokenToApi();
    notifyListeners();
  }

  Future<void> register(String email, String password, String name) async {
    _user = await _auth.register(email, password, name);
    _syncTokenToApi();
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    ApiClient().clearToken();
    _user = null;
    notifyListeners();
  }
}
