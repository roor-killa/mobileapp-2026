import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_text.dart';
import '../../models/crypto_model.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({Key? key}) : super(key: key);

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  int _selectedCryptoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selectedCrypto = CryptoModel.mockCryptos[_selectedCryptoIndex];

    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientText('Crypto Market', style: NEGsStyles.heading2),
              const SizedBox(height: 28),
              _buildCryptoChart(selectedCrypto),
              const SizedBox(height: 32),
              const Text(
                'Top Cryptocurrencies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...CryptoModel.mockCryptos.asMap().entries.map((e) {
                int index = e.key;
                CryptoModel crypto = e.value;
                return _buildCryptoItem(crypto, index);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoChart(CryptoModel crypto) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(crypto.name, style: NEGsStyles.heading3),
                  const SizedBox(height: 4),
                  Text(
                    crypto.priceFormatted,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: NEGsColors.primaryCyan,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: crypto.priceChangePercent24h > 0
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${crypto.priceChangePercent24h > 0 ? '+' : ''}${crypto.priceChangePercent24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: crypto.priceChangePercent24h > 0
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: const TextStyle(
                            color: NEGsColors.textTertiary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: const TextStyle(
                            color: NEGsColors.textTertiary,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      crypto.sparklineData.length,
                      (index) =>
                          FlSpot(index.toDouble(), crypto.sparklineData[index]),
                    ),
                    isCurved: true,
                    color: NEGsColors.primaryViolet,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: NEGsColors.primaryCyan,
                          strokeColor: NEGsColors.primaryViolet,
                          strokeWidth: 2,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: NEGsColors.primaryViolet.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Market Cap', crypto.marketCapFormatted),
              _buildStatItem('24h Volume', crypto.volume24hFormatted),
              _buildStatItem('Symbol', crypto.symbol),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: NEGsColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: NEGsColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoItem(CryptoModel crypto, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        onTap: () => setState(() => _selectedCryptoIndex = index),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: NEGsGradients.mainGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(crypto.image, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crypto.name,
                    style: const TextStyle(
                      color: NEGsColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    crypto.symbol,
                    style: const TextStyle(
                      color: NEGsColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crypto.priceFormatted,
                  style: const TextStyle(
                    color: NEGsColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${crypto.priceChangePercent24h > 0 ? '+' : ''}${crypto.priceChangePercent24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: crypto.priceChangePercent24h > 0
                        ? Colors.green
                        : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
