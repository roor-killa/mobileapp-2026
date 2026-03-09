class TransactionModel {
  final int? id;
  final int utilisateurId;
  final double montant;
  final double soldeAvant;
  final double soldeApres;
  final String statut; // 'succes' | 'echec'
  final String message;
  final String dateHeure; // ISO 8601
  final String? type; // 'envoi' | 'reception'
  final String? autrePartieNom; // nom du destinataire ou de l'expéditeur

  TransactionModel({
    this.id,
    required this.utilisateurId,
    required this.montant,
    required this.soldeAvant,
    required this.soldeApres,
    required this.statut,
    required this.message,
    required this.dateHeure,
    this.type,
    this.autrePartieNom,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      utilisateurId: map['utilisateur_id'] as int,
      montant: (map['montant'] as num).toDouble(),
      soldeAvant: (map['solde_avant'] as num).toDouble(),
      soldeApres: (map['solde_apres'] as num).toDouble(),
      statut: map['statut'] as String,
      message: map['message'] as String,
      dateHeure: map['date_heure'] as String,
      type: map['type'] as String?,
      autrePartieNom: map['autre_partie_nom'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'utilisateur_id': utilisateurId,
      'montant': montant,
      'solde_avant': soldeAvant,
      'solde_apres': soldeApres,
      'statut': statut,
      'message': message,
      'date_heure': dateHeure,
      'type': type,
      'autre_partie_nom': autrePartieNom,
    };
  }
}
