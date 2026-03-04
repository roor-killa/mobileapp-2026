import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/bank_provider.dart';
import '../widgets/transaction_tile.dart';
import 'accounts_screen.dart';
import 'transfert_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  static const _titles = ['Mes comptes', 'Virement', 'Historique'];

  @override
  Widget build(BuildContext context) {
    final bank = context.watch<BankProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: bank.isLoading
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.refresh),
          onPressed: () => bank.loadAll(),
        ),
        title: Text(_titles[_idx]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              bank.clear();
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: IndexedStack(index: _idx, children: const [
        AccountsScreen(),
        _TransferTab(),
        _HistoryTab(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_balance_outlined),
              selectedIcon: Icon(Icons.account_balance), label: 'Comptes'),
          NavigationDestination(icon: Icon(Icons.send_outlined),
              selectedIcon: Icon(Icons.send), label: 'Virement'),
          NavigationDestination(icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history), label: 'Historique'),
        ],
      ),
    );
  }
}

class _TransferTab extends StatelessWidget {
  const _TransferTab();
  @override
  Widget build(BuildContext context) => const TransferBody();
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();
  @override
  Widget build(BuildContext context) {
    final bank = context.watch<BankProvider>();
    final txns = bank.transactions;
    // Ensemble de tous les IDs de comptes appartenant à l'utilisateur
    final myAccountIds = bank.accounts.map((a) => a.id).toSet();

    if (txns.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text('Aucune transaction',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: txns.length,
      itemBuilder: (ctx, i) {
        final txn = txns[i];
        // Cherche l'ID d'un compte "moi" impliqué dans cette transaction
        final myId = myAccountIds.contains(txn.fromAccountId)
            ? txn.fromAccountId
            : txn.toAccountId;
        return TransactionTile(
          transaction: txn,
          perspectiveAccountId: myId,
        );
      },
    );
  }
}