import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Appelé au démarrage : restaure la session Supabase si elle existe
  Future<void> tryRestoreSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;
    try {
      _user = await SupabaseService.getMyProfile();
      notifyListeners();
    } catch (_) {
      await SupabaseService.logout();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await SupabaseService.login(email, password);
      _user = await SupabaseService.getMyProfile();
      return true;
    } on AuthException catch (e) {
      _error = _friendlyAuthError(e.message);
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    double initialBalance = 1000.0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await SupabaseService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        initialBalance: initialBalance,
      );
      _user = await SupabaseService.getMyProfile();
      return true;
    } on AuthException catch (e) {
      _error = _friendlyAuthError(e.message);
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SupabaseService.logout();
    _user = null;
    notifyListeners();
  }

  String _friendlyAuthError(String msg) {
    if (msg.contains('Invalid login')) return 'Email ou mot de passe incorrect.';
    if (msg.contains('already registered')) return 'Cet email est déjà utilisé.';
    if (msg.contains('Password should')) return 'Mot de passe trop court (min. 6 caractères).';
    return msg;
  }
}