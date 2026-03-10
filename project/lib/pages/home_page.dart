import 'package:flutter/material.dart';
import '../models/operation.dart';
import 'deposit_page.dart';
import 'withdraw_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final double initialBalance;

  const HomePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.initialBalance,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double balance;
  final List<Operation> history = [];

  @override
  void initState() {
    super.initState();
    balance = widget.initialBalance;
  }

  Future<void> goToDepositPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DepositPage(),
      ),
    );

    if (result != null && result is double) {
      setState(() {
        balance += result;
        history.add(
          Operation(
            type: 'Dépôt',
            amount: result,
            date: DateTime.now(),
          ),
        );
      });
    }
  }

  Future<void> goToWithdrawPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WithdrawPage(currentBalance: balance),
      ),
    );

    if (result != null && result is double) {
      setState(() {
        balance -= result;
        history.add(
          Operation(
            type: 'Retrait',
            amount: result,
            date: DateTime.now(),
          ),
        );
      });
    }
  }

  void showHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(history: history),
      ),
    );
  }

  void showProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          userName: widget.userName,
          userEmail: widget.userEmail,
          balance: balance,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('MiniBank'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bienvenue ${widget.userName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Solde actuel',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${balance.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'Déposer',
                    icon: Icons.add_circle_outline,
                    color: Colors.green,
                    onTap: goToDepositPage,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildActionCard(
                    title: 'Retirer',
                    icon: Icons.remove_circle_outline,
                    color: Colors.red,
                    onTap: goToWithdrawPage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildLargeActionButton(
              title: 'Voir l’historique',
              icon: Icons.history,
              color: Colors.deepPurple,
              onTap: showHistoryPage,
            ),
            const SizedBox(height: 14),
            _buildLargeActionButton(
              title: 'Mon profil',
              icon: Icons.person_outline,
              color: Colors.blue,
              onTap: showProfilePage,
            ),
            const SizedBox(height: 14),
            _buildLargeActionButton(
              title: 'Se déconnecter',
              icon: Icons.logout,
              color: Colors.grey.shade700,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 34),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}