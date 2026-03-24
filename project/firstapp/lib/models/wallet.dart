class Wallet {
  final int walletId;
  final double balance;
  final double balanceBkn;

  Wallet({required this.walletId, required this.balance, required this.balanceBkn});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      walletId:   json['wallet_id'],
      balance:    (json['balance'] as num).toDouble(),
      balanceBkn: (json['balance_bkn'] as num? ?? 0).toDouble(),
    );
  }
}
