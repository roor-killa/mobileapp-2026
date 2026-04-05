import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isSent = transaction.isSent;
    final isRecharge = transaction.type == 'recharge';
    final color = isRecharge
        ? AppColors.secondary
        : isSent
            ? AppColors.error
            : AppColors.success;

    final icon = isRecharge
        ? Icons.add_circle_rounded
        : isSent
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.otherPartyName,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.typeLabel,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),

          // Montant + Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isSent && !isRecharge ? '-' : '+'}${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2).format(transaction.amount)}',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd/MM HH:mm').format(transaction.createdAt),
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
