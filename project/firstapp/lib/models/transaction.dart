class Transaction {
  final int id;
  final String type; // 'topup', 'transfer_out', 'transfer_in'
  final double amount;
  final String status;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id:        json['id'],
      type:      json['type'],
      amount:    (json['amount'] as num).toDouble(),
      status:    json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
