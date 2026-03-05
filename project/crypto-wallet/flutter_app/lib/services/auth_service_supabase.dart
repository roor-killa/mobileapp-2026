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

  /// Inscription : Supabase signUp (email + password, optionnellement name en metadata).
  Future<User> register(String email, String password, String name) async {
    try {
      final res = await _auth.signUp(
        email: email,
        password: password,
        data: name.isNotEmpty ? {'name': name} : null,
      );
      if (res.user == null) {
        throw Exception('Inscription impossible');
      }
      final u = res.user!;
      return User(
        id: u.id,
        email: u.email ?? '',
        name: u.userMetadata?['name'] as String? ?? (name.isNotEmpty ? name : null),
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
}
