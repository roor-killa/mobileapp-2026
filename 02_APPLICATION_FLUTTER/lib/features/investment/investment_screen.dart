import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_text.dart';
import '../../models/investment_model.dart';

class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final investments = InvestmentModel.mockInvestments;
    final totalInvested = investments.fold<double>(
      0,
      (sum, inv) => sum + inv.totalInvested,
    );
    final totalValue = investments.fold<double>(
      0,
      (sum, inv) => sum + inv.currentValue,
    );
    final totalProfit = totalValue - totalInvested;

    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientText('Investments', style: NEGsStyles.heading2),
              const SizedBox(height: 28),
              _buildPortfolioCard(totalInvested, totalValue, totalProfit),
              const SizedBox(height: 32),
              const Text(
                'Your Portfolio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...investments.map((inv) => _buildInvestmentItem(inv)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioCard(double invested, double value, double profit) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Value',
            style: TextStyle(
              color: NEGsColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text('\$${value.toStringAsFixed(2)}', style: NEGsStyles.largePrice),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Invested', '\$${invested.toStringAsFixed(2)}'),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.1),
              ),
              _buildStatColumn(
                'Profit',
                '\$${profit.toStringAsFixed(2)}',
                color: profit >= 0 ? Colors.green : Colors.red,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.1),
              ),
              _buildStatColumn(
                'Return',
                '${((profit / invested) * 100).toStringAsFixed(2)}%',
                color: profit >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: NEGsColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? NEGsColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentItem(InvestmentModel inv) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.name,
                      style: const TextStyle(
                        color: NEGsColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${inv.quantity} shares @ \$${inv.investedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: NEGsColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${inv.currentValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: NEGsColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${inv.isProfit ? '+' : ''}\$${inv.profit.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: inv.isProfit ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (inv.currentValue / (inv.totalInvested * 1.5)).clamp(
                    0.0,
                    1.0,
                  ),
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(
                    inv.isProfit ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${inv.profitPercent.toStringAsFixed(2)}% ${inv.isProfit ? 'gain' : 'loss'}',
              style: TextStyle(
                color: inv.isProfit ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
