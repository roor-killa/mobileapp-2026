import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/bank_service.dart';
import 'transfer_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BankService _bankService = BankService();
  late Future<void> _initializationFuture;
  List<Account>? _accounts;
  List<Transaction>? _transactions;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bankService.init();
    _initializationFuture = _loadData();
  }

  Future<void> _loadData() async {
    try {
      final accounts = await _bankService.getAccounts();
      final transactions = await _bankService.getTransactions();
      
      setState(() {
        _accounts = accounts;
        _transactions = transactions;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _logout() async {
    await _bankService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('MyBank - Tableau de bord'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message d'erreur
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // Solde total
                const Text(
                  'Solde total',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  _accounts != null
                      ? '${_accounts!.fold<double>(0, (sum, acc) => sum + acc.balance).toStringAsFixed(2)} EUR'
                      : 'Chargement...',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 30),

                // Comptes bancaires
                const Text(
                  'Mes comptes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                if (_accounts != null && _accounts!.isNotEmpty)
                  for (var account in _accounts!)
                    _buildAccountCard(account)
                else if (_accounts == null)
                  const CircularProgressIndicator()
                else
                  const Text('Aucun compte trouvé'),

                const SizedBox(height: 30),

                // Bouton de virement
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransferScreen(
                            accounts: _accounts ?? [],
                            onTransferSuccess: _loadData,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Effectuer un virement'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Historique des transactions
                const Text(
                  'Historique des transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                if (_transactions != null && _transactions!.isNotEmpty)
                  for (var transaction in _transactions!.take(5))
                    _buildTransactionTile(transaction)
                else if (_transactions == null)
                  const CircularProgressIndicator()
                else
                  const Text('Aucune transaction'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountCard(Account account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.accountType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      account.accountNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${account.balance.toStringAsFixed(2)} ${account.currency}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'IBAN: ${account.iban}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isDebit = transaction.fromAccountId != null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Icon(
        isDebit ? Icons.arrow_forward : Icons.arrow_back,
        color: isDebit ? Colors.red : Colors.green,
      ),
      title: Text(transaction.description),
      subtitle: Text(dateFormat.format(transaction.transactionDate)),
      trailing: Text(
        '${isDebit ? '-' : '+'}${transaction.amount.toStringAsFixed(2)} EUR',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDebit ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
