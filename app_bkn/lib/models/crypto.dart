class CryptoCurrency {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final String iconPath;
  final double change24h;

  CryptoCurrency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.iconPath,
    this.change24h = 0.0,
  });

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
    return CryptoCurrency(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'].toUpperCase(),
      price: json['price']?.toDouble() ?? 0.0,
      iconPath: json['iconPath'] ?? 'assets/icons/bitcoin.png',
      change24h: json['change24h']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'price': price,
      'iconPath': iconPath,
      'change24h': change24h,
    };
  }

  static List<CryptoCurrency> get supportedCryptos => [
    CryptoCurrency(
      id: 'bitcoin',
      name: 'Bitcoin',
      symbol: 'BTC',
      price: 45000,
      iconPath: 'assets/icons/bitcoin.png',
      change24h: 2.5,
    ),
    CryptoCurrency(
      id: 'ethereum',
      name: 'Ethereum',
      symbol: 'ETH',
      price: 2800,
      iconPath: 'assets/icons/ethereum.png',
      change24h: -1.2,
    ),
    CryptoCurrency(
      id: 'solana',
      name: 'Solana',
      symbol: 'SOL',
      price: 98,
      iconPath: 'assets/icons/solana.png',
      change24h: 5.8,
    ),
    CryptoCurrency(
      id: 'cardano',
      name: 'Cardano',
      symbol: 'ADA',
      price: 0.45,
      iconPath: 'assets/icons/cardano.png',
      change24h: -0.5,
    ),
    CryptoCurrency(
      id: 'polkadot',
      name: 'Polkadot',
      symbol: 'DOT',
      price: 6.50,
      iconPath: 'assets/icons/polkadot.png',
      change24h: 1.2,
    ),
    CryptoCurrency(
      id: 'avalanche',
      name: 'Avalanche',
      symbol: 'AVAX',
      price: 35,
      iconPath: 'assets/icons/avalanche.png',
      change24h: 3.4,
    ),
  ];
}

class CryptoTransaction {
  final String id;
  final String type; // 'buy' ou 'sell'
  final String crypto;
  final double amountBKN;
  final double amountCrypto;
  final double priceAtTransaction;
  final DateTime createdAt;
  final String? walletAddress;

  CryptoTransaction({
    required this.id,
    required this.type,
    required this.crypto,
    required this.amountBKN,
    required this.amountCrypto,
    required this.priceAtTransaction,
    required this.createdAt,
    this.walletAddress,
  });

  factory CryptoTransaction.fromJson(Map<String, dynamic> json) {
    return CryptoTransaction(
      id: json['id'],
      type: json['type'],
      crypto: json['crypto'],
      amountBKN: json['amount_bkn']?.toDouble() ?? 0.0,
      amountCrypto: json['amount_crypto']?.toDouble() ?? 0.0,
      priceAtTransaction: json['price_at_transaction']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      walletAddress: json['wallet_address'],
    );
  }
}