import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import 'receive_screen.dart';
import 'transfer_screen.dart';
import 'swap_screen.dart';
import 'buy_screen.dart';
import 'bank_transfer_screen.dart';
import 'notifications_screen.dart';
import '../widgets/nodex_spotlight_carousel.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/analog_clock.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<WalletProvider>().fetch(context.read<AuthProvider>().user?.id),
          color: AppTheme.primary,
          child: Consumer2<WalletProvider, AuthProvider>(
            builder: (context, wp, auth, _) {
              if (wp.loading && wp.wallets.isEmpty) {
                return const DashboardLoadingSkeleton();
              }
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  _Header(userName: _displayName(auth.user?.name, auth.user?.email)),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: NodexSpotlightCarousel(),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: AppTheme.card.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6, right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.schedule_rounded, color: AppTheme.primary, size: 22),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Heure locale',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Horloge analogique sur votre fuseau : cadran, aiguilles et heure numérique.',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary.withValues(alpha: 0.92),
                                      fontSize: 12.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const AnalogClock(size: 108),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                _BalanceSection(total: wp.totalBalanceEur),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _MiniBalance(label: 'Euros', value: '${wp.eurBalance.toStringAsFixed(2)} \u20AC', icon: Icons.euro_rounded, color: AppTheme.accent),
                      const SizedBox(width: 10),
                      _MiniBalance(label: 'Crypto', value: '${wp.totalCryptoEur.toStringAsFixed(2)} \u20AC', icon: Icons.currency_bitcoin_rounded, color: AppTheme.primaryLight),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _QuickActions(),
                  const SizedBox(height: 28),
                  _SectionTitle(title: 'Vos actifs'),
                  const SizedBox(height: 8),
                  ...wp.wallets.map((w) {
                    final price = wp.prices[w.symbol] ?? 0.0;
                    final change = wp.changes24h[w.symbol] ?? 0.0;
                    final eur = w.balance * price;
                    return _AssetTile(wallet: w, eurValue: eur, price: price, change24h: change);
                  }),
                  const SizedBox(height: 28),
                  _SectionTitle(title: 'Dernières transactions'),
                  const SizedBox(height: 8),
                  if (wp.transactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 48, color: AppTheme.textSecondary.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            const Text('Aucune transaction', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('Vos opérations apparaîtront ici', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.8), fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...wp.transactions.take(5).map((t) => _TransactionTile(tx: t)),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

String _getGreeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Bonjour';
  if (h < 18) return 'Bonne journée';
  return 'Bonsoir';
}

String _displayName(String? name, String? email) {
  final n = name?.trim() ?? '';
  if (n.isNotEmpty) return n;
  final parts = email?.split('@');
  if (parts != null && parts.isNotEmpty && parts.first.trim().isNotEmpty) return parts.first.trim();
  return 'Utilisateur';
}

class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.brandIconGradient,
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Text(
                (userName.trim().isNotEmpty ? userName.trim()[0] : '?').toUpperCase(),
                style: const TextStyle(color: Color(0xFF042028), fontWeight: FontWeight.w800, fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(userName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
              boxShadow: AppTheme.cardShadow,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryLight),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  final double total;
  const _BalanceSection({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          gradient: AppTheme.heroGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.cardShadowStrong,
        ),
        child: Column(
          children: [
            const Text('Solde total', style: TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              _fmt(total),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            const Text('EUR', style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  static String _fmt(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final dec = parts[1];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('\u202F');
      buf.write(intPart[i]);
    }
    return '${buf.toString()},$dec\u00A0\u20AC';
  }
}

class _MiniBalance extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MiniBalance({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)), boxShadow: AppTheme.cardShadow),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _ActionBtn(icon: Icons.arrow_downward_rounded, label: 'Recevoir', color: AppTheme.accent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiveScreen()))),
          const SizedBox(width: 10),
          _ActionBtn(icon: Icons.arrow_upward_rounded, label: 'Envoyer', color: AppTheme.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()))),
          const SizedBox(width: 10),
          _ActionBtn(icon: Icons.swap_horiz_rounded, label: 'Swap', color: AppTheme.primaryLight, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SwapScreen()))),
          const SizedBox(width: 10),
          _ActionBtn(icon: Icons.add_rounded, label: 'Acheter', color: AppTheme.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyScreen()))),
          const SizedBox(width: 10),
          _ActionBtn(icon: Icons.account_balance_rounded, label: 'Virement', color: AppTheme.primaryLight, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankTransferScreen()))),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Material(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Icon(icon, color: color, size: 26),
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.primary, AppTheme.primaryLight]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.3)),
        ],
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final Wallet wallet;
  final double eurValue;
  final double price;
  final double change24h;
  const _AssetTile({required this.wallet, required this.eurValue, required this.price, required this.change24h});

  static const _colors = {
    'ETH': Color(0xFF627EEA),
    'SOL': Color(0xFF14F195),
    'ALGO': Color(0xFF6ECFF6),
    'BTC': Color(0xFFF7931A),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[wallet.symbol] ?? AppTheme.primary;
    final isUp = change24h >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border.withValues(alpha: 0.35)),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(wallet.icon, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wallet.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text('${price.toStringAsFixed(2)} \u20AC', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(
                        '${isUp ? '+' : ''}${change24h.toStringAsFixed(1)}%',
                        style: TextStyle(color: isUp ? AppTheme.accent : AppTheme.error, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${wallet.balance.toStringAsFixed(4)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 15)),
                const SizedBox(height: 2),
                Text('${eurValue.toStringAsFixed(2)} \u20AC', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isSend = tx.type == 'send' || tx.type == 'bank_send';
    final color = isSend ? AppTheme.error : AppTheme.accent;
    final icon = tx.type == 'bank_send' || tx.type == 'bank_receive'
        ? Icons.account_balance_rounded
        : (isSend ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded);
    final sign = tx.amount >= 0 ? '+' : '';
    final now = DateTime.now();
    final diff = now.difference(tx.date);
    String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      timeAgo = 'Il y a ${diff.inHours}h';
    } else {
      timeAgo = 'Il y a ${diff.inDays}j';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border.withValues(alpha: 0.35)),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.description, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(timeAgo, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Text(
              '$sign${tx.symbol == 'EUR' ? tx.amount.toStringAsFixed(2) : tx.amount.toStringAsFixed(4)} ${tx.symbol == 'EUR' ? '\u20AC' : tx.symbol}',
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
