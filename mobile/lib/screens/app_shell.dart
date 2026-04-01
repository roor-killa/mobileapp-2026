import 'package:flutter/material.dart';
import '../main.dart';

import 'home_screen.dart';
import 'history_screen.dart';
import 'actus_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with RouteAware {
  int _index = 0;

  // GlobalKey lets us call reload() on HomeScreen's state after a push/pop.
  final _homeKey = GlobalKey<HomeScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(key: _homeKey),
      const ActusScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];
  }

  /// Called whenever any route above AppShell pops back to it
  /// (e.g. buy screen, transfer screen).
  @override
  void didPopNext() {
    // Only reload if we're on the home tab; otherwise the user will reload
    // when they switch back to it.
    if (_index == 0) {
      _homeKey.currentState?.reload();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    homeRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    homeRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          // Reload home when the user taps back onto the home tab
          if (i == 0 && _index != 0) {
            _homeKey.currentState?.reload();
          }
          setState(() => _index = i);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0B1220),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Actus'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
