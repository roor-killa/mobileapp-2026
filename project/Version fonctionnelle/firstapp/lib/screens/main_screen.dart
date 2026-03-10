import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'transfer_screen.dart'; // Ton écran actuel (Onglet 1)
import 'history_screen.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // L'onglet actif par défaut (0 = Wallet)

  // Liste des 4 écrans de ton application
  // Pour l'instant, les 3 derniers sont des textes temporaires
  final List<Widget> _screens = [
    const TransferScreen(), 
    const HistoryScreen(), 
    const Center(child: Text("Bourse & Achat BKN", style: TextStyle(fontSize: 18, color: Colors.grey))), 
    const Center(child: Text("Vendre mes BKN", style: TextStyle(fontSize: 18, color: Colors.grey))), 
  ];

  // Fonction pour se déconnecter
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // On supprime le badge
    await prefs.remove('solde');
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BKN Wallet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Se déconnecter',
          )
        ],
      ),
      // Le corps de la page change en fonction de l'onglet sélectionné
      body: _screens[_currentIndex],
      
      // La barre de navigation façon Revolut
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // On change d'onglet
          });
        },
        type: BottomNavigationBarType.fixed, // Garde les icônes fixes
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'BKN Crypto'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_exchange), label: 'Vendre'),
        ],
      ),
    );
  }
}