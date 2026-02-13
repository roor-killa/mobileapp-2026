class TransferResponse {
  final bool success;
  final double montantTotal;      // Solde avant
  final double montantTransfere;  // Montant du virement
  final double nouveauSolde;      // Solde après
  final String message;

  TransferResponse({
    required this.success,
    required this.montantTotal,
    required this.montantTransfere,
    required this.nouveauSolde,
    required this.message,
  });

  // Factory pour créer un objet depuis le JSON reçu du serveur
  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      success: json['success'] ?? false,
      // On utilise (num) pour accepter à la fois int et double, puis on convertit
      montantTotal: (json['montant_total'] as num?)?.toDouble() ?? 0.0,
      montantTransfere: (json['montant_transfere'] as num?)?.toDouble() ?? 0.0,
      nouveauSolde: (json['nouveau_solde'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] ?? '',
    );
  }
}
