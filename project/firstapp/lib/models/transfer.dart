/// Modèle représentant un transfert d'argent
class Transfer {
  final int id;
  final int fromUserId;
  final int toUserId;
  final double amount;
  final String status;
  final String? description;
  final DateTime createdAt;

  Transfer({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.status,
    this.description,
    required this.createdAt,
  });

  /// Factory pour créer un Transfer depuis JSON
  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'] ?? 0,
      fromUserId: json['from_user_id'] ?? 0,
      toUserId: json['to_user_id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'completed',
      description: json['description'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  /// Convertir l'objet en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'amount': amount,
      'status': status,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
