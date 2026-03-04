class Transaction {
  final int id;
  final double amount;
  final String date;
  final String senderName;
  final String receiverName;
  final int senderId;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.senderName,
    required this.receiverName,
    required this.senderId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      date: json['created_at'],
      // On va chercher le nom dans l'objet imbriqué envoyé par Laravel (le 'with')
      senderName: json['sender']['name'] ?? 'Inconnu',
      receiverName: json['receiver']['name'] ?? 'Inconnu',
      senderId: json['sender_id'],
    );
  }
}