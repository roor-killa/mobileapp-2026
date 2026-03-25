import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/secure_clipboard.dart';
import 'receive_screen.dart';
import 'transfer_screen.dart';
import 'swap_screen.dart';
import 'buy_screen.dart';
import 'history_screen.dart';

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
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Mes portefeuilles',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary.withOpacity(0.08),
                      AppTheme.primaryLight.withOpacity(0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () => context.read<WalletProvider>().fetch(context.read<AuthProvider>().user?.id),
          color: AppTheme.primary,
          child: Consumer<WalletProvider>(
            builder: (context, wp, _) {
              if (wp.loading && wp.wallets.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppTheme.primary),
                      SizedBox(height: 16),
                      Text('Chargement de vos portefeuilles...', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                );
              }
              if (wp.wallets.isEmpty) {
                return _EmptyWalletsState(isAuthenticated: context.read<AuthProvider>().isAuthenticated);
              }
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _PortfolioSummary(wp: wp)),
                  SliverToBoxAdapter(child: _QuickActionsBar(context: context)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Vos actifs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${wp.wallets.length} actif${wp.wallets.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final w = wp.wallets[i];
                          final price = wp.prices[w.symbol] ?? 0.0;
                          final eur = w.balance * price;
                          final change = wp.changes24h[w.symbol] ?? 0.0;
                          final color = _colors[w.symbol] ?? AppTheme.primary;
                          return _WalletCard(
                            wallet: w,
                            eurValue: eur,
                            price: price,
                            change24h: change,
                            color: color,
                            onReceive: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiveScreen())),
                            onSend: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen())),
                          );
                        },
                        childCount: wp.wallets.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: _SecurityTipCard()),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PortfolioSummary extends StatelessWidget {
  final WalletProvider wp;

  const _PortfolioSummary({required this.wp});

  @override
  Widget build(BuildContext context) {
    final total = wp.totalBalanceEur;
    final cryptoTotal = wp.totalCryptoEur;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pie_chart_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Valeur totale du portefeuille',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _fmt(total),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Chip(label: 'Crypto: ${_fmtShort(cryptoTotal)}', color: Colors.white24),
              const SizedBox(width: 8),
              _Chip(label: 'EUR: ${wp.eurBalance.toStringAsFixed(0)} €', color: Colors.white24),
            ],
          ),
        ],
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

  static String _fmtShort(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k €';
    return '${v.toStringAsFixed(0)} €';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}

class _QuickActionsBar extends StatelessWidget {
  final BuildContext context;

  const _QuickActionsBar({required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _ActionChip(icon: Icons.arrow_downward_rounded, label: 'Recevoir', color: AppTheme.accent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiveScreen()))),
          const SizedBox(width: 10),
          _ActionChip(icon: Icons.arrow_upward_rounded, label: 'Envoyer', color: AppTheme.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()))),
          const SizedBox(width: 10),
          _ActionChip(icon: Icons.swap_horiz_rounded, label: 'Swap', color: AppTheme.primaryLight, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SwapScreen()))),
          const SizedBox(width: 10),
          _ActionChip(icon: Icons.add_rounded, label: 'Acheter', color: AppTheme.accent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyScreen()))),
          const SizedBox(width: 10),
          _ActionChip(icon: Icons.history_rounded, label: 'Historique', color: AppTheme.textSecondary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final Wallet wallet;
  final double eurValue;
  final double price;
  final double change24h;
  final Color color;
  final VoidCallback onReceive;
  final VoidCallback onSend;

  const _WalletCard({
    required this.wallet,
    required this.eurValue,
    required this.price,
    required this.change24h,
    required this.color,
    required this.onReceive,
    required this.onSend,
  });

  static const _colors = {
    'ETH': Color(0xFF627EEA),
    'SOL': Color(0xFF14F195),
    'ALGO': Color(0xFF6ECFF6),
    'BTC': Color(0xFFF7931A),
  };

  @override
  Widget build(BuildContext context) {
    final isUp = change24h >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color, color.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Center(child: Text(wallet.icon, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(wallet.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('${price.toStringAsFixed(2)} €', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isUp ? AppTheme.accent : AppTheme.error).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${isUp ? '+' : ''}${change24h.toStringAsFixed(1)}%',
                                  style: TextStyle(color: isUp ? AppTheme.accent : AppTheme.error, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${wallet.balance.toStringAsFixed(4)} ${wallet.symbol}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text('${eurValue.toStringAsFixed(2)} €', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fingerprint_rounded, color: AppTheme.textSecondary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _shorten(wallet.address),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontFamily: 'monospace'),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await secureCopy(context, wallet.address, logDescription: 'Adresse ${wallet.symbol} copiée');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Adresse ${wallet.symbol} copiée'),
                              backgroundColor: AppTheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.copy_rounded, color: AppTheme.primary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _WalletBtn(icon: Icons.arrow_downward_rounded, label: 'Recevoir', color: AppTheme.accent, onTap: onReceive),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WalletBtn(icon: Icons.arrow_upward_rounded, label: 'Envoyer', color: AppTheme.primary, onTap: onSend),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityTipCard extends StatelessWidget {
  const _SecurityTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_rounded, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Conseil sécurité', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  'Ne partagez jamais votre clé privée. NodEX ne vous la demandera jamais.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWalletsState extends StatelessWidget {
  final bool isAuthenticated;

  const _EmptyWalletsState({required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, size: 64, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun portefeuille',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isAuthenticated
                  ? 'Vos portefeuilles crypto apparaîtront ici. Vérifiez que le backend est démarré et actualisez.'
                  : 'Vos portefeuilles crypto apparaîtront ici après votre inscription. Connectez-vous pour les voir.',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.read<WalletProvider>().fetch(context.read<AuthProvider>().user?.id),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
