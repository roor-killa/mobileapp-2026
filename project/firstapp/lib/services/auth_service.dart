import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/utilisateur.dart';
import 'database_service.dart';

// Note : les mots de passe sont hashés en SHA-256.
// En production, utilisez bcrypt ou argon2 avec un sel unique par utilisateur.
class AuthService {
  static Utilisateur? _utilisateurConnecte;
  static const _keySessionUserId = 'session_user_id';

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
    await _sauvegarderSession(u.id!);
    return u;
  }

  Future<Utilisateur> inscrire({
    required String nom,
    required String email,
    required String mdp,
    required double soldeInitial,
  }) async {
    final emailPris = await DatabaseService.instance.emailExiste(email);
    if (emailPris) throw Exception('EMAIL_EXISTE');

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
    await _sauvegarderSession(id);
    return _utilisateurConnecte!;
  }

  Future<void> mettreAJourProfil({String? nom, String? motDePasse}) async {
    final user = _utilisateurConnecte!;
    final hashedMdp = motDePasse != null ? _hasher(motDePasse) : null;
    await DatabaseService.instance.mettreAJourUtilisateur(
      user.id!,
      nom: nom,
      motDePasse: hashedMdp,
    );
    _utilisateurConnecte = user.copyWith(nom: nom, motDePasse: hashedMdp);
  }

  bool verifierMotDePasse(String mdp) {
    return _utilisateurConnecte?.motDePasse == _hasher(mdp);
  }

  Future<void> _sauvegarderSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySessionUserId, userId);
  }

  Future<bool> restaurerSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keySessionUserId);
    if (userId == null) return false;
    final u = await DatabaseService.instance.getUtilisateurById(userId);
    if (u == null) return false;
    _utilisateurConnecte = u;
    return true;
  }

  Future<void> deconnecter() async {
    _utilisateurConnecte = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySessionUserId);
  }
}
