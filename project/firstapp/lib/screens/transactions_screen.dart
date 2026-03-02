import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';

class TransactionsScreen extends StatelessWidget {
  final List<Account> accounts;
  final List<Transaction> transactions;

  const TransactionsScreen({
    super.key,
    required this.accounts,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ids = accounts.map((a) => a.id).toSet();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => Divider(color: scheme.outlineVariant),
        itemBuilder: (context, i) {
          final t = transactions[i];
          final isOutgoing = ids.contains(t.fromAccountId) && (t.toAccountId == null || !ids.contains(t.toAccountId));
          final isIncoming = t.toAccountId != null && ids.contains(t.toAccountId) && !ids.contains(t.fromAccountId);
          final isInternal = t.toAccountId != null && ids.contains(t.toAccountId) && ids.contains(t.fromAccountId);

          final icon = isInternal
              ? Icons.sync_alt
              : (isOutgoing ? Icons.call_made : (isIncoming ? Icons.call_received : Icons.receipt_long));

          final color = isInternal
              ? scheme.primary
              : (isOutgoing ? scheme.error : (isIncoming ? scheme.tertiary : scheme.onSurfaceVariant));

          final sign = isInternal ? '' : (isOutgoing ? '-' : (isIncoming ? '+' : ''));

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: color),
            title: Text(t.description.isEmpty ? 'Transaction' : t.description),
            subtitle: Text('${dateFormat.format(t.transactionDate)} • Ref ${t.referenceNumber}'),
            trailing: Text(
              '$sign${t.amount.toStringAsFixed(2)} EUR',
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
          );
        },
      ),
    );
  }
}

