import 'package:supabase_flutter/supabase_flutter.dart';

/// Utilisateur connecté (même interface qu'avant pour le reste de l'app).
class User {
  final String id;
  final String email;
  final String? name;
  User({required this.id, required this.email, this.name});
}

/// Auth via Supabase (signUp, signInWithPassword, signOut, getUser).
class AuthServiceSupabase {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  Future<User?> getCurrentUser() async {
    final session = _auth.currentSession;
    final u = session?.user;
    if (u == null) return null;
    final name = u.userMetadata?['name'] as String?;
    return User(id: u.id, email: u.email ?? '', name: name);
  }

  /// Retourne le JWT Supabase pour l’envoyer au backend (wallets, etc.).
  String? get accessToken => _auth.currentSession?.accessToken;

  /// Inscription : Supabase signUp avec envoi d'email de vérification.
  /// Si [emailRedirectTo] est fourni, le lien de confirmation redirigera vers cette URL.
  /// Retourne (User?, needsEmailVerification) - si needsEmailVerification, l'utilisateur doit confirmer son email.
  Future<({User? user, bool needsEmailVerification})> register(
    String email,
    String password,
    String name, {
    String? emailRedirectTo,
  }) async {
    try {
      final res = await _auth.signUp(
        email: email,
        password: password,
        data: name.isNotEmpty ? {'name': name} : null,
        emailRedirectTo: emailRedirectTo,
      );
      if (res.user == null) {
        throw Exception('Inscription impossible');
      }
      final u = res.user!;
      final user = User(
        id: u.id,
        email: u.email ?? '',
        name: u.userMetadata?['name'] as String? ?? (name.isNotEmpty ? name : null),
      );
      // Session null = email confirmation requise (Supabase a envoyé un email avec lien/code)
      final needsVerification = res.session == null;
      return (user: user, needsEmailVerification: needsVerification);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Renvoie l'email de confirmation d'inscription.
  Future<void> resendConfirmationEmail(String email, {String? emailRedirectTo}) async {
    try {
      await _auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: emailRedirectTo,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Connexion : Supabase signInWithPassword.
  Future<User> login(String email, String password) async {
    try {
      final res = await _auth.signInWithPassword(email: email, password: password);
      if (res.user == null) {
        throw Exception('Connexion impossible');
      }
      final u = res.user!;
      return User(
        id: u.id,
        email: u.email ?? '',
        name: u.userMetadata?['name'] as String?,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Déconnexion de tous les appareils (révoque toutes les sessions).
  Future<void> logoutFromAllDevices() async {
    await _auth.signOut(scope: SignOutScope.global);
  }

  /// Envoie un email de réinitialisation du mot de passe.
  /// [redirectTo] : URL de redirection après clic sur le lien (ex: http://localhost:port/ pour le web).
  Future<void> resetPasswordForEmail(String email, {String? redirectTo}) async {
    try {
      await _auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Met à jour le mot de passe après récupération (via le lien email).
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }
}
