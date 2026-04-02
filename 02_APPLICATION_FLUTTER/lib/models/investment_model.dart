class InvestmentModel {
  final String id;
  final String name;
  final String symbol;
  final double amount;
  final double investedPrice;
  final double currentPrice;
  final int quantity;
  final String type;

  InvestmentModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.investedPrice,
    required this.currentPrice,
    required this.quantity,
    required this.type,
  });

  double get totalInvested => investedPrice * quantity;
  double get currentValue => currentPrice * quantity;
  double get profit => currentValue - totalInvested;
  double get profitPercent => (profit / totalInvested * 100);
  bool get isProfit => profit > 0;

  static List<InvestmentModel> mockInvestments = [
    InvestmentModel(
      id: '1',
      name: 'Tesla',
      symbol: 'TSLA',
      amount: 5000,
      investedPrice: 250,
      currentPrice: 285,
      quantity: 20,
      type: 'stock',
    ),
    InvestmentModel(
      id: '2',
      name: 'Apple',
      symbol: 'AAPL',
      amount: 3000,
      investedPrice: 150,
      currentPrice: 165,
      quantity: 20,
      type: 'stock',
    ),
    InvestmentModel(
      id: '3',
      name: 'S&P 500 ETF',
      symbol: 'SPY',
      amount: 10000,
      investedPrice: 450,
      currentPrice: 475,
      quantity: 22,
      type: 'etf',
    ),
    InvestmentModel(
      id: '4',
      name: 'Microsoft',
      symbol: 'MSFT',
      amount: 4000,
      investedPrice: 380,
      currentPrice: 405,
      quantity: 10,
      type: 'stock',
    ),
  ];
}
