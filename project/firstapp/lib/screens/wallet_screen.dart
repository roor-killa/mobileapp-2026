import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'transfer_screen.dart';
import 'topup_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _apiService  = ApiService();
  final _authService = AuthService();
  Wallet? _wallet;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final wallet       = await _apiService.getWallet();
      final transactions = await _apiService.getTransactions();
      setState(() {
        _wallet       = wallet;
        _transactions = transactions;
        _isLoading    = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Portefeuille'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Carte solde
                  Card(
                    elevation: 4,
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'Solde disponible',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_wallet?.balance.toStringAsFixed(2) ?? '...'} €',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TransferScreen()),
                            );
                            _loadData();
                          },
                          icon: const Icon(Icons.send),
                          label: const Text('Transférer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TopUpScreen()),
                            );
                            _loadData();
                          },
                          icon: const Icon(Icons.add_card),
                          label: const Text('Recharger'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Historique des transactions
                  const Text(
                    'Historique',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_transactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucune transaction pour l\'instant.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._transactions.map((t) => _buildTransactionTile(t)),
                ],
              ),
            ),
    );
  }

  Widget _buildTransactionTile(Transaction t) {
    final isPositive = t.type == 'topup' || t.type == 'transfer_in';

    final icon = switch (t.type) {
      'topup'        => Icons.add_card,
      'transfer_out' => Icons.arrow_upward,
      'transfer_in'  => Icons.arrow_downward,
      _              => Icons.swap_horiz,
    };

    final label = switch (t.type) {
      'topup'        => 'Rechargement',
      'transfer_out' => 'Transfert envoyé',
      'transfer_in'  => 'Transfert reçu',
      _              => t.type,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: isPositive ? Colors.green : Colors.red),
        title: Text(label),
        subtitle: Text(t.createdAt.toLocal().toString().substring(0, 16)),
        trailing: Text(
          '${isPositive ? '+' : '-'}${t.amount.toStringAsFixed(2)} €',
          style: TextStyle(
            fontSize: 16,
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
