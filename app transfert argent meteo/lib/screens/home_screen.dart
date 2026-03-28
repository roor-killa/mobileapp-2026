import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/bank_provider.dart';
import '../widgets/transaction_tile.dart';
import 'accounts_screen.dart';
import 'transfert_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  static const _titles = ['Mes comptes', 'Virement', 'Historique'];

  Future<void> _logout() async {
    final bank = context.read<BankProvider>();
    final auth = context.read<AuthProvider>();
    bank.clear();
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bank = context.watch<BankProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
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
            onPressed: _logout,
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: IndexedStack(index: _idx, children: const [
          AccountsScreen(),
          _TransferTab(),
          _HistoryTab(),
        ]),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        child: NavigationBar(
        backgroundColor: const Color(0xFF1565C0),
        indicatorColor: Colors.white24,
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_balance_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.account_balance, color: Colors.white), label: 'Comptes'),
          NavigationDestination(icon: Icon(Icons.send_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.send, color: Colors.white), label: 'Virement'),
          NavigationDestination(icon: Icon(Icons.history_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.history, color: Colors.white), label: 'Historique'),
        ],
      ),
    )
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
    final myAccountIds = bank.accounts.map((a) => a.id).toSet();

    if (txns.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.receipt_long_outlined, size: 72, color: Colors.white38),
        const SizedBox(height: 16),
        const Text('Aucune transaction',
            style: TextStyle(fontSize: 18, color: Colors.white70)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: txns.length,
      itemBuilder: (ctx, i) {
        final txn = txns[i];
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