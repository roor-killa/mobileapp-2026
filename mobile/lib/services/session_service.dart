import '../models/professeur.dart';
import '../models/admin.dart';

// Service qui garde en mémoire l'utilisateur connecté
// pendant toute la durée de la session
class SessionService {
  // Instance unique (singleton)
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // Le professeur actuellement connecté (null si personne n'est connecté)
  Professeur? _professeurConnecte;

  // L'admin actuellement connecté (null si personne n'est connecté)
  Admin? _adminConnecte;

  // ─── PROFESSEUR ─────────────────────────────────────────────────────────

  // Sauvegarde le professeur connecté
  void connecter(Professeur professeur) {
    _professeurConnecte = professeur;
  }

  // Supprime le professeur connecté (déconnexion)
  void deconnecter() {
    _professeurConnecte = null;
  }

  // Retourne le professeur connecté
  Professeur? get professeurConnecte => _professeurConnecte;

  // Retourne true si un professeur est connecté
  bool get estConnecte => _professeurConnecte != null;

  // ─── ADMIN ──────────────────────────────────────────────────────────────

  // Sauvegarde l'admin connecté
  void connecterAdmin(Admin admin) {
    _adminConnecte = admin;
  }

  // Supprime l'admin connecté (déconnexion)
  void deconnecterAdmin() {
    _adminConnecte = null;
  }

  // Retourne l'admin connecté
  Admin? get adminConnecte => _adminConnecte;

  // Retourne true si un admin est connecté
  bool get adminEstConnecte => _adminConnecte != null;
}