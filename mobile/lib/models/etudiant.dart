class Etudiant {
  final int? id;
  final String nom;
  final String prenom;
  final String email;
  final double note;

  Etudiant({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.note,
  });

  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      note: (json['note'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'note': note,
    };
  }
}