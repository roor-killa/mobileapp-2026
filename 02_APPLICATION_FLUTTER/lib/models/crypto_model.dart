class CryptoModel {
  final String id;
  final String symbol;
  final String name;
  final double price;
  final double priceChangePercent24h;
  final double marketCap;
  final double volume24h;
  final String image;
  final List<double> sparklineData;

  CryptoModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.price,
    required this.priceChangePercent24h,
    required this.marketCap,
    required this.volume24h,
    required this.image,
    required this.sparklineData,
  });

  static List<CryptoModel> mockCryptos = [
    CryptoModel(
      id: 'bitcoin',
      symbol: 'BTC',
      name: 'Bitcoin',
      price: 42500.50,
      priceChangePercent24h: 2.45,
      marketCap: 830000000000,
      volume24h: 28000000000,
      image: '₿',
      sparklineData: [40000, 40500, 41000, 41500, 42000, 42500],
    ),
    CryptoModel(
      id: 'ethereum',
      symbol: 'ETH',
      name: 'Ethereum',
      price: 2250.75,
      priceChangePercent24h: -0.85,
      marketCap: 270000000000,
      volume24h: 12000000000,
      image: 'Ξ',
      sparklineData: [2200, 2210, 2230, 2240, 2250, 2250],
    ),
    CryptoModel(
      id: 'cardano',
      symbol: 'ADA',
      name: 'Cardano',
      price: 0.95,
      priceChangePercent24h: 1.25,
      marketCap: 34000000000,
      volume24h: 1500000000,
      image: '₳',
      sparklineData: [0.90, 0.91, 0.92, 0.93, 0.94, 0.95],
    ),
    CryptoModel(
      id: 'solana',
      symbol: 'SOL',
      name: 'Solana',
      price: 150.25,
      priceChangePercent24h: 5.12,
      marketCap: 65000000000,
      volume24h: 3500000000,
      image: '◎',
      sparklineData: [140, 142, 144, 147, 149, 150],
    ),
    CryptoModel(
      id: 'ripple',
      symbol: 'XRP',
      name: 'Ripple',
      price: 2.45,
      priceChangePercent24h: -1.50,
      marketCap: 135000000000,
      volume24h: 5000000000,
      image: '✕',
      sparklineData: [2.50, 2.48, 2.47, 2.46, 2.45, 2.45],
    ),
  ];

  String get priceFormatted => '\$${price.toStringAsFixed(2)}';
  String get marketCapFormatted => formatLargeNumber(marketCap);
  String get volume24hFormatted => formatLargeNumber(volume24h);

  static String formatLargeNumber(double number) {
    if (number >= 1000000000) {
      return '\$${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '\$${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '\$${(number / 1000).toStringAsFixed(2)}K';
    } else {
      return '\$${number.toStringAsFixed(2)}';
    }
  }
}
