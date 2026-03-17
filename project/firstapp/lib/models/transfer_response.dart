class TransferResponse {
  final bool success;
  final String message;
  final double montantTotal;      // Solde de l'utilisateur AVANT le transfert
  final double montantTransfere;  // Le montant qui vient d'être envoyé
  final double nouveauSolde;      // Le nouveau solde calculé par le serveur

  TransferResponse({
    required this.success,
    required this.message,
    required this.montantTotal,
    required this.montantTransfere,
    required this.nouveauSolde,
  });

  /// Transforme le JSON reçu de Laravel en objet Dart sécurisé
  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      // On récupère success et message
      success: json['success'] ?? false,
      message: json['message'] ?? 'Une erreur est survenue',
      
      // On utilise une conversion sécurisée au cas où les champs sont absents (cas d'erreur 403/400)
      montantTotal: _toDouble(json['montantTotal']),
      montantTransfere: _toDouble(json['montantTransfere']),
      nouveauSolde: _toDouble(json['nouveauSolde']),
    );
  }

  /// Fonction utilitaire privée pour transformer n'importe quelle valeur en double
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'montantTotal': montantTotal,
      'montantTransfere': montantTransfere,
      'nouveauSolde': nouveauSolde,
    };
  }
}