import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/history/history_page.dart';
import '../features/qr/qr_page.dart';
import '../features/chatbot/chatbot_page.dart';
import '../features/profile/profile_page.dart';
import '../providers/dashboard_provider.dart';
import '../providers/transaction_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final _pages = const [
    DashboardPage(),
    HistoryPage(),
    QrPage(),
    ChatbotPage(),
    ProfilePage(),
  ];

  void _onTabTap(int i) {
    // Rafraîchir dashboard et historique à chaque sélection
    if (i == 0) {
      context.read<DashboardProvider>().loadDashboard();
    } else if (i == 1) {
      context.read<TransactionProvider>().loadTransactions(refresh: true);
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _BottomNav(
        currentIndex: _index,
        onTap: _onTabTap,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded,        label: 'Accueil',   index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.history_rounded,     label: 'Historique',index: 1, current: currentIndex, onTap: onTap),
              _QrCenter(isActive: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.chat_bubble_rounded, label: 'Chatbot',   index: 3, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.person_rounded,      label: 'Profil',    index: 4, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon, required this.label, required this.index,
    required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha:0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppColors.primary : AppColors.textHint, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: active ? AppColors.primary : AppColors.textHint,
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _QrCenter extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  const _QrCenter({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.qr_code_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}
