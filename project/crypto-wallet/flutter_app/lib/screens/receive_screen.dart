import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../app_theme.dart';
import '../providers/wallet_provider.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  int _selectedIndex = 0;

  static const _colors = {
    'ETH': Color(0xFF627EEA),
    'SOL': Color(0xFF14F195),
    'ALGO': Color(0xFF6ECFF6),
    'BTC': Color(0xFFF7931A),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recevoir')),
      body: Consumer<WalletProvider>(
        builder: (context, wp, _) {
          if (wp.wallets.isEmpty) {
            return const Center(child: Text('Aucun portefeuille', style: TextStyle(color: AppTheme.textSecondary)));
          }
          final w = wp.wallets[_selectedIndex];
          final color = _colors[w.symbol] ?? AppTheme.primary;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: wp.wallets.asMap().entries.map((entry) {
                      final i = entry.key;
                      final wallet = entry.value;
                      final selected = i == _selectedIndex;
                      final c = _colors[wallet.symbol] ?? AppTheme.primary;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(wallet.symbol),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedIndex = i),
                          selectedColor: c.withOpacity(0.2),
                          backgroundColor: AppTheme.card,
                          labelStyle: TextStyle(color: selected ? c : AppTheme.textSecondary, fontWeight: FontWeight.w600),
                          side: BorderSide(color: selected ? c : AppTheme.border),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: QrImageView(data: w.address, version: QrVersions.auto, size: 200),
                ),
                const SizedBox(height: 24),
                Text(w.name, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(w.address, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis, maxLines: 2),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: w.address));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Adresse ${w.symbol} copiée'), backgroundColor: AppTheme.primary),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.copy_rounded, color: AppTheme.primary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Envoyez uniquement du ${w.symbol} (${w.name}) à cette adresse. Tout autre token sera perdu.',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: w.address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Adresse ${w.symbol} copiée'), backgroundColor: AppTheme.primary),
                      );
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Partager l\'adresse'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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
