class TransactionModel {
  final String id;
  final String type;
  final String status;
  final String direction; // 'debit' ou 'credit'
  final int amount;
  final String amountFormatted;
  final String? reference;
  final String? note;
  final Map<String, dynamic>? counterpart;
  final DateTime createdAt;
  final String? blockchainTxId;
  final String? blockchainExplorerUrl;

  TransactionModel({
    required this.id,
    required this.type,
    required this.status,
    required this.direction,
    required this.amount,
    required this.amountFormatted,
    this.reference,
    this.note,
    this.counterpart,
    required this.createdAt,
    this.blockchainTxId,
    this.blockchainExplorerUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id:                    json['id'] ?? '',
      type:                  json['type'] ?? '',
      status:                json['status'] ?? '',
      direction:             json['direction'] ?? 'credit',
      amount:                json['amount'] ?? 0,
      amountFormatted:       json['amount_formatted'] ?? '0,00 €',
      reference:             json['reference'],
      note:                  json['note'],
      counterpart:           json['counterpart'],
      createdAt:             DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      blockchainTxId:        json['blockchain_tx_id'],
      blockchainExplorerUrl: json['blockchain_explorer_url'],
    );
  }

  bool get hasBlockchain => blockchainTxId != null;

  bool get isDebit  => direction == 'debit';
  bool get isCredit => direction == 'credit';

  String get typeLabel {
    switch (type) {
      case 'transfer':   return 'Transfert';
      case 'recharge':   return 'Recharge';
      case 'qr_send':    return 'Paiement QR';
      case 'qr_receive': return 'Réception QR';
      default:           return type;
    }
  }
}

