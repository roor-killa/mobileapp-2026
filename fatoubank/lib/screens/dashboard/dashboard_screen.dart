import 'package:flutter/material.dart';
import 'package:fatoubank/utils/colors.dart';
import 'package:fatoubank/screens/dashboard/dashboard_content.dart';
import 'package:fatoubank/screens/dashboard/transfers_content.dart';
import 'package:fatoubank/screens/dashboard/analytics_content.dart';
import 'package:fatoubank/screens/dashboard/cards_content.dart';
import 'package:fatoubank/screens/dashboard/settings_content.dart';
import 'package:fatoubank/screens/login/login_screen.dart';
import 'package:fatoubank/models/transaction.dart';
import 'package:fatoubank/models/transaction_type.dart';
import 'package:fatoubank/screens/dashboard/ai_assistant_screen.dart';
import 'package:fatoubank/widgets/ecobank_header.dart';

import 'package:fatoubank/services/api_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  double _balance = 0.0;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final accountData = await ApiService.getAccountInfo();
      final transactionsData = await ApiService.getTransactions();

      if (!mounted) return;

      setState(() {
        _balance = double.parse(accountData['balance'].toString());
        final List<dynamic> txList = transactionsData;
        _transactions = txList.map<Transaction>((dynamic tx) {
          final TransactionType type = tx['transaction_type'] == 'income' 
              ? TransactionType.income 
              : TransactionType.expense;
          
          return Transaction(
            name: tx['description'] as String? ?? 'Transaction sans nom',
            amount: double.parse(tx['amount'].toString()),
            date: _formatDate(tx['transaction_date'] as String?),
            type: type,
            icon: _getIconForCategory(tx['category'] as String?, type),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement : $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "Inconnu";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getIconForCategory(String? category, TransactionType type) {
    if (type == TransactionType.income) return Icons.arrow_downward;
    
    switch (category?.toLowerCase()) {
      case 'alimentation': return Icons.shopping_basket;
      case 'divertissement': return Icons.play_circle_outline;
      case 'transport': return Icons.directions_car;
      case 'virement': return Icons.swap_horiz;
      default: return Icons.money;
    }
  }

  final List<String> _beneficiaries = [
    'Marie Dupont',
    'Jean Martin',
    'Sophie Bernard',
    'Paul Leroy',
  ];

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardContent(
        balance: _balance,
        transactions: _transactions,
        beneficiaries: _beneficiaries,
      ),
      TransfersContent(
        beneficiaries: _beneficiaries,
        onTransferMade: (Transaction tx) {
          setState(() {
            _transactions.insert(0, tx);
            _balance += tx.amount; // tx.amount est déjà négatif ici
          });
        },
      ),
      const AnalyticsContent(),
      const CardsContent(),
      SettingsContent(onLogout: _logout),
    ];

    const List<String> titles = [
      'ECOBANK',
      'Virements',
      'Statistiques',
      'Mes Cartes',
      'Paramètres',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Premium ECOBANK Header
          EcoBankCardHeader(
            title: titles[_selectedIndex],
            initials: 'MC',
          ),

          // Page content pushed below header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : pages[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.swap_horiz_outlined), activeIcon: Icon(Icons.swap_horiz), label: 'Virements'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), activeIcon: Icon(Icons.credit_card), label: 'Cartes'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Réglages'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAssistantScreen()));
        },
        backgroundColor: AppColors.primary,
        elevation: 8,
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 28),
      ),
    );
  }
}