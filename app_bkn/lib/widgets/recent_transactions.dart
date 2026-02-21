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
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8F9FF)],
          ),
          borderRadius: BorderRadius.circular(25),
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
            Icon(Icons.history, size: 60, color: AppTheme.primaryPink),
            SizedBox(height: 16),
            Text(
              'Aucune transaction',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Vos transactions apparaîtront ici',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
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
    
    Color getColor() {
      return isEnvoi ? AppTheme.errorRed : AppTheme.secondaryGreen;
    }

    IconData getIcon() {
      return isEnvoi ? Icons.arrow_upward : Icons.arrow_downward;
    }

    String getTitle() {
      if (isEnvoi) {
        return 'Envoi à ${t['destinataire_pseudo'] ?? '?'}';
      } else {
        return 'Réception de ${t['expediteur_pseudo'] ?? '?'}';
      }
    }

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                getColor(),
                getColor().withValues(alpha: 0.8),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            getIcon(),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          getTitle(),
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
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: getColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isEnvoi ? '-' : '+'}${montant.toStringAsFixed(0)}',
                style: TextStyle(
                  color: getColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'BKN',
                style: TextStyle(
                  color: getColor().withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}