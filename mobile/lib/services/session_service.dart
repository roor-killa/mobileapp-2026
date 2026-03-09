import '../models/professeur.dart';

// Service qui garde en mémoire le professeur connecté
// pendant toute la durée de la session
class SessionService {
  // Instance unique (singleton) - un seul objet SessionService dans toute l'app
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // Le professeur actuellement connecté (null si personne n'est connecté)
  Professeur? _professeurConnecte;

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
}