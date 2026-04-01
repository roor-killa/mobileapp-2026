import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'deposit_page.dart';
import 'withdraw_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'chat_page.dart';
import 'transfer_page.dart';
import 'crypto_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String userEmail = '';
  double balance = 0.0;

  List<dynamic> cryptoAssets = [];

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final profile = await ApiService.getProfile();
      final assets = await ApiService.getCryptoAssets();

      setState(() {
        userName = profile['name'] ?? '';
        userEmail = profile['email'] ?? '';
        balance = double.tryParse(profile['balance'].toString()) ?? 0.0;
        cryptoAssets = assets;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> goToDepositPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DepositPage(),
      ),
    );

    if (result == true) {
      await loadDashboard();
    }
  }

  Future<void> goToWithdrawPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WithdrawPage(currentBalance: balance),
      ),
    );

    if (result == true) {
      await loadDashboard();
    }
  }

  Future<void> goToTransferPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransferPage(),
      ),
    );

    if (result == true) {
      await loadDashboard();
    }
  }

  Future<void> goToCryptoPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CryptoPage(),
      ),
    );

    await loadDashboard();
  }

  void showHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryPage(),
      ),
    );
  }

  void showProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          userName: userName,
          userEmail: userEmail,
          balance: balance,
        ),
      ),
    );
  }

  void showChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatPage(),
      ),
    );
  }

  Future<void> logout() async {
    await ApiService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  double getTotalCryptoInvested() {
    double total = 0.0;

    for (final asset in cryptoAssets) {
      final quantity = double.tryParse(asset['quantity'].toString()) ?? 0.0;
      final avgPrice =
          double.tryParse(asset['average_buy_price'].toString()) ?? 0.0;
      total += quantity * avgPrice;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('MiniBank'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('MiniBank'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loadDashboard,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalCryptoInvested = getTotalCryptoInvested();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('MiniBank'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                      'Bienvenue $userName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      userEmail,
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
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Résumé du wallet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      label: 'Argent disponible',
                      value: '${balance.toStringAsFixed(2)} €',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      label: 'Cryptos détenues',
                      value: '${cryptoAssets.length}',
                      color: Colors.amber.shade800,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      label: 'Montant investi en crypto',
                      value: '${totalCryptoInvested.toStringAsFixed(2)} €',
                      color: Colors.deepPurple,
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
                title: 'Faire un virement',
                icon: Icons.swap_horiz,
                color: Colors.orange,
                onTap: goToTransferPage,
              ),
              const SizedBox(height: 14),
              _buildLargeActionButton(
                title: 'Portefeuille Crypto',
                icon: Icons.currency_bitcoin,
                color: Colors.amber,
                onTap: goToCryptoPage,
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
                title: 'Assistant MiniBank',
                icon: Icons.smart_toy_outlined,
                color: Colors.teal,
                onTap: showChatPage,
              ),
              const SizedBox(height: 14),
              _buildLargeActionButton(
                title: 'Se déconnecter',
                icon: Icons.logout,
                color: Colors.grey,
                onTap: logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(Icons.circle, size: 12, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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