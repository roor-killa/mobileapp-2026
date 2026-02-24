class TransactionModel {
  final String id;
  final double amount;
  final String? note;
  final String fromAccountId;
  final String toAccountId;
  final String fromOwnerName;
  final String toOwnerName;
  final String fromAccountNum;
  final String toAccountNum;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    this.note,
    required this.fromAccountId,
    required this.toAccountId,
    required this.fromOwnerName,
    required this.toOwnerName,
    required this.fromAccountNum,
    required this.toAccountNum,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> j) => TransactionModel(
        id: j['id'] as String,
        amount: (j['amount'] as num).toDouble(),
        note: j['note'] as String?,
        fromAccountId: j['from_account_id'] as String,
        toAccountId: j['to_account_id'] as String,
        fromOwnerName: j['from_owner_name'] as String,
        toOwnerName: j['to_owner_name'] as String,
        fromAccountNum: j['from_account_num'] as String,
        toAccountNum: j['to_account_num'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}