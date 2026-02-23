class Wallet {
  final int walletId;
  final double balance;

  Wallet({required this.walletId, required this.balance});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      walletId: json['wallet_id'],
      balance:  (json['balance'] as num).toDouble(),
    );
  }
}
