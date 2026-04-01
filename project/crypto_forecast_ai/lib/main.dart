import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/bank_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/wallet_screen.dart';

import 'services/session_store.dart';
import 'services/api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final token = await SessionStore.loadToken();
    final refresh = await SessionStore.loadRefreshToken();
  final logged = token != null && token.isNotEmpty;

  if (logged) {
    api.setToken(token);
    api.setRefreshToken(refresh);
    api.onTokenUpdate = (access, refreshTok) async {
      if (access != null && access.isNotEmpty) {
        await SessionStore.saveToken(access);
      }
      if (refreshTok != null && refreshTok.isNotEmpty) {
        await SessionStore.saveRefreshToken(refreshTok);
      }
    };
  }

  runApp(MyApp(isLogged: logged));
}

class MyApp extends StatelessWidget {
  final bool isLogged;
  const MyApp({super.key, required this.isLogged});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF00FFC6);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeoBank',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF070B10),
      ),
      routes: {
        "/": (_) => isLogged ? const RootShell() : const AuthScreen(),
        "/app": (_) => const RootShell(),
        "/auth": (_) => const AuthScreen(),
      },
      initialRoute: "/",
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  Future<void> _logout() async {
    await SessionStore.clear();
    api.setToken(null);
    if (!mounted) return;

    // ✅ évite de revenir en arrière vers une page protégée
    Navigator.of(context).pushNamedAndRemoveUntil("/auth", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: (_index == 2) ? null : AppBar(
        title: const Text("NeoBank"),
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: "Déconnexion",
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          const BankScreen(),
          WalletScreen(onLogout: _logout),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: cs.surface.withOpacity(0.7),
        indicatorColor: cs.primary.withOpacity(0.25),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.show_chart_rounded), label: "Marché"),
          NavigationDestination(icon: Icon(Icons.account_balance_rounded), label: "Banque"),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_rounded), label: "Wallet"),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: "Profil"),
        ],
      ),
    );
  }
}