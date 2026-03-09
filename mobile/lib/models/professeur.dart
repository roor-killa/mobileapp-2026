// Modèle représentant un professeur connecté
class Professeur {
  final int id;
  final String nom;
  final String prenom;
  final String email;

  Professeur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  // Crée un objet Professeur depuis le JSON reçu de l'API
  factory Professeur.fromJson(Map<String, dynamic> json) {
    return Professeur(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
    );
  }
}
