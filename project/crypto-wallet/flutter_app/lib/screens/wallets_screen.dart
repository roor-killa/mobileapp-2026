import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/wallet_provider.dart';
import 'receive_screen.dart';
import 'transfer_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  static const _colors = {
    'ETH': Color(0xFF627EEA),
    'SOL': Color(0xFF14F195),
    'ALGO': Color(0xFF6ECFF6),
    'BTC': Color(0xFFF7931A),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallets')),
      body: RefreshIndicator(
        onRefresh: () => context.read<WalletProvider>().fetch(),
        color: AppTheme.primary,
        child: Consumer<WalletProvider>(
          builder: (context, wp, _) {
            if (wp.loading && wp.wallets.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            }
            if (wp.wallets.isEmpty) {
              return ListView(children: const [SizedBox(height: 200), Center(child: Text('Aucun portefeuille', style: TextStyle(color: AppTheme.textSecondary)))]);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: wp.wallets.length,
              itemBuilder: (context, i) {
                final w = wp.wallets[i];
                final price = wp.prices[w.symbol] ?? 0.0;
                final eur = w.balance * price;
                final change = wp.changes24h[w.symbol] ?? 0.0;
                final color = _colors[w.symbol] ?? AppTheme.primary;
                final isUp = change >= 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                            child: Center(child: Text(w.icon, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(w.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 17)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text('${price.toStringAsFixed(2)} \u20AC', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${isUp ? '+' : ''}${change.toStringAsFixed(1)}%',
                                      style: TextStyle(color: isUp ? const Color(0xFF10B981) : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${w.balance.toStringAsFixed(4)} ${w.symbol}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                              const SizedBox(height: 2),
                              Text('${eur.toStringAsFixed(2)} \u20AC', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.key_rounded, color: AppTheme.textSecondary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _shorten(w.address),
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontFamily: 'monospace'),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: w.address));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Adresse ${w.symbol} copiée'), backgroundColor: AppTheme.primary, duration: const Duration(seconds: 2)),
                                );
                              },
                              child: const Icon(Icons.copy_rounded, color: AppTheme.primary, size: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _WalletBtn(icon: Icons.arrow_downward_rounded, label: 'Recevoir', color: const Color(0xFF10B981), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiveScreen()))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _WalletBtn(icon: Icons.arrow_upward_rounded, label: 'Envoyer', color: AppTheme.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()))),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static String _shorten(String addr) {
    if (addr.length <= 16) return addr;
    return '${addr.substring(0, 8)}\u2026${addr.substring(addr.length - 8)}';
  }
}

class _WalletBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _WalletBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
