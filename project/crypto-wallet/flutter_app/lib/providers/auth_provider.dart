import 'package:flutter/foundation.dart';
import '../config/appwrite_config.dart';
import '../services/api_client.dart';
import '../services/auth_service_appwrite.dart';

class AuthProvider with ChangeNotifier {
  final AuthServiceAppwrite _auth = AuthServiceAppwrite();
  User? _user;
  bool _loading = true;
  bool _isPasswordRecovery = false;
  String? _pendingVerificationEmail;

  User? get user => _user;
  bool get isLoading => _loading;
  bool get isAuthenticated => _user != null;
  bool get isPasswordRecovery => _isPasswordRecovery;
  String? get pendingVerificationEmail => _pendingVerificationEmail;

  void clearPendingVerification() {
    _pendingVerificationEmail = null;
    notifyListeners();
  }

  void clearPasswordRecovery() {
    _isPasswordRecovery = false;
    notifyListeners();
  }

  /// Appwrite : pas d'événements auth globaux. La récupération mot de passe via l'écran dédié.
  void initAuthListener() {
    // Rien à faire pour Appwrite
  }

  /// Envoie le JWT Appwrite au client API pour que le backend reçoive le token.
  /// Doit être attendu pour éviter que fetch() s'exécute avant que le token soit stocké.
  Future<void> _syncTokenToApi() async {
    final token = await _auth.getAccessToken();
    if (token != null) await ApiClient().setToken(token);
  }

  /// À appeler avant les requêtes API (carte, virements) pour un JWT à jour et limiter les 401.
  Future<void> syncApiToken() async {
    if (_user != null) await _syncTokenToApi();
  }

  Future<void> checkAuth() async {
    _loading = true;
    notifyListeners();
    // Sécurité : après 10 s, afficher l'écran de login même si checkAuth bloque
    Future.delayed(const Duration(seconds: 10), () {
      if (_loading) {
        _loading = false;
        notifyListeners();
      }
    });
    try {
      // Callback web : userId et secret dans l'URL (Magic URL ou vérification email)
      if (kIsWeb) {
        try {
          final uri = Uri.base;
          final userId = uri.queryParameters['userId'];
          final secret = uri.queryParameters['secret'];
          if (userId != null && secret != null && userId.isNotEmpty && secret.isNotEmpty) {
            final path = uri.path;
            if (path.contains('verify-email')) {
              await completeEmailVerificationFromCallback(userId, secret);
            } else {
              await completeMagicURLFromCallback(userId, secret);
            }
            _loading = false;
            notifyListeners();
            return;
          }
        } catch (_) {
          // Lien expiré ou invalide, continuer le flux normal
        }
      }
      _user = await _auth.getCurrentUser().timeout(
        const Duration(seconds: 8),
        onTimeout: () => null,
      );
      if (_user != null) await _syncTokenToApi();
    } catch (_) {
      _user = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _user = await _auth.login(email, password);
    await _syncTokenToApi();
    notifyListeners();
  }

  /// Email OTP : étape 1 - envoie le code par email. Retourne userId pour l'étape 2.
  Future<String> sendEmailOTP(String email) async {
    return _auth.sendEmailOTP(email);
  }

  /// Email OTP : étape 2 - connexion avec le code reçu.
  Future<void> verifyEmailOTP(String userId, String code) async {
    _user = await _auth.verifyEmailOTP(userId, code);
    await _syncTokenToApi();
    notifyListeners();
  }

  /// Phone : étape 1 - envoie le code par SMS. Retourne userId pour l'étape 2.
  Future<String> sendPhoneOTP(String phone) async {
    return _auth.sendPhoneOTP(phone);
  }

  /// Phone : étape 2 - connexion avec le code reçu.
  Future<void> verifyPhoneOTP(String userId, String code) async {
    _user = await _auth.verifyPhoneOTP(userId, code);
    await _syncTokenToApi();
    notifyListeners();
  }

  /// Magic URL : envoie le lien magique par email.
  Future<void> sendMagicURLToken(String email) async {
    await _auth.sendMagicURLToken(email, redirectUrl: AppwriteConfig.redirectUrl);
  }

  /// Magic URL : complète la connexion après clic sur le lien (callback).
  Future<void> completeMagicURLFromCallback(String userId, String secret) async {
    _user = await _auth.completeMagicURL(userId, secret);
    await _syncTokenToApi();
    notifyListeners();
  }

  /// Inscription. Si Appwrite envoie un email de vérification, _pendingVerificationEmail est défini.
  /// L'utilisateur reste connecté pour pouvoir utiliser "Renvoyer l'email".
  Future<void> register(String email, String password, String name) async {
    final result = await _auth.register(
      email,
      password,
      name,
      emailRedirectTo: AppwriteConfig.verificationRedirectUrl,
    );
    _user = result.user;
    _pendingVerificationEmail = result.needsEmailVerification ? email : null;
    if (_user != null) await _syncTokenToApi();
    notifyListeners();
  }

  /// Renvoie l'email de vérification. L'utilisateur doit être connecté.
  Future<void> resendVerificationEmail() async {
    final email = _pendingVerificationEmail;
    if (email == null) throw Exception('Aucun email en attente');
    await _auth.resendConfirmationEmail(email, emailRedirectTo: AppwriteConfig.verificationRedirectUrl);
  }

  /// Complète la vérification email après clic sur le lien (callback).
  Future<void> completeEmailVerificationFromCallback(String userId, String secret) async {
    await _auth.completeEmailVerification(userId, secret);
    _pendingVerificationEmail = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    ApiClient().clearToken();
    _user = null;
    notifyListeners();
  }

  /// Déconnexion de tous les appareils.
  Future<void> logoutFromAllDevices() async {
    await _auth.logoutFromAllDevices();
    ApiClient().clearToken();
    _user = null;
    notifyListeners();
  }

  /// Demande de réinitialisation du mot de passe (envoie un email).
  Future<void> requestPasswordReset(String email) async {
    await _auth.resetPasswordForEmail(email, redirectTo: AppwriteConfig.redirectUrl);
  }

  /// Met à jour le mot de passe après récupération (via le lien email).
  Future<void> updatePassword(String newPassword) async {
    await _auth.updatePassword(newPassword);
    _isPasswordRecovery = false;
    _user = await _auth.getCurrentUser();
    await _syncTokenToApi();
    notifyListeners();
  }
}
