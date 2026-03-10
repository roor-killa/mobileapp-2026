import 'matiere.dart';

// Modèle représentant un professeur
class Professeur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final List<Matiere> matieres;

  Professeur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.matieres = const [],
  });

  factory Professeur.fromJson(Map<String, dynamic> json) {
    return Professeur(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      // "matieres" sans accent pour correspondre à la réponse de l'API
      matieres: json['matieres'] != null
          ? (json['matieres'] as List)
              .map((m) => Matiere.fromJson(m))
              .toList()
          : [],
    );
  }
}