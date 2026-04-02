class Invoice {
  final String id;
  final String name;
  final String category;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String reference;

  Invoice({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.reference,
  });

  bool get isPaid => paidDate != null;
  bool get isOverdue => !isPaid && DateTime.now().isAfter(dueDate);

  String get statusLabel => isPaid
      ? 'Payée'
      : isOverdue
      ? 'En retard'
      : 'En attente';
}
