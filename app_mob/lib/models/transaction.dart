class TransactionModel { // J'ai renommé pour éviter les conflits
  final String senderName;
  final String receiverName;
  final double amount;
  final DateTime date;

  TransactionModel({
    required this.senderName,
    required this.receiverName,
    required this.amount,
    required this.date,
  });
}
