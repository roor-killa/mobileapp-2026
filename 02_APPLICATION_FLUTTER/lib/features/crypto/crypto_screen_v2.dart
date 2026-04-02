import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import '../../core/constants/colors.dart';
import '../../core/models/crypto.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({Key? key}) : super(key: key);

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  late List<CryptoAsset> _cryptoAssets;
  late List<CryptoPortfolio> _portfolio;
  late Timer _priceTimer;
  String _selectedTimeframe = '1J';
  bool _isBuyMode = true;
  final _amountController = TextEditingController();
  double _mainBalance = 15000;

  @override
  void initState() {
    super.initState();
    _initializeCryptos();
    _portfolio = [
      CryptoPortfolio(symbol: 'BTC', quantity: 0.5, purchasePrice: 42000),
      CryptoPortfolio(symbol: 'ETH', quantity: 5, purchasePrice: 2200),
      CryptoPortfolio(symbol: 'SOL', quantity: 50, purchasePrice: 100),
    ];
    _startPriceUpdates();
  }

  void _initializeCryptos() {
    _cryptoAssets = [
      CryptoAsset(
        symbol: 'BTC',
        name: 'Bitcoin',
        emoji: '₿',
        currentPrice: 42500,
        priceHistory: List.generate(20, (i) => 41000 + (i * 75).toDouble()),
        changePercent24h: 3.5,
        high24h: 43200,
        low24h: 41000,
      ),
      CryptoAsset(
        symbol: 'ETH',
        name: 'Ethereum',
        emoji: 'Ξ',
        currentPrice: 2250,
        priceHistory: List.generate(20, (i) => 2100 + (i * 7.5).toDouble()),
        changePercent24h: 2.8,
        high24h: 2300,
        low24h: 2100,
      ),
      CryptoAsset(
        symbol: 'SOL',
        name: 'Solana',
        emoji: '◎',
        currentPrice: 105,
        priceHistory: List.generate(20, (i) => 95 + (i * 0.5).toDouble()),
        changePercent24h: 4.2,
        high24h: 110,
        low24h: 95,
      ),
      CryptoAsset(
        symbol: 'BNB',
        name: 'Binance',
        emoji: '⬡',
        currentPrice: 620,
        priceHistory: List.generate(20, (i) => 580 + (i * 2).toDouble()),
        changePercent24h: -1.5,
        high24h: 650,
        low24h: 580,
      ),
      CryptoAsset(
        symbol: 'ADA',
        name: 'Cardano',
        emoji: '⧫',
        currentPrice: 0.98,
        priceHistory: List.generate(20, (i) => 0.85 + (i * 0.0065).toDouble()),
        changePercent24h: 5.1,
        high24h: 1.05,
        low24h: 0.85,
      ),
      CryptoAsset(
        symbol: 'DOGE',
        name: 'Dogecoin',
        emoji: '🐕',
        currentPrice: 0.42,
        priceHistory: List.generate(20, (i) => 0.38 + (i * 0.0021).toDouble()),
        changePercent24h: -2.3,
        high24h: 0.45,
        low24h: 0.38,
      ),
    ];
  }

  void _startPriceUpdates() {
    _priceTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        for (var asset in _cryptoAssets) {
          final variation = (DateTime.now().millisecond / 1000 - 0.5) * 0.02;
          asset.currentPrice *= (1 + variation);
          asset.priceHistory.add(asset.currentPrice);
          if (asset.priceHistory.length > 100) {
            asset.priceHistory.removeAt(0);
          }
          asset.changePercent24h =
              ((asset.currentPrice - asset.priceHistory.first) /
                  asset.priceHistory.first) *
              100;
        }
      });
    });
  }

  void _showTradeDialog(CryptoAsset asset) {
    _amountController.clear();
    showModalBottomSheet(
      context: context,
      backgroundColor: NEGsColors.bgWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isBuyMode ? 'Acheter' : 'Vendre',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isBuyMode = true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isBuyMode
                              ? Colors.green
                              : NEGsColors.bgSecondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Acheter',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isBuyMode = false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: !_isBuyMode
                              ? Colors.red
                              : NEGsColors.bgSecondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Vendre',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Montant (€)'),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '100',
                  filled: true,
                  fillColor: NEGsColors.bgSecondaryLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NEGsColors.bgSecondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Résumé'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Montant'),
                        Text(
                          '${_amountController.text}€',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Frais (0.5%)'),
                        Text(
                          '${(double.tryParse(_amountController.text) ?? 0) * 0.005}€',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Crypto reçue'),
                        Text(
                          '${((double.tryParse(_amountController.text) ?? 0) / asset.currentPrice).toStringAsFixed(4)} ${asset.symbol}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: NEGsGradients.mainGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(_amountController.text);
                      if (amount == null || amount <= 0) return;

                      if (_isBuyMode) {
                        final fees = amount * 0.005;
                        if (_mainBalance >= (amount + fees)) {
                          setState(() {
                            _mainBalance -= (amount + fees);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Achat confirmé ✓'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        setState(() {
                          _mainBalance += amount * 0.995;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vente confirmée ✓'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isBuyMode ? 'Acheter' : 'Vendre',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCrypto = _cryptoAssets[0];
    final chartData = selectedCrypto.priceHistory;

    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crypto',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              // Solde principal
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NEGsColors.bgWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NEGsColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solde',
                      style: TextStyle(
                        fontSize: 12,
                        color: NEGsColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '€${_mainBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: NEGsColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Crypto list horizontal scroll
              const Text(
                'Cryptos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cryptoAssets.length,
                  itemBuilder: (context, index) {
                    final crypto = _cryptoAssets[index];
                    final isGain = crypto.isGain;
                    return GestureDetector(
                      onTap: () => _showTradeDialog(crypto),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: NEGsColors.bgWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: NEGsColors.borderLight),
                        ),
                        width: 140,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  crypto.emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                Text(
                                  crypto.symbol,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '€${crypto.currentPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${crypto.changePercent24h?.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isGain ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Chart section
              const Text(
                'Graphique',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NEGsColors.bgWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NEGsColors.borderLight),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (int i = 0; i < chartData.length; i++)
                                  FlSpot(i.toDouble(), chartData[i]),
                              ],
                              isCurved: true,
                              color: selectedCrypto.isGain
                                  ? NEGsColors.primaryCyan
                                  : Colors.red,
                              barWidth: 2,
                              belowBarData: BarAreaData(
                                show: true,
                                color:
                                    (selectedCrypto.isGain
                                            ? NEGsColors.primaryCyan
                                            : Colors.red)
                                        .withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: ['1H', '1J', '1S', '1M', '1A'].map((timeframe) {
                        final isSelected = _selectedTimeframe == timeframe;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedTimeframe = timeframe),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NEGsColors.primaryCyan
                                  : NEGsColors.bgSecondaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              timeframe,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : NEGsColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 24h stats
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '24h Haut',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '€${selectedCrypto.high24h?.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '24h Bas',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '€${selectedCrypto.low24h?.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Portefeuille
              const Text(
                'Mon Portefeuille',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _portfolio.length,
                itemBuilder: (context, index) {
                  final holding = _portfolio[index];
                  final crypto = _cryptoAssets.firstWhere(
                    (c) => c.symbol == holding.symbol,
                  );
                  final value = holding.value;
                  final gain =
                      (crypto.currentPrice - holding.purchasePrice) *
                      holding.quantity;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: NEGsColors.bgWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: NEGsColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Text(
                          crypto.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                holding.symbol,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${holding.quantity} ${holding.symbol}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: NEGsColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '€${value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              gain >= 0
                                  ? '+€${gain.toStringAsFixed(2)}'
                                  : '-€${gain.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: gain >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _priceTimer.cancel();
    _amountController.dispose();
    super.dispose();
  }
}
