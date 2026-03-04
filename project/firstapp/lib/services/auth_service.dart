import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/utilisateur.dart';
import 'database_service.dart';

// Note : les mots de passe sont hashés en SHA-256.
// En production, utilisez bcrypt ou argon2 avec un sel unique par utilisateur.
class AuthService {
  static Utilisateur? _utilisateurConnecte;

  static Utilisateur? get utilisateurConnecte => _utilisateurConnecte;
  static bool get estConnecte => _utilisateurConnecte != null;

  static String _hasher(String mdp) {
    final bytes = utf8.encode(mdp);
    return sha256.convert(bytes).toString();
  }

  Future<Utilisateur?> connecter(String email, String mdp) async {
    final u = await DatabaseService.instance.trouverParEmail(email);
    if (u == null || u.motDePasse != _hasher(mdp)) return null;
    _utilisateurConnecte = u;
    return u;
  }

  Future<Utilisateur> inscrire({
    required String nom,
    required String email,
    required String mdp,
    required double soldeInitial,
  }) async {
    final u = Utilisateur(
      nom: nom,
      email: email,
      motDePasse: _hasher(mdp),
      soldeInitial: soldeInitial,
      soldeActuel: soldeInitial,
      creeLe: DateTime.now().toIso8601String(),
    );
    final id = await DatabaseService.instance.creerUtilisateur(u);
    _utilisateurConnecte = u.copyWith(id: id);
    return _utilisateurConnecte!;
  }

  void deconnecter() {
    _utilisateurConnecte = null;
  }
}
