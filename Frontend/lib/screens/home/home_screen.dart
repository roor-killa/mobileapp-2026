import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';
import 'send/send_screen.dart';
import 'recharge/recharge_screen.dart';
import 'history/history_screen.dart';
import 'qrcode/qrcode_screen.dart';
import 'chatbot/chatbot_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    _DashboardTab(onTabChange: _goToTab),
    const SendScreen(),
    const RechargeScreen(),
    const HistoryScreen(),
    const QrCodeScreen(),
    const ChatbotScreen(),
  ];

  void _goToTab(int index) => setState(() => _currentIndex = index);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.send_outlined),
              activeIcon: Icon(Icons.send),
              label: 'Envoyer'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_card_outlined),
              activeIcon: Icon(Icons.add_card),
              label: 'Recharge'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Historique'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_outlined),
              activeIcon: Icon(Icons.qr_code),
              label: 'QR Code'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              activeIcon: Icon(Icons.smart_toy),
              label: 'Assistant'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person_outline, color: Colors.white),
            )
          : null,
    );
  }
}

// ─── Onglet Dashboard ────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final void Function(int) onTabChange;
  const _DashboardTab({required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final txProvider = context.watch<TransactionProvider>();
    final recent = txProvider.transactions.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final auth = context.read<AuthProvider>();
            final tx   = context.read<TransactionProvider>();
            await auth.refreshUser();
            await tx.loadHistory();
          },
          child: CustomScrollView(
            slivers: [
              // ─── Header ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  decoration: const BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Bonjour,',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              Text(
                                user?.firstName ?? '—',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Text(
                              user != null
                                  ? '${user.firstName[0]}${user.lastName[0]}'
                                  : '?',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text('Solde disponible',
                          style:
                              TextStyle(color: Colors.white60, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        user?.balanceFormatted ?? '— €',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Actions rapides ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Actions rapides',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _QuickAction(
                            icon: Icons.send_rounded,
                            label: 'Envoyer',
                            color: AppColors.primary,
                            onTap: () => onTabChange(1),
                          ),
                          _QuickAction(
                            icon: Icons.add_card,
                            label: 'Recharger',
                            color: AppColors.secondary,
                            onTap: () => onTabChange(2),
                          ),
                          _QuickAction(
                            icon: Icons.qr_code_2,
                            label: 'QR Code',
                            color: AppColors.warning,
                            onTap: () => onTabChange(4),
                          ),
                          _QuickAction(
                            icon: Icons.history,
                            label: 'Historique',
                            color: AppColors.success,
                            onTap: () => onTabChange(3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Dernières transactions ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dernières transactions',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                      if (txProvider.transactions.isNotEmpty)
                        TextButton(
                          onPressed: () {},
                          child: const Text('Voir tout'),
                        ),
                    ],
                  ),
                ),
              ),

              if (recent.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('Aucune transaction',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _MiniTransactionTile(tx: recent[i]),
                    childCount: recent.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MiniTransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const _MiniTransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDebit = tx.isDebit;
    final color   = isDebit ? AppColors.error : AppColors.success;
    final sign    = isDebit ? '- ' : '+ ';
    final counterpart = tx.counterpart?['full_name'] ?? tx.typeLabel;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(counterpart,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(tx.typeLabel,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '$sign${tx.amountFormatted}',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
