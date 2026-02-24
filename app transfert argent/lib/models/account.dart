class AccountModel {
  final String id;
  final String accountNumber;
  final String label;
  double balance;
  final String ownerId;
  final String ownerName;

  AccountModel({
    required this.id,
    required this.accountNumber,
    required this.label,
    required this.balance,
    required this.ownerId,
    required this.ownerName,
  });

  String get displayName => '$ownerName  •  $accountNumber';

  factory AccountModel.fromJson(Map<String, dynamic> j) => AccountModel(
        id: j['id'] as String,
        accountNumber: j['account_number'] as String,
        label: j['label'] as String? ?? 'Compte',
        balance: (j['balance'] as num).toDouble(),
        ownerId: j['owner_id'] as String,
        ownerName: j['owner_name'] as String? ?? '',
      );
}