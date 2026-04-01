import 'package:flutter/material.dart';
import 'screens/transfer_screen.dart'; // Vérifie bien que le chemin est correct
import 'screens/profile_screen.dart'; 

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Utilisation de static pour la liste des écrans
  final List<Widget> _screens = [
    const TransferScreen(), // Correction du nom (sans le 't' à Transfer)
    const ProfileScreen(),  // Ajout du const
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // On utilise souvent IndexedStack pour ne pas perdre l'état des pages 
      // (par exemple, si tu as commencé à taper un montant, il reste là)
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ), 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Recommandé pour 2 onglets ou plus
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Portefeuille',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mon Compte',
          ),
        ],
      ),
    );
  }
}