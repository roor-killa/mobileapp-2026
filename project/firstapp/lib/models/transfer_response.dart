/// Modèle représentant la réponse de l'API
/// Facilite la conversion JSON <-> Objet Dart
class TransferResponse {
  final bool success;
  final double montantTotal;
  final double montantTransfere;
  final double nouveauSolde;
  final String message;

  TransferResponse({
    required this.success,
    required this.montantTotal,
    required this.montantTransfere,
    required this.nouveauSolde,
    required this.message,
  });

  /// Factory pour créer un objet depuis JSON
  /// C'est ici qu'on "parse" le JSON reçu de l'API
  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      success: json['success'] ?? false,
      montantTotal: (json['montant_total'] ?? 0).toDouble(),
      montantTransfere: (json['montant_transfere'] ?? 0).toDouble(),
      nouveauSolde: (json['nouveau_solde'] ?? 0).toDouble(),
      message: json['message'] ?? '',
    );
  }

  /// Méthode pour convertir l'objet en JSON (si besoin)
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'montant_total': montantTotal,
      'montant_transfere': montantTransfere,
      'nouveau_solde': nouveauSolde,
      'message': message,
    };
  }
}