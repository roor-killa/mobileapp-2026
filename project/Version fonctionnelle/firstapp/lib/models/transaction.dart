class Transaction {
  final int id;
  final String type; // 'sent', 'received', 'topup'
  final double amount;
  final String details;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.details,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      details: json['details'],
      date: DateTime.parse(json['date']),
    );
  }
}