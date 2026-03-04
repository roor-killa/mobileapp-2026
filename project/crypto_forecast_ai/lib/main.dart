import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';
import 'screens/bank_screen.dart';
import 'screens/auth_screen.dart';
import 'services/session_store.dart';
import 'services/api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ IMPORTANT: initialise les locales pour DateFormat()
  // Tu peux mettre 'fr_FR' ou juste 'fr' (les deux marchent souvent).
  Intl.defaultLocale = 'fr_FR';
  await initializeDateFormatting('fr_FR', null);

  // Charge la session si elle existe
  final token = await SessionStore.loadToken();
  if (token != null && token.isNotEmpty) {
    api.setToken(token);
  }

  runApp(MyApp(isLogged: token != null && token.isNotEmpty));
}

class MyApp extends StatelessWidget {
  final bool isLogged;
  const MyApp({super.key, required this.isLogged});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF00FFC6); // cyan/vert neon

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeoBank',

      // ✅ Force l'app en français
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('fr'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF070B10),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
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
    Navigator.of(context).pushReplacementNamed("/auth");
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          Stack(
            children: [
              const BankScreen(),
              Positioned(
                right: 12,
                top: MediaQuery.of(context).padding.top + 10,
                child: IconButton(
                  onPressed: _logout,
                  tooltip: "Déconnexion",
                  icon: Icon(Icons.logout_rounded, color: cs.onSurface.withOpacity(0.85)),
                ),
              )
            ],
          ),
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
        ],
      ),
    );
  }
}