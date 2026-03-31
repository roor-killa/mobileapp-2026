// Modèle représentant un étudiant dans la base de données
class Etudiant {
  final int? id;
  final String nom;
  final String prenom;
  final String email;
  final int? classeId;
  final String? classeNom;

  Etudiant({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.classeId,
    this.classeNom,
  });

  // Crée un objet Etudiant depuis le JSON reçu de l'API
  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      classeId: json['classe_id'],
      classeNom: json['classe'] != null ? json['classe']['nom'] : null,
    );
  }

  // Convertit l'objet en JSON pour l'envoyer à l'API
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      if (classeId != null) 'classe_id': classeId,
    };
  }
}

