import 'matiere.dart';

// Modèle représentant un professeur
class Professeur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final List<Matiere> matieres; // Matières enseignées par le professeur

  Professeur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.matieres = const [],
  });

  // Crée un objet Professeur depuis le JSON reçu de l'API
  factory Professeur.fromJson(Map<String, dynamic> json) {
    return Professeur(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      // Récupère les matières si elles sont incluses dans la réponse
      matieres: json['matières'] != null
          ? (json['matières'] as List)
              .map((m) => Matiere.fromJson(m))
              .toList()
          : [],
    );
  }
}