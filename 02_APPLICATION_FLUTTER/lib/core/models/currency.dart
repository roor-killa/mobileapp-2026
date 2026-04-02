class CurrencyConversion {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double rate;
  final DateTime timestamp;

  CurrencyConversion({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.rate,
    required this.timestamp,
  });

  double get convertedAmount => amount * rate;
}

final Map<String, String> currencySymbols = {
  'EUR': '€',
  'USD': '\$',
  'GBP': '£',
  'CAD': 'C\$',
  'XAF': 'Fr',
};

final Map<String, double> exchangeRates = {
  'EUR_USD': 1.09,
  'EUR_GBP': 0.87,
  'EUR_CAD': 1.48,
  'EUR_XAF': 655.96,
  'USD_EUR': 0.92,
  'USD_GBP': 0.80,
  'USD_CAD': 1.35,
  'USD_XAF': 602.00,
  'GBP_EUR': 1.15,
  'GBP_USD': 1.25,
  'GBP_CAD': 1.69,
  'GBP_XAF': 752.00,
  'CAD_EUR': 0.68,
  'CAD_USD': 0.74,
  'CAD_GBP': 0.59,
  'CAD_XAF': 443.00,
  'XAF_EUR': 0.00152,
  'XAF_USD': 0.00166,
  'XAF_GBP': 0.00133,
  'XAF_CAD': 0.00226,
};
