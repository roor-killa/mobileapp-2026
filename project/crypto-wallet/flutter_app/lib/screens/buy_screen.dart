import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/wallet_provider.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final _amount = TextEditingController(text: '100');
  int _selectedIndex = 0;
  final _presets = [50, 100, 200, 500, 1000];

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acheter')),
      body: Consumer<WalletProvider>(
        builder: (context, wp, _) {
          if (wp.wallets.isEmpty) {
            return const Center(child: Text('Aucun portefeuille', style: TextStyle(color: AppTheme.textSecondary)));
          }
          final w = wp.wallets[_selectedIndex];
          final price = wp.prices[w.symbol] ?? 1;
          final eurAmount = double.tryParse(_amount.text) ?? 0;
          final cryptoAmount = price > 0 ? eurAmount / price : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choisir la crypto', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: wp.wallets.asMap().entries.map((e) {
                      final selected = e.key == _selectedIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(e.value.symbol),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedIndex = e.key),
                          selectedColor: AppTheme.primary.withOpacity(0.2),
                          backgroundColor: AppTheme.card,
                          labelStyle: TextStyle(color: selected ? AppTheme.primary : AppTheme.textSecondary, fontWeight: FontWeight.w600),
                          side: BorderSide(color: selected ? AppTheme.primary : AppTheme.border),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),
                const Text('Montant en EUR', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    prefix: Text('\u20AC ', style: TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.w600)),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _presets.map((p) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: OutlinedButton(
                          onPressed: () { _amount.text = p.toString(); setState(() {}); },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text('${p}\u20AC', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Text('Vous recevrez environ', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        '${cryptoAmount.toStringAsFixed(6)} ${w.symbol}',
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('1 ${w.symbol} = ${price.toStringAsFixed(2)} \u20AC', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      _FeeRow(label: 'Frais (1.5%)', value: '${(eurAmount * 0.015).toStringAsFixed(2)} \u20AC'),
                      const Divider(color: AppTheme.border, height: 16),
                      _FeeRow(label: 'Total débité', value: '${(eurAmount * 1.015).toStringAsFixed(2)} \u20AC', bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card_rounded, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Carte bancaire', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                            Text('Visa •••• 4242', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (eurAmount <= 0) return;
                      wp.buyCrypto(w.id, eurAmount);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${cryptoAmount.toStringAsFixed(6)} ${w.symbol} acheté pour ${eurAmount.toStringAsFixed(2)} \u20AC'), backgroundColor: AppTheme.primary),
                      );
                      _amount.text = '100';
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                    child: Text('Acheter ${w.symbol}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _FeeRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
        Text(value, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }
}
