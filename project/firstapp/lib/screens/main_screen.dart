import 'package:flutter/material.dart';
import 'crypto_screen.dart';
import 'history_screen.dart';
import 'wallet_screen.dart'; // <-- C'est bien le bon import !

// --- NOS NOUVELLES COULEURS THEME (Inspirées du React) ---
const Color bgDark = Color(0xFF09090B); // zinc-950
const Color cardDark = Color(0xFF18181B); // zinc-900
const Color emerald500 = Color(0xFF10B981);
const Color textGray = Color(0xFF71717A); // zinc-500

// ---> NOUVEAU 1 : La clé globale pour contrôler la navigation depuis d'autres pages <---
final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
  // ---> NOUVEAU 2 : On retire le 'const' et on attache la clé globale ici <---
  MainScreen({Key? key}) : super(key: mainScreenKey);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // On met l'onglet Wallet par défaut en entrant dans l'app

  // Liste de tes futurs écrans redesignés
  final List<Widget> _screens = [
    const WalletScreen(),   // <-- La bonne classe de ton wallet_screen.dart
    const HistoryScreen(),  
    const CryptoScreen(),
    const Center(child: Text("Chat IA (À venir)", style: TextStyle(color: Colors.white))), 
  ];

  // ---> NOUVEAU 3 : La fonction pour changer d'onglet manuellement <---
  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      // Le Header (App Bar) façon React
      appBar: AppBar(
        backgroundColor: bgDark.withOpacity(0.8),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: emerald500,
                  child: Text('B', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Compte', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold)),
                    Text('Boss', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: const Text('BKN WALLET', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            )
          ],
        ),
      ),
      body: _screens[_currentIndex],
      
      // La Bottom Navigation flottante façon React
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: bgDark.withOpacity(0.9),
          border: Border(top: BorderSide(color: Colors.grey.shade900)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.account_balance_wallet, 'WALLET'),
            _buildNavItem(1, Icons.history, 'HISTORIQUE'),
            _buildNavItem(2, Icons.trending_up, 'MARCHÉ'),
            _buildNavItem(3, Icons.chat_bubble_outline, 'AI CHAT'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      // ---> NOUVEAU 4 : On utilise notre nouvelle fonction switchTab <---
      onTap: () => switchTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? emerald500 : textGray, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? emerald500 : textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(color: emerald500, shape: BoxShape.circle),
            )
        ],
      ),
    );
  }
}