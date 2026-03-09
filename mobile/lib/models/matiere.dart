// Modèle représentant une matière
class Matiere {
  final int id;
  final String nom;

  Matiere({
    required this.id,
    required this.nom,
  });

  // Crée un objet Matiere depuis le JSON reçu de l'API
  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      id: json['id'],
      nom: json['nom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}