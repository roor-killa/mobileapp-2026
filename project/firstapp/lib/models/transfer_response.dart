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

  /// Transforme le JSON reçu de Laravel en objet Dart
  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      // On utilise les clés exactes définies dans ton AuthController.php
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      
      // .toDouble() est important car le JSON peut envoyer un int ou un double
      montantTotal: (json['montantTotal'] ?? 0.0).toDouble(),
      montantTransfere: (json['montantTransfere'] ?? 0.0).toDouble(),
      nouveauSolde: (json['nouveauSolde'] ?? 0.0).toDouble(),
    );
  }

  /// Optionnel : Convertir l'objet en Map (utile pour le debug)
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