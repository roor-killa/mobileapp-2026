import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../cards/cards_screen.dart';
import '../beneficiaries/beneficiaries_screen.dart';
import '../crypto/crypto_screen_v2.dart';
import '../rewards/gagner_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const CardsScreen(),
      const BeneficiariesScreen(),
      const CryptoScreen(),
      const GagnerScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildChatbotFAB(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: NEGsColors.bgWhite,
        boxShadow: [
          BoxShadow(
            color: NEGsColors.primaryViolet.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: NEGsColors.bgWhite,
        selectedItemColor: NEGsColors.primaryCyan,
        unselectedItemColor: NEGsColors.textTertiary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Cartes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Bénéficiaires'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Crypto'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Gagner'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildChatbotFAB() {
    return FloatingActionButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chatbot - Support bientôt disponible'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      backgroundColor: NEGsColors.primaryViolet,
      child: const Icon(Icons.chat_bubble, color: Colors.white),
    );
  }
}
