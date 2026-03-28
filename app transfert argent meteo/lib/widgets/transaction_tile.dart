import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String? perspectiveAccountId;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.perspectiveAccountId,
  });

  @override
  Widget build(BuildContext context) {
    final isDebit = perspectiveAccountId == null
        ? true
        : transaction.fromAccountId == perspectiveAccountId;

    final color = isDebit ? Colors.red.shade700 : Colors.green.shade700;
    final icon  = isDebit ? Icons.arrow_upward : Icons.arrow_downward;
    final sign  = isDebit ? '−' : '+';

    // ✅ CORRIGÉ : utilise createdAt (et non date), fromOwnerName/toOwnerName
    final d = transaction.createdAt;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}'
        '  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(children: [
          Expanded(
            child: Text(transaction.fromOwnerName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
          ),
          Expanded(
            child: Text(transaction.toOwnerName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateStr, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            if (transaction.note != null && transaction.note!.isNotEmpty)
              Text(transaction.note!,
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                  overflow: TextOverflow.ellipsis),
          ],
        ),
        isThreeLine: transaction.note != null && transaction.note!.isNotEmpty,
        trailing: Text(
          '$sign${transaction.amount.toStringAsFixed(2)} €',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
        ),
      ),
    );
  }
}