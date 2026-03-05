import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/wallet_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all';

  static const _filters = {
    'all': 'Tout',
    'send': 'Envoyés',
    'receive': 'Reçus',
    'swap': 'Échanges',
    'buy': 'Achats',
    'bank': 'Virements',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: Consumer<WalletProvider>(
        builder: (context, wp, _) {
          final filtered = wp.transactions.where((t) {
            if (_filter == 'all') return true;
            if (_filter == 'bank') return t.type == 'bank_send' || t.type == 'bank_receive';
            return t.type == _filter;
          }).toList();

          return Column(
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _filters.entries.map((e) {
                    final selected = _filter == e.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(e.value),
                        selected: selected,
                        onSelected: (_) => setState(() => _filter = e.key),
                        selectedColor: AppTheme.primary.withOpacity(0.2),
                        backgroundColor: AppTheme.card,
                        labelStyle: TextStyle(color: selected ? AppTheme.primary : AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                        side: BorderSide(color: selected ? AppTheme.primary : AppTheme.border),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Aucune transaction', style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final tx = filtered[i];
                          final prev = i > 0 ? filtered[i - 1] : null;
                          final showDate = prev == null || !_sameDay(tx.date, prev.date);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showDate) ...[
                                if (i > 0) const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(_formatDate(tx.date), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                                ),
                              ],
                              _TransactionCard(tx: tx),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (_sameDay(d, now)) return "Aujourd'hui";
    if (_sameDay(d, now.subtract(const Duration(days: 1)))) return 'Hier';
    const mois = ['', 'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return '${d.day} ${mois[d.month]} ${d.year}';
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction tx;
  const _TransactionCard({required this.tx});

  static const _typeConfig = {
    'send': {'icon': Icons.arrow_upward_rounded, 'color': Colors.redAccent, 'label': 'Envoi'},
    'receive': {'icon': Icons.arrow_downward_rounded, 'color': Color(0xFF10B981), 'label': 'Réception'},
    'swap': {'icon': Icons.swap_horiz_rounded, 'color': Color(0xFFF59E0B), 'label': 'Échange'},
    'buy': {'icon': Icons.shopping_cart_rounded, 'color': Color(0xFF3B82F6), 'label': 'Achat'},
    'bank_send': {'icon': Icons.account_balance_rounded, 'color': Colors.redAccent, 'label': 'Virement envoyé'},
    'bank_receive': {'icon': Icons.account_balance_rounded, 'color': Color(0xFF10B981), 'label': 'Virement reçu'},
  };

  @override
  Widget build(BuildContext context) {
    final conf = _typeConfig[tx.type] ?? _typeConfig['send']!;
    final icon = conf['icon'] as IconData;
    final color = conf['color'] as Color;
    final label = conf['label'] as String;
    final isNeg = tx.amount < 0;
    final sign = isNeg ? '' : '+';

    String amountText;
    if (tx.type == 'swap') {
      amountText = '${tx.amount.toStringAsFixed(4)} ${tx.symbol}';
    } else if (tx.symbol == 'EUR') {
      amountText = '$sign${tx.amount.toStringAsFixed(2)} \u20AC';
    } else {
      amountText = '$sign${tx.amount.toStringAsFixed(4)} ${tx.symbol}';
    }

    final hour = '${tx.date.hour.toString().padLeft(2, '0')}:${tx.date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    Text(hour, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    if (tx.status == 'pending') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: const Text('En cours', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amountText, style: TextStyle(color: isNeg ? Colors.redAccent : const Color(0xFF10B981), fontWeight: FontWeight.w600, fontSize: 14)),
              if (tx.eurValue != null)
                Text('${tx.eurValue!.toStringAsFixed(2)} \u20AC', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              if (tx.type == 'swap' && tx.toSymbol != null)
                Text('+${tx.toAmount?.toStringAsFixed(4)} ${tx.toSymbol}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
