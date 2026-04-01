class Tx {
  final int id;
  final String type; // BUY, SELL, TRANSFER_IN, TRANSFER_OUT
  final double amountBkn;
  final String status; // OK, NOK
  final String createdAt;
  final String? counterparty;
  final String? note;

  const Tx({
    required this.id,
    required this.type,
    required this.amountBkn,
    required this.status,
    required this.createdAt,
    this.counterparty,
    this.note,
  });

  factory Tx.fromJson(Map<String, dynamic> json) => Tx(
        id: (json['id'] as num).toInt(),
        type: (json['type'] ?? '').toString(),
        amountBkn: (json['amount_bkn'] as num).toDouble(),
        status: (json['status'] ?? 'OK').toString(),
        createdAt: (json['created_at'] ?? '').toString(),
        counterparty: json['counterparty']?.toString(),
        note: json['note']?.toString(),
      );

  bool get isDebit => type == 'SELL' || type == 'TRANSFER_OUT';

  String get signedAmount => '${isDebit ? '-' : '+'}${amountBkn.toStringAsFixed(2)} BKN';

  String get displayType {
    switch (type) {
      case 'BUY':
        return 'Achat';
      case 'SELL':
        return 'Vente';
      case 'TRANSFER_IN':
        return 'Réception';
      case 'TRANSFER_OUT':
        return 'Transfert';
      default:
        return type;
    }
  }
}
