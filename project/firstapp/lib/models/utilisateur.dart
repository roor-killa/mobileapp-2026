class Utilisateur {
  final int? id;
  final String nom;
  final String email;
  final String motDePasse; // SHA-256
  final double soldeInitial;
  double soldeActuel;
  final String creeLe;

  Utilisateur({
    this.id,
    required this.nom,
    required this.email,
    required this.motDePasse,
    required this.soldeInitial,
    required this.soldeActuel,
    required this.creeLe,
  });

  Utilisateur copyWith({int? id}) {
    return Utilisateur(
      id: id ?? this.id,
      nom: nom,
      email: email,
      motDePasse: motDePasse,
      soldeInitial: soldeInitial,
      soldeActuel: soldeActuel,
      creeLe: creeLe,
    );
  }

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      email: map['email'] as String,
      motDePasse: map['mot_de_passe'] as String,
      soldeInitial: (map['solde_initial'] as num).toDouble(),
      soldeActuel: (map['solde_actuel'] as num).toDouble(),
      creeLe: map['cree_le'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'email': email,
      'mot_de_passe': motDePasse,
      'solde_initial': soldeInitial,
      'solde_actuel': soldeActuel,
      'cree_le': creeLe,
    };
  }
}
