class TransactionModel {
  final String id;
  final String? senderId;
  final String? receiverId;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;
  final double amount;
  final String type;
  final String status;
  final String? description;
  final String referenceCode;
  final String? direction; // 'sent' | 'received'
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    this.senderId,
    this.receiverId,
    this.sender,
    this.receiver,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    required this.referenceCode,
    this.direction,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] ?? '',
        senderId: json['sender_id'],
        receiverId: json['receiver_id'],
        sender: json['sender'] as Map<String, dynamic>?,
        receiver: json['receiver'] as Map<String, dynamic>?,
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        type: json['type'] ?? 'send',
        status: json['status'] ?? 'pending',
        description: json['description'],
        referenceCode: json['reference_code'] ?? '',
        direction: json['direction'],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
            : DateTime.now(),
      );

  bool get isSent => direction == 'sent';
  bool get isSuccess => status == 'success';

  String get otherPartyName {
    if (type == 'recharge') return 'TransfertApp (Recharge)';
    if (type == 'qr_payment') {
      if (isSent) {
        return receiver != null
            ? '${receiver!['first_name']} ${receiver!['last_name']}'
            : 'QR Payment';
      }
      return sender != null
          ? '${sender!['first_name']} ${sender!['last_name']}'
          : 'QR Payment';
    }
    if (isSent) {
      return receiver != null
          ? '${receiver!['first_name']} ${receiver!['last_name']}'
          : 'Inconnu';
    }
    return sender != null
        ? '${sender!['first_name']} ${sender!['last_name']}'
        : 'Inconnu';
  }

  String get typeLabel {
    switch (type) {
      case 'send':
        return isSent ? 'Envoi' : 'Réception';
      case 'recharge':
        return 'Recharge';
      case 'qr_payment':
        return 'Paiement QR';
      default:
        return type;
    }
  }
}
