import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/design_system.dart';

/// Écran Analytiques (style Figma AnalyticsScreen).
/// Sélecteur de période, résumé revenus/dépenses, répartition par catégorie.
class AnalyticsScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Account> accounts;

  const AnalyticsScreen({super.key, this.transactions = const [], this.accounts = const []});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _periodIndex = 2; // 3M par défaut
  static const List<String> _periods = ['1W', '1M', '3M', '6M', '1Y'];

  @override
  Widget build(BuildContext context) {
    final ids = widget.accounts.map((a) => a.id).toSet();
    double income = 0;
    double expense = 0;
    for (final t in widget.transactions) {
      final inRange = _isInPeriod(t.transactionDate);
      if (!inRange) continue;
      final isIncoming = t.toAccountId != null && ids.contains(t.toAccountId) && !ids.contains(t.fromAccountId);
      final isOutgoing = ids.contains(t.fromAccountId) && (t.toAccountId == null || !ids.contains(t.toAccountId));
      if (isIncoming) income += t.amount;
      if (isOutgoing) expense += t.amount;
    }

    // Catégories simulées à partir des libellés (ou valeurs par défaut)
    final categories = _buildCategories();

    return Scaffold(
      backgroundColor: DesignSystem.gray100,
      appBar: AppBar(
        title: const Text('Analytiques'),
        backgroundColor: DesignSystem.gray100,
        foregroundColor: DesignSystem.gray900,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space24, vertical: DesignSystem.space16),
        children: [
          // Sélecteur de période
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: DesignSystem.gray200,
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            ),
            child: Row(
              children: List.generate(_periods.length, (i) {
                final isActive = _periodIndex == i;
                return Expanded(
                  child: Material(
                    color: isActive ? DesignSystem.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                    child: InkWell(
                      onTap: () => setState(() => _periodIndex = i),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          _periods[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? DesignSystem.indigo600 : DesignSystem.gray500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: DesignSystem.space24),

          // Cartes résumé
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(DesignSystem.space16),
                  decoration: BoxDecoration(
                    color: DesignSystem.indigo600,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Revenus', style: TextStyle(fontSize: 11, color: DesignSystem.indigo200)),
                      const SizedBox(height: 4),
                      Text(
                        '${income.toStringAsFixed(2)} €',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Text('Sur la période', style: TextStyle(fontSize: 11, color: DesignSystem.green300)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(DesignSystem.space16),
                  decoration: BoxDecoration(
                    color: DesignSystem.gray50,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dépenses', style: TextStyle(fontSize: 11, color: DesignSystem.gray500)),
                      const SizedBox(height: 4),
                      Text(
                        '${expense.toStringAsFixed(2)} €',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DesignSystem.gray900),
                      ),
                      Text('Sur la période', style: TextStyle(fontSize: 11, color: DesignSystem.red500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.space24),

          // Encart Revenus vs Dépenses (placeholder sans graphique)
          Container(
            padding: const EdgeInsets.all(DesignSystem.space16),
            decoration: BoxDecoration(
              color: DesignSystem.gray50,
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revenus vs Dépenses', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DesignSystem.gray700)),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: DesignSystem.indigo600, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Revenus', style: TextStyle(fontSize: 11, color: DesignSystem.gray500)),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Row(
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: DesignSystem.red500, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Dépenses', style: TextStyle(fontSize: 11, color: DesignSystem.gray500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignSystem.space24),

          // Dépenses par catégorie
          Text('Dépenses par catégorie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DesignSystem.gray700)),
          const SizedBox(height: 12),
          ...categories.map((c) {
            final pct = c['pct'] as double;
            final amount = c['amount'] as double;
            final name = c['name'] as String;
            final color = c['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: TextStyle(fontSize: 13, color: DesignSystem.gray600)),
                      Text('${amount.toStringAsFixed(2)} €', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesignSystem.gray800)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: DesignSystem.gray200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isInPeriod(DateTime date) {
    final now = DateTime.now();
    switch (_periodIndex) {
      case 0:
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case 1:
        return date.isAfter(DateTime(now.year, now.month - 1, now.day));
      case 2:
        return date.isAfter(DateTime(now.year, now.month - 3, now.day));
      case 3:
        return date.isAfter(DateTime(now.year, now.month - 6, now.day));
      case 4:
        return date.isAfter(DateTime(now.year - 1, now.month, now.day));
      default:
        return true;
    }
  }

  List<Map<String, dynamic>> _buildCategories() {
    final ids = widget.accounts.map((a) => a.id).toSet();
    final out = widget.transactions.where((t) => ids.contains(t.fromAccountId) && (t.toAccountId == null || !ids.contains(t.toAccountId))).toList();
    final byDesc = <String, double>{};
    for (final t in out) {
      if (!_isInPeriod(t.transactionDate)) continue;
      final key = t.description.isEmpty ? 'Autre' : (t.description.length > 20 ? '${t.description.substring(0, 20)}...' : t.description);
      byDesc[key] = (byDesc[key] ?? 0) + t.amount;
    }
    final total = byDesc.values.fold<double>(0, (a, b) => a + b);
    if (total == 0) {
      return [
        {'name': 'Virements', 'amount': 0.0, 'pct': 0.2, 'color': DesignSystem.gray400},
        {'name': 'Prélèvements', 'amount': 0.0, 'pct': 0.15, 'color': DesignSystem.gray500},
        {'name': 'Autres', 'amount': 0.0, 'pct': 0.1, 'color': DesignSystem.gray600},
      ];
    }
    final colors = [const Color(0xFFf59e0b), DesignSystem.red500, const Color(0xFF3b82f6), const Color(0xFF8b5cf6), DesignSystem.green500];
    int i = 0;
    return byDesc.entries.map((e) {
      final pct = total > 0 ? (e.value / total) : 0.0;
      return {
        'name': e.key,
        'amount': e.value,
        'pct': pct,
        'color': colors[i++ % colors.length],
      };
    }).toList()
      ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
  }
}
