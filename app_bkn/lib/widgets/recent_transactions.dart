import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:app_bkn/theme/app_theme.dart';
import 'package:app_bkn/providers/transaction_provider.dart';
import 'package:app_bkn/services/api_service.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions.take(3).toList();
    
    if (transactionProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }
    
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.history, size: 48, color: AppTheme.textSecondary),
            SizedBox(height: 12),
            Text(
              'Aucune transaction',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: transactions.map((transaction) {
        return _buildTransactionTile(transaction);
      }).toList(),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> t) {
    final isEnvoi = t['expediteur_pseudo'] == ApiService.currentUserPseudo;
    final montant = t['montant'].toDouble();
    final date = DateTime.parse(t['date']);
    final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (isEnvoi ? AppTheme.errorRed : AppTheme.secondaryGreen).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isEnvoi ? Icons.arrow_upward : Icons.arrow_downward,
            color: isEnvoi ? AppTheme.errorRed : AppTheme.secondaryGreen,
            size: 24,
          ),
        ),
        title: Text(
          isEnvoi ? 'Envoi à ${t['destinataire_pseudo'] ?? '?'}' : 'Réception de ${t['expediteur_pseudo'] ?? '?'}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          formattedDate,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isEnvoi ? '-' : '+'}${montant.toStringAsFixed(0)} BKN',
              style: TextStyle(
                color: isEnvoi ? AppTheme.errorRed : AppTheme.secondaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '≈ ${montant.toStringAsFixed(0)} €',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}