import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';

class TransactionsScreen extends StatefulWidget {
  final List<Account> accounts;
  final List<Transaction> transactions;
  final String initialFilter;

  const TransactionsScreen({
    super.key,
    required this.accounts,
    required this.transactions,
    this.initialFilter = 'all',
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late String _filter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _filtered() {
    final ids = widget.accounts.map((a) => a.id).toSet();
    var list = widget.transactions.where((t) {
      final isOutgoing = ids.contains(t.fromAccountId) && (t.toAccountId == null || !ids.contains(t.toAccountId));
      final isIncoming = t.toAccountId != null && ids.contains(t.toAccountId) && !ids.contains(t.fromAccountId);
      final isInternal = t.toAccountId != null && ids.contains(t.toAccountId) && ids.contains(t.fromAccountId);
      switch (_filter) {
        case 'incoming': if (!isIncoming) return false; break;
        case 'outgoing': if (!isOutgoing) return false; break;
        case 'internal': if (!isInternal) return false; break;
        default: break;
      }
      return true;
    }).toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((t) => (t.description.toLowerCase().contains(_searchQuery))).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ids = widget.accounts.map((a) => a.id).toSet();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final list = _filtered();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par libellé...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                FilterChip(
                  label: const Text('Toutes'),
                  selected: _filter == 'all',
                  onSelected: (_) => setState(() => _filter = 'all'),
                ),
                FilterChip(
                  label: const Text('Entrant'),
                  selected: _filter == 'incoming',
                  onSelected: (_) => setState(() => _filter = 'incoming'),
                ),
                FilterChip(
                  label: const Text('Sortant'),
                  selected: _filter == 'outgoing',
                  onSelected: (_) => setState(() => _filter = 'outgoing'),
                ),
                FilterChip(
                  label: const Text('Interne'),
                  selected: _filter == 'internal',
                  onSelected: (_) => setState(() => _filter = 'internal'),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      'Aucune transaction',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Divider(color: scheme.outlineVariant),
                    itemBuilder: (context, i) {
                      final t = list[i];
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

                      final counterparty = isIncoming
                          ? (t.fromOwnerName ?? 'Compte externe')
                          : (isOutgoing ? (t.toOwnerName ?? 'Bénéficiaire') : null);

                      final subtitle = [
                        dateFormat.format(t.transactionDate),
                        'Ref ${t.referenceNumber}',
                        if (counterparty != null) (isIncoming ? 'De $counterparty' : 'À $counterparty'),
                      ].join(' • ');

                      final label = isInternal
                          ? 'Interne'
                          : (isOutgoing ? 'Sortant' : (isIncoming ? 'Entrant' : 'Autre'));

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(icon, color: color),
                        title: Row(
                          children: [
                            Expanded(child: Text(t.description.isEmpty ? 'Transaction' : t.description)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(subtitle),
                        trailing: Text(
                          '$sign${t.amount.toStringAsFixed(2)} EUR',
                          style: TextStyle(fontWeight: FontWeight.w800, color: color),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
