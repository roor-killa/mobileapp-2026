import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Récupérer l'utilisateur actuel
  User? get currentUser => _supabase.auth.currentUser;

  // Inscription
  Future<AuthResponse> signUp(String email, String password, String fullName) async {
    try {
      // 1. Créer le compte Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // 2. Vérification critique
      if (response.user == null) {
        throw const AuthException("Échec de la création du compte (User null)");
      }

      // 3. Créer le profil dans la table 'profiles'
      // Cela ne fonctionnera que si tu as ajouté la policy INSERT dans Supabase SQL
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'full_name': fullName,
        'balance': 1500.0, // Solde de bienvenue par défaut
      });
      
      return response;
    } catch (e) {
      // Pour le débogage, on affiche l'erreur dans la console
      print("Erreur Inscription AuthService: $e");
      rethrow; // Renvoie l'erreur pour l'afficher à l'utilisateur via le SnackBar
    }
  }

  // Connexion
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Déconnexion
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
