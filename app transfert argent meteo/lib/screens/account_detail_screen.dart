import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bank_provider.dart';
import '../widgets/transaction_tile.dart';
import '../screens/transfert_screen.dart';

class AccountDetailScreen extends StatelessWidget {
  final String accountId;
  const AccountDetailScreen({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    final bank    = context.watch<BankProvider>();
    final account = bank.findById(accountId);

    if (account == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compte')),
        body: const Center(child: Text('Compte introuvable.')),
      );
    }

    final txns = bank.transactionsFor(accountId);

    return Scaffold(
      appBar: AppBar(
        title: Text(account.label),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(children: [
          // ── Solde ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              Text(account.ownerName,
                  style: const TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(account.accountNumber,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 20),
              Text('${account.balance.toStringAsFixed(2)} €',
                  style: const TextStyle(color: Colors.white, fontSize: 36,
                      fontWeight: FontWeight.bold)),
              const Text('Solde disponible',
                  style: TextStyle(color: Colors.white60)),
            ]),
          ),

          // ── Bouton virement ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Effectuer un virement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                        TransferScreen(preselectedFromId: accountId))),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Historique ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Text('Historique',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Spacer(),
              Text('${txns.length} opération(s)',
                  style: const TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: txns.isEmpty
                ? const Center(child: Text('Aucune transaction',
                      style: TextStyle(color: Colors.white70)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: txns.length,
                    itemBuilder: (ctx, i) => TransactionTile(
                      transaction: txns[i],
                      perspectiveAccountId: accountId,
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}