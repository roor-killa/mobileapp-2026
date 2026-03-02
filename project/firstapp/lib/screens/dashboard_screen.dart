import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/bank_service.dart';
import 'transfer_screen.dart';
import 'login_screen.dart';
import 'account_details_screen.dart';
import 'transactions_screen.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BankService _bankService = BankService();
  late Future<void> _initializationFuture;
  List<Account>? _accounts;
  List<Transaction>? _transactions;
  String? _errorMessage;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    await _bankService.init();
    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userRaw = prefs.getString('user_data');
      if (userRaw != null) {
        try {
          final user = (jsonDecode(userRaw) as Map<String, dynamic>);
          _userName = (user['full_name'] ?? user['name'] ?? '').toString().trim();
        } catch (_) {
          // ignore
        }
      }

      final accounts = await _bankService.getAccounts();
      final transactions = await _bankService.getTransactions();
      
      setState(() {
        _accounts = accounts;
        _transactions = transactions;
        _errorMessage = null;
      });
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.toLowerCase().contains('session expirée')) {
        await _logout();
        return;
      }
      setState(() => _errorMessage = msg);
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

        final scheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('MyBank'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // Message d'erreur
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                  ),

                // Header banking card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.brand, AppTheme.brand2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName == null || _userName!.isEmpty ? 'Bonjour' : 'Bonjour, $_userName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Solde total',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _accounts != null
                            ? '${_accounts!.fold<double>(0, (sum, acc) => sum + acc.balance).toStringAsFixed(2)} EUR'
                            : '—',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
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
                  const Center(child: Padding(padding: EdgeInsets.only(top: 10), child: CircularProgressIndicator()))
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
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Historique des transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Historique',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: (_accounts == null || _transactions == null)
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionsScreen(
                                    accounts: _accounts ?? const [],
                                    transactions: _transactions ?? const [],
                                  ),
                                ),
                              );
                            },
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                if (_transactions != null && _transactions!.isNotEmpty)
                  for (var transaction in _transactions!.take(5))
                    _buildTransactionTile(transaction)
                else if (_transactions == null)
                  const Center(child: Padding(padding: EdgeInsets.only(top: 10), child: CircularProgressIndicator()))
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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AccountDetailsScreen(account: account)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.accountType,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          account.accountNumber,
                          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${account.balance.toStringAsFixed(2)} ${account.currency}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'IBAN: ${account.iban}',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final ids = (_accounts ?? const <Account>[]).map((a) => a.id).toSet();
    final isOutgoing = ids.contains(transaction.fromAccountId) &&
        (transaction.toAccountId == null || !ids.contains(transaction.toAccountId));
    final isIncoming = transaction.toAccountId != null &&
        ids.contains(transaction.toAccountId) &&
        !ids.contains(transaction.fromAccountId);
    final isInternal = transaction.toAccountId != null &&
        ids.contains(transaction.toAccountId) &&
        ids.contains(transaction.fromAccountId);

    final scheme = Theme.of(context).colorScheme;
    final icon = isInternal
        ? Icons.sync_alt
        : (isOutgoing ? Icons.call_made : (isIncoming ? Icons.call_received : Icons.receipt_long));
    final color = isInternal ? scheme.primary : (isOutgoing ? scheme.error : (isIncoming ? scheme.tertiary : scheme.onSurfaceVariant));
    final sign = isInternal ? '' : (isOutgoing ? '-' : (isIncoming ? '+' : ''));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(transaction.description),
      subtitle: Text(dateFormat.format(transaction.transactionDate)),
      trailing: Text(
        '$sign${transaction.amount.toStringAsFixed(2)} EUR',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
