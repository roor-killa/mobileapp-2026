class CryptoAsset {
  final String symbol;
  final String name;
  final String emoji;
  double currentPrice;
  List<double> priceHistory;
  double? changePercent24h;
  double? high24h;
  double? low24h;

  CryptoAsset({
    required this.symbol,
    required this.name,
    required this.emoji,
    required this.currentPrice,
    required this.priceHistory,
    this.changePercent24h,
    this.high24h,
    this.low24h,
  });

  bool get isGain => changePercent24h != null && changePercent24h! > 0;
}

class CryptoPortfolio {
  final String symbol;
  final double quantity;
  final double purchasePrice;

  CryptoPortfolio({
    required this.symbol,
    required this.quantity,
    required this.purchasePrice,
  });

  double get value => quantity * purchasePrice;
}
