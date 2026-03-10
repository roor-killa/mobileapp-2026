import '../models/professeur.dart';
import '../models/admin.dart';
import '../models/etudiant.dart'; // ← NOUVEAU : import du modèle étudiant

// ============================================================
// SERVICE : SessionService
// Garde en mémoire l'utilisateur connecté pendant toute
// la durée de la session (pattern Singleton).
//
// 3 types d'utilisateurs gérés :
//   - Professeur  → espace gestion des étudiants
//   - Admin       → espace administration
//   - Etudiant    → espace consultation des notes  ← NOUVEAU
// ============================================================

class SessionService {

  // ----------------------------------------------------------
  // SINGLETON : une seule instance dans toute l'application
  // On utilise une factory + instance statique privée
  // ----------------------------------------------------------
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // ----------------------------------------------------------
  // VARIABLES PRIVÉES
  // Stockent l'utilisateur connecté pour chaque rôle
  // null = personne n'est connecté pour ce rôle
  // ----------------------------------------------------------
  Professeur? _professeurConnecte;
  Admin?      _adminConnecte;
  Etudiant?   _etudiantConnecte; // ← NOUVEAU

  // ==========================================================
  // SECTION PROFESSEUR
  // ==========================================================

  /// Sauvegarde le professeur après connexion réussie
  void connecter(Professeur professeur) {
    _professeurConnecte = professeur;
  }

  /// Supprime le professeur de la session (déconnexion)
  void deconnecter() {
    _professeurConnecte = null;
  }

  /// Retourne le professeur actuellement connecté (ou null)
  Professeur? get professeurConnecte => _professeurConnecte;

  /// Retourne true si un professeur est connecté
  bool get estConnecte => _professeurConnecte != null;

  // ==========================================================
  // SECTION ADMIN
  // ==========================================================

  /// Sauvegarde l'admin après connexion réussie
  void connecterAdmin(Admin admin) {
    _adminConnecte = admin;
  }

  /// Supprime l'admin de la session (déconnexion)
  void deconnecterAdmin() {
    _adminConnecte = null;
  }

  /// Retourne l'admin actuellement connecté (ou null)
  Admin? get adminConnecte => _adminConnecte;

  /// Retourne true si un admin est connecté
  bool get adminEstConnecte => _adminConnecte != null;

  // ==========================================================
  // SECTION ÉTUDIANT ← NOUVEAU
  // ==========================================================

  /// Sauvegarde l'étudiant après connexion réussie sur l'espace étudiant
  void connecterEtudiant(Etudiant etudiant) {
    _etudiantConnecte = etudiant;
  }

  /// Supprime l'étudiant de la session (déconnexion)
  void deconnecterEtudiant() {
    _etudiantConnecte = null;
  }

  /// Retourne l'étudiant actuellement connecté (ou null)
  Etudiant? get etudiantConnecte => _etudiantConnecte;

  /// Retourne true si un étudiant est connecté
  bool get etudiantEstConnecte => _etudiantConnecte != null;
}