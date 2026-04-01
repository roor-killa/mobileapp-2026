/// Modèle représentant un objectif d'épargne.
class GoalModel {
  final int? id;
  final int utilisateurId;
  final String nom;
  final String emoji;
  final double montantCible;
  double montantActuel;
  final String dateCreation;
  final String? dateEcheance;

  GoalModel({
    this.id,
    required this.utilisateurId,
    required this.nom,
    this.emoji = '🎯',
    required this.montantCible,
    this.montantActuel = 0.0,
    required this.dateCreation,
    this.dateEcheance,
  });

  /// Progression entre 0.0 et 1.0.
  double get progression =>
      montantCible > 0 ? (montantActuel / montantCible).clamp(0.0, 1.0) : 0.0;

  bool get estAtteint => montantActuel >= montantCible;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'utilisateur_id': utilisateurId,
        'nom': nom,
        'emoji': emoji,
        'montant_cible': montantCible,
        'montant_actuel': montantActuel,
        'date_creation': dateCreation,
        'date_echeance': dateEcheance,
      };

  factory GoalModel.fromMap(Map<String, dynamic> map) => GoalModel(
        id: map['id'] as int?,
        utilisateurId: map['utilisateur_id'] as int,
        nom: map['nom'] as String,
        emoji: map['emoji'] as String? ?? '🎯',
        montantCible: (map['montant_cible'] as num).toDouble(),
        montantActuel: (map['montant_actuel'] as num).toDouble(),
        dateCreation: map['date_creation'] as String,
        dateEcheance: map['date_echeance'] as String?,
      );
}
