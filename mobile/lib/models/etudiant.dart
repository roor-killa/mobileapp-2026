// Modèle représentant un étudiant dans la base de données
class Etudiant {
  final int? id;
  final String nom;
  final String prenom;
  final String email;
  // La note globale n'existe plus, les notes sont maintenant
  // gérées par matière dans la table "notes"

  Etudiant({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  // Crée un objet Etudiant depuis le JSON reçu de l'API
  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
    );
  }

  // Convertit l'objet en JSON pour l'envoyer à l'API
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
    };
  }
}