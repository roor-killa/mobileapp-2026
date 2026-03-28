import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _resetEmail;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get resetEmail => _resetEmail;

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

  /// Étape 1 : envoie un OTP 6 chiffres par email
  Future<bool> sendPasswordResetOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );
      _resetEmail = email;
      return true;
    } on AuthException catch (e) {
      _error = _friendlyAuthError(e.message);
      return false;
    } catch (e) {
      _error = 'Impossible d\'envoyer le code. Vérifiez l\'adresse email.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Étape 2 : vérifie le code OTP saisi par l'utilisateur
  Future<bool> verifyOtp(String otp) async {
    if (_resetEmail == null) {
      _error = 'Aucune demande de réinitialisation en cours.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: _resetEmail!,
        token: otp,
        type: OtpType.email,
      );
      return true;
    } on AuthException catch (e) {
      _error = (e.message.contains('expired') || e.message.contains('invalid'))
          ? 'Code invalide ou expiré. Réessayez.'
          : _friendlyAuthError(e.message);
      return false;
    } catch (e) {
      _error = 'Erreur lors de la vérification du code.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Étape 3 : définit le nouveau mot de passe
  Future<bool> resetPassword(String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _resetEmail = null;
      await Supabase.instance.client.auth.signOut();
      return true;
    } on AuthException catch (e) {
      _error = _friendlyAuthError(e.message);
      return false;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du mot de passe.';
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
    if (msg.contains('New password should be different')) return 'Le nouveau mot de passe doit être différent de l\'ancien.';
    if (msg.contains('Password should be at least')) return 'Le mot de passe doit contenir au moins 6 caractères.';
    if (msg.contains('Password should')) return 'Mot de passe trop court (min. 6 caractères).';
    if (msg.contains('User not found')) return 'Aucun compte associé à cet email.';
    if (msg.contains('Email not confirmed')) return 'Email non confirmé.';
    return msg;
  }
}