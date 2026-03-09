// Modèle représentant un administrateur connecté
class Admin {
  final int id;
  final String nom;
  final String prenom;
  final String email;

  Admin({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  // Crée un objet Admin depuis le JSON reçu de l'API
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
    );
  }
}