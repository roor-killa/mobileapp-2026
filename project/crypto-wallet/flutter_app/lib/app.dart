import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/wallets_screen.dart';
import 'screens/history_screen.dart';
import 'screens/card_screen.dart';
import 'screens/settings_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NodEX',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) return const LoadingScreen();
          if (!auth.isAuthenticated) return const LoginScreen();
          return const HomeTabs();
        },
      ),
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetch();
    });
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
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallets'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card_rounded), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Réglages'),
        ],
      ),
    );
  }
}
