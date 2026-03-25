import 'package:appwrite/appwrite.dart';
import '../config/appwrite_config.dart';
import 'appwrite_service.dart';

/// Utilisateur connecté (même interface qu'avant pour le reste de l'app).
class User {
  final String id;
  final String email;
  final String? name;
  User({required this.id, required this.email, this.name});
}

/// Auth via Appwrite (create, createEmailPasswordSession, get, createJWT, deleteSession).
class AuthServiceAppwrite {
  Account get _account => appwriteAccount;

  Future<User?> getCurrentUser() async {
    try {
      final u = await _account.get();
      return User(
        id: u.$id,
        email: u.email,
        name: u.name,
      );
    } catch (_) {
      return null;
    }
  }

  /// Retourne le JWT Appwrite pour l'envoyer au backend (wallets, etc.).
  /// Les JWT expirent après 15 min — on en génère un à la demande.
  Future<String?> getAccessToken() async {
    try {
      final jwt = await _account.createJWT();
      return jwt.jwt;
    } catch (_) {
      return null;
    }
  }

  /// Inscription : crée le compte, envoie un email de vérification, puis connecte l'utilisateur.
  /// Si SMTP est configuré dans Appwrite, l'utilisateur reçoit un email avec un lien de vérification.
  Future<({User? user, bool needsEmailVerification})> register(
    String email,
    String password,
    String name, {
    String? emailRedirectTo,
  }) async {
    try {
      await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name.isNotEmpty ? name : null,
      );
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      final u = await _account.get();
      final user = User(id: u.$id, email: u.email, name: u.name);

      // Envoie l'email de vérification (nécessite SMTP configuré dans Appwrite Console)
      try {
        await _account.createVerification(
          url: emailRedirectTo ?? AppwriteConfig.verificationRedirectUrl,
        );
        return (user: user, needsEmailVerification: true);
      } on AppwriteException catch (_) {
        // SMTP non configuré ou erreur : on connecte sans vérification
        return (user: user, needsEmailVerification: false);
      }
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Inscription impossible');
    }
  }

  /// Renvoie l'email de vérification. L'utilisateur doit être connecté.
  Future<void> resendConfirmationEmail(String email, {String? emailRedirectTo}) async {
    try {
      await _account.createVerification(
        url: emailRedirectTo ?? AppwriteConfig.verificationRedirectUrl,
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Impossible de renvoyer l\'email');
    }
  }

  /// Complète la vérification email après clic sur le lien (userId et secret dans l'URL).
  Future<void> completeEmailVerification(String userId, String secret) async {
    await _account.updateVerification(
      userId: userId,
      secret: secret,
    );
  }

  /// Connexion : Appwrite createEmailPasswordSession.
  Future<User> login(String email, String password) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      final u = await _account.get();
      return User(id: u.$id, email: u.email, name: u.name);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Identifiants invalides');
    }
  }

  /// Email OTP : envoie un code à l'email. Retourne userId à garder pour l'étape 2.
  /// Appwrite Console : configurer SMTP (Auth → Settings → Email) pour envoyer les emails.
  Future<String> sendEmailOTP(String email) async {
    try {
      final token = await _account.createEmailToken(
        userId: ID.unique(),
        email: email,
      );
      return token.userId;
    } on AppwriteException catch (e) {
      final msg = e.message ?? 'Erreur lors de l\'envoi du code';
      if (msg.toLowerCase().contains('smtp') || msg.toLowerCase().contains('email')) {
        throw Exception('$msg Vérifiez la configuration SMTP dans Appwrite Console → Auth → Settings.');
      }
      throw Exception(msg);
    }
  }

  /// Email OTP : connexion avec le code reçu par email.
  Future<User> verifyEmailOTP(String userId, String code) async {
    try {
      await _account.createSession(
        userId: userId,
        secret: code,
      );
      final u = await _account.get();
      return User(id: u.$id, email: u.email, name: u.name);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Code invalide ou expiré');
    }
  }

  /// Phone : envoie un SMS avec code. Retourne userId pour l'étape 2.
  /// Appwrite Console : configurer un fournisseur SMS (Twilio, etc.) dans Auth → Settings → Phone.
  /// Format du numéro : +33612345678 (indicatif pays + numéro sans espaces).
  Future<String> sendPhoneOTP(String phone) async {
    try {
      final normalized = _normalizePhone(phone);
      final token = await _account.createPhoneToken(
        userId: ID.unique(),
        phone: normalized,
      );
      return token.userId;
    } on AppwriteException catch (e) {
      final msg = e.message ?? 'Erreur lors de l\'envoi du SMS';
      if (msg.toLowerCase().contains('provider') || msg.toLowerCase().contains('sms') || msg.toLowerCase().contains('phone')) {
        throw Exception('$msg Configurez un fournisseur SMS (Twilio) dans Appwrite Console → Auth → Settings.');
      }
      throw Exception(msg);
    }
  }

  /// Normalise le numéro pour Appwrite : +33XXXXXXXXX.
  String _normalizePhone(String phone) {
    String s = phone.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
    if (s.startsWith('0')) s = '+33${s.substring(1)}';
    else if (!s.startsWith('+')) s = '+33$s';
    return s;
  }

  /// Phone : connexion avec le code reçu par SMS.
  Future<User> verifyPhoneOTP(String userId, String code) async {
    try {
      await _account.updatePhoneSession(
        userId: userId,
        secret: code,
      );
      final u = await _account.get();
      return User(
        id: u.$id,
        email: u.email,
        name: u.name,
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Code invalide ou expiré');
    }
  }

  /// Magic URL : envoie un lien magique par email. L'utilisateur clique sur le lien pour se connecter.
  /// Appwrite Console : ajouter la plateforme Web (localhost ou votre domaine) dans Auth → Settings.
  /// L'URL de redirection doit être autorisée (localhost est autorisé par défaut).
  Future<void> sendMagicURLToken(String email, {required String redirectUrl}) async {
    try {
      await _account.createMagicURLToken(
        userId: ID.unique(),
        email: email,
        url: redirectUrl,
      );
    } on AppwriteException catch (e) {
      final msg = e.message ?? 'Erreur lors de l\'envoi du lien';
      if (msg.toLowerCase().contains('url') || msg.toLowerCase().contains('redirect') || msg.toLowerCase().contains('domain')) {
        throw Exception('$msg Vérifiez que l\'URL de redirection est autorisée dans Appwrite Console (Auth → Platforms).');
      }
      throw Exception(msg);
    }
  }

  /// Magic URL : complète la connexion après clic sur le lien (userId et secret dans l'URL).
  Future<User> completeMagicURL(String userId, String secret) async {
    try {
      await _account.createSession(
        userId: userId,
        secret: secret,
      );
      final u = await _account.get();
      return User(id: u.$id, email: u.email, name: u.name);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Lien invalide ou expiré');
    }
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {}
  }

  Future<void> logoutFromAllDevices() async {
    try {
      await _account.deleteSessions();
    } catch (_) {}
  }

  /// Demande de réinitialisation du mot de passe (envoie un email).
  Future<void> resetPasswordForEmail(String email, {String? redirectTo}) async {
    try {
      await _account.createRecovery(
        email: email,
        url: redirectTo ?? AppwriteConfig.redirectUrl,
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Erreur lors de la demande');
    }
  }

  /// Met à jour le mot de passe après récupération (via le lien email).
  /// Nécessite userId et secret du lien de récupération.
  Future<void> updatePassword(String newPassword) async {
    // L'écran UpdatePasswordScreen gère le flux de récupération.
    // Ici on suppose que l'utilisateur est déjà authentifié (flux "changer mot de passe").
    // Pour le flux "récupération", il faut userId + secret depuis l'URL.
    try {
      await _account.updatePassword(password: newPassword);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Erreur lors de la mise à jour');
    }
  }

  /// Met à jour le mot de passe via le lien de récupération (userId + secret depuis l'email).
  Future<void> updateRecovery({
    required String userId,
    required String secret,
    required String newPassword,
  }) async {
    try {
      await _account.updateRecovery(
        userId: userId,
        secret: secret,
        password: newPassword,
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Erreur lors de la récupération');
    }
  }
}
