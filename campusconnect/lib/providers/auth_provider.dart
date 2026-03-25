import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _loading = true;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(AuthState state) async {
    if (state.event == AuthChangeEvent.initialSession ||
        state.event == AuthChangeEvent.signedIn ||
        state.event == AuthChangeEvent.tokenRefreshed) {
      if (state.session == null) {
        _user = null;
      } else {
        // Retry a few times in case the DB trigger hasn't created the row yet
        UserModel? model;
        for (int i = 0; i < 3; i++) {
          model = await _authService.getCurrentUserModel();
          if (model != null) break;
          await Future.delayed(const Duration(milliseconds: 500));
        }
        _user = model;
      }
      _loading = false;
      notifyListeners();
    } else if (state.event == AuthChangeEvent.signedOut) {
      _user = null;
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String nom,
  }) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 1500)); // Load image
      _user = await _authService.signUp(
          email: email, password: password, nom: nom);
      _error = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = _mapAuthError(e.message);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(
      {required String email, required String password}) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 1500)); // Load image
      _user =
          await _authService.signIn(email: email, password: password);
      _error = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = _mapAuthError(e.message);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 1500)); // Load image
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String nom,
    String? bio,
    String? filiere,
    File? photoFile,
    File? coverPhotoFile,
  }) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      _user = await _authService.updateProfile(
        userId: _user!.id,
        nom: nom,
        bio: bio,
        filiere: filiere,
        photoFile: photoFile,
        coverPhotoFile: coverPhotoFile,
      );
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('already registered') ||
        lower.contains('user already exists')) {
      return 'Cet email est déjà utilisé.';
    } else if (lower.contains('invalid email')) {
      return 'Email invalide.';
    } else if (lower.contains('password') &&
        (lower.contains('short') || lower.contains('weak'))) {
      return 'Mot de passe trop faible (min. 6 caractères).';
    } else if (lower.contains('invalid') ||
        lower.contains('credentials') ||
        lower.contains('not found')) {
      return 'Email ou mot de passe incorrect.';
    }
    return 'Une erreur est survenue. Réessayez.';
  }
}
