class Transaction {
  final int id;
  final String type; // 'topup', 'transfer_out', 'transfer_in'
  final double amount;
  final String status;
  final DateTime createdAt;
  final String? relatedUserName;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.relatedUserName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id:              json['id'],
      type:            json['type'],
      amount:          double.parse(json['amount'].toString()),
      status:          json['status'],
      createdAt:       DateTime.parse(json['created_at']),
      relatedUserName: json['related_user_name'] as String?,
    );
  }
}
