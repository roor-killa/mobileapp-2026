import 'package:flutter/material.dart';
import 'package:fatoubank/models/transaction.dart';
import 'package:fatoubank/models/transaction_type.dart';
import 'package:fatoubank/utils/colors.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  Color getTypeColor() {
    switch (transaction.type) {
      case TransactionType.expense:
        return AppColors.expenseColor;
      case TransactionType.income:
        return AppColors.incomeColor;
      case TransactionType.transfer:
        return AppColors.transferColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: getTypeColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              transaction.icon,
              color: getTypeColor(),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.amount >= 0 ? '+' : ''}${transaction.amount.toStringAsFixed(2)} €',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: getTypeColor(),
            ),
          ),
        ],
      ),
    );
  }
}