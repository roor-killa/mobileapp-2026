import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'panache_theme.dart';
import 'widgets/animated_dot_indicator.dart';
import 'widgets/futuristic_background.dart';
import 'providers/auth_provider.dart';
import 'providers/security_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/app_lock_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/wallets_screen.dart';
import 'screens/history_screen.dart';
import 'screens/card_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/update_password_screen.dart';
import 'screens/email_verification_pending_screen.dart';
import 'screens/chat_screen.dart';
import 'widgets/nodex_opening_splash.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _openingSplash = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NodEX',
      theme: myTheme,
      debugShowCheckedModeBanner: false,
      home: Stack(
        fit: StackFit.expand,
        children: [
          Consumer2<AuthProvider, SecurityProvider>(
            builder: (context, auth, sec, _) {
              if (auth.isLoading) return const LoadingScreen();
              if (auth.isPasswordRecovery) return const UpdatePasswordScreen();
              if (auth.pendingVerificationEmail != null) return const EmailVerificationPendingScreen();
              if (!auth.isAuthenticated) return const LoginScreen();
              if (sec.isLocked || (sec.pinEnabled && sec.isSessionExpired)) {
                return const AppLockScreen();
              }
              return const HomeTabs();
            },
          ),
          if (_openingSplash)
            Positioned.fill(
              child: NodexOpeningSplash(
                onFinished: () => setState(() => _openingSplash = false),
              ),
            ),
        ],
      ),
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<WalletProvider>().fetch(auth.user?.id);
      context.read<SecurityProvider>().touchActivity();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sec = context.read<SecurityProvider>();
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (sec.pinEnabled) sec.lock();
    } else if (state == AppLifecycleState.resumed) {
      sec.touchActivity();
      if (sec.pinEnabled && sec.isSessionExpired) sec.lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardScreen(),
      const WalletsScreen(),
      const HistoryScreen(),
      const CardScreen(),
      const SettingsScreen(),
    ];
    return Listener(
      onPointerDown: (_) => context.read<SecurityProvider>().touchActivity(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const FuturisticBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, animation, secondaryAnimation) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_index),
                child: pages[_index],
              ),
            ),
            floatingActionButton: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  context.read<SecurityProvider>().touchActivity();
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ChatScreen()));
                },
                backgroundColor: AppTheme.primary,
                foregroundColor: const Color(0xFF042028),
                elevation: 0,
                highlightElevation: 0,
                icon: const Icon(Icons.smart_toy_rounded, size: 22),
                label: const Text('Assistant', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card.withValues(alpha: 0.72),
                    border: Border(
                      top: BorderSide(color: AppTheme.border.withValues(alpha: 0.55)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        blurRadius: 28,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      TabNavigatorDots(count: 5, selectedIndex: _index),
                      const SizedBox(height: 4),
                      BottomNavigationBar(
                    currentIndex: _index,
                    onTap: (i) {
                      context.read<SecurityProvider>().touchActivity();
                      setState(() => _index = i);
                    },
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    selectedFontSize: 12,
                    unselectedFontSize: 11,
                    selectedItemColor: AppTheme.primary,
                    unselectedItemColor: AppTheme.textSecondary,
                    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 26), label: 'Accueil'),
                      BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded, size: 26), label: 'Wallets'),
                      BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded, size: 26), label: 'Historique'),
                      BottomNavigationBarItem(icon: Icon(Icons.credit_card_rounded, size: 26), label: 'Carte'),
                      BottomNavigationBarItem(icon: Icon(Icons.settings_rounded, size: 26), label: 'Réglages'),
                    ],
                  ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
