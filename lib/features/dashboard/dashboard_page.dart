import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/transaction_card.dart';
import '../transfer/transfer_page.dart';
import '../recharge/recharge_page.dart';
import '../history/history_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final dash  = context.watch<DashboardProvider>();
    final user  = auth.user;
    final fmt   = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().loadDashboard(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── AppBar ────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(gradient: AppColors.balanceGradient),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Salutation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bonjour,',
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                                  Text(user?.firstName ?? '...',
                                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              // Notifications
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                      onPressed: () {},
                                    ),
                                  ),
                                  if (dash.unreadNotifications > 0)
                                    Positioned(
                                      right: 8, top: 8,
                                      child: Container(
                                        width: 10, height: 10,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Solde
                          const Text('Solde disponible',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _balanceVisible
                                    ? fmt.format(user?.balance ?? 0)
                                    : '••••••',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                                child: Icon(
                                  _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: Colors.white70, size: 22,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Actions rapides ────────────────────────────────────
                    Row(
                      children: [
                        _QuickAction(
                          icon: Icons.send_rounded,
                          label: 'Envoyer',
                          color: AppColors.primary,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const TransferPage())),
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: Icons.add_card_rounded,
                          label: 'Recharger',
                          color: AppColors.secondary,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const RechargePage())),
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: Icons.receipt_long_rounded,
                          label: 'Historique',
                          color: AppColors.accent,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const HistoryPage())),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Stats du mois ──────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Envoyé ce mois',
                            amount: dash.totalSent,
                            color: AppColors.error,
                            icon: Icons.arrow_upward_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Reçu ce mois',
                            amount: dash.totalReceived,
                            color: AppColors.success,
                            icon: Icons.arrow_downward_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Transactions récentes ──────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Transactions récentes',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const HistoryPage())),
                          child: const Text('Voir tout',
                              style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (dash.isLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    else if (dash.recentTransactions.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textHint),
                              SizedBox(height: 12),
                              Text('Aucune transaction',
                                  style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...dash.recentTransactions.map((t) => TransactionCard(transaction: t)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bouton action rapide ────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Carte stat mensuelle ────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.amount, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fmt.format(amount),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
