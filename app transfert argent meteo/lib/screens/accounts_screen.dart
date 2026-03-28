import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bank_provider.dart';
import '../models/account.dart';
import 'account_detail_screen.dart';
import 'create_account_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bank = context.watch<BankProvider>();
    final accounts = bank.accounts;

    return Stack(
      children: [
        accounts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        size: 72, color: Colors.white38),
                    const SizedBox(height: 16),
                    const Text("Aucun compte créé",
                        style: TextStyle(fontSize: 18, color: Colors.white70)),
                    const SizedBox(height: 8),
                    const Text("Appuyez sur + pour créer votre premier compte",
                        style: TextStyle(color: Colors.white60)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: accounts.length,
                itemBuilder: (context, i) => _AccountCard(account: accounts[i]),
              ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: "fab_create_account",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text("Nouveau compte"), backgroundColor: Colors.white, 
            foregroundColor: const Color(0xFF1565C0),
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AccountModel account;
  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AccountDetailScreen(accountId: account.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.ownerName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(account.accountNumber,
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${account.balance.toStringAsFixed(2)} €",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 4),
                  const Text("Voir détails",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
        ),
      ),
    );
  }
}