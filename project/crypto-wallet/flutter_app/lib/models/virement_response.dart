/// Modèle représentant la réponse de l'API virements NodEX.
/// API NestJS POST /virements/send (pas Laravel /api/products).
/// Réponse attendue : { success, newBalance, recipientCredited?, recipientNewBalance? }
class VirementResponse {
  final bool success;
  final double newBalance;
  final bool recipientCredited;
  final double? recipientNewBalance;

  VirementResponse({
    required this.success,
    required this.newBalance,
    this.recipientCredited = true,
    this.recipientNewBalance,
  });

  /// Parse la réponse JSON de NestJS POST /virements/send
  factory VirementResponse.fromJson(Map<String, dynamic> json) {
    final newBal = json['newBalance'] ?? json['new_balance'];
    final newBalNum = newBal is num ? newBal.toDouble() : (double.tryParse(newBal?.toString() ?? '') ?? 0.0);
    return VirementResponse(
      success: json['success'] == true,
      newBalance: newBalNum,
      recipientCredited: json['recipientCredited'] == true || json['recipient_credited'] == true,
      recipientNewBalance: _toDouble(json['recipientNewBalance'] ?? json['recipient_new_balance']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
