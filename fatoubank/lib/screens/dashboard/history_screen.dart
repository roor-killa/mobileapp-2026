import 'package:flutter/material.dart';
import 'package:fatoubank/utils/colors.dart';
import 'package:fatoubank/models/transaction.dart';
import 'package:fatoubank/widgets/transaction_card.dart';

class HistoryScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const HistoryScreen({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique complet'),
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('Aucune transaction trouvée'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return TransactionCard(transaction: transactions[index]);
              },
            ),
    );
  }
}
