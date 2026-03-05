import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../theme/design_system.dart';

class TransactionsScreen extends StatefulWidget {
  final List<Account> accounts;
  final List<Transaction> transactions;
  final List<Map<String, dynamic>> stockTransactions;
  final List<Map<String, dynamic>> cryptoTransactions;
  final String initialFilter;

  const TransactionsScreen({
    super.key,
    required this.accounts,
    required this.transactions,
    this.stockTransactions = const [],
    this.cryptoTransactions = const [],
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

  List<Transaction> _filteredBank() {
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

  /// Liste fusionnée (banque + bourse + crypto) triée par date décroissante.
  List<_TransactionItem> _combinedList() {
    final bankList = _filteredBank();
    final List<_TransactionItem> items = [];
    for (final t in bankList) {
      items.add(_TransactionItem(date: t.transactionDate, bank: t, stock: null, crypto: null));
    }
    for (final s in widget.stockTransactions) {
      try {
        final date = DateTime.parse(s['date'] as String);
        final symbol = s['symbol'] as String? ?? '';
        if (_searchQuery.isNotEmpty && !symbol.toLowerCase().contains(_searchQuery)) continue;
        if (_filter != 'all' && _filter != 'bourse') continue;
        items.add(_TransactionItem(date: date, bank: null, stock: s, crypto: null));
      } catch (_) {}
    }
    for (final c in widget.cryptoTransactions) {
      try {
        final date = DateTime.parse(c['date'] as String);
        final symbol = c['symbol'] as String? ?? '';
        if (_searchQuery.isNotEmpty && !symbol.toLowerCase().contains(_searchQuery)) continue;
        if (_filter != 'all' && _filter != 'crypto') continue;
        items.add(_TransactionItem(date: date, bank: null, stock: null, crypto: c));
      } catch (_) {}
    }
    if (_filter == 'outgoing' || _filter == 'incoming' || _filter == 'internal') {
      items.removeWhere((e) => e.stock != null || e.crypto != null);
    }
    if (_filter == 'bourse') {
      items.removeWhere((e) => e.bank != null || e.crypto != null);
    }
    if (_filter == 'crypto') {
      items.removeWhere((e) => e.bank != null || e.stock != null);
    }
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final list = _combinedList();

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
                  label: const Text('Bourse'),
                  selected: _filter == 'bourse',
                  onSelected: (_) => setState(() => _filter = 'bourse'),
                ),
                FilterChip(
                  label: const Text('Crypto'),
                  selected: _filter == 'crypto',
                  onSelected: (_) => setState(() => _filter = 'crypto'),
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
                      final item = list[i];
                      if (item.crypto != null) {
                        final c = item.crypto!;
                        final total = (c['total'] as num?)?.toDouble() ?? 0.0;
                        final quantity = c['quantity'] as int? ?? 0;
                        final symbol = c['symbol'] as String? ?? '';
                        final name = c['name'] as String? ?? '';
                        final accountId = c['accountId'] as int?;
                        String accountLabel = '';
                        for (final a in widget.accounts) {
                          if (a.id == accountId) {
                            accountLabel = a.accountType;
                            break;
                          }
                        }
                        final parts = [if (accountLabel.isNotEmpty) accountLabel, name, dateFormat.format(item.date)].where((e) => e.toString().isNotEmpty);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.currency_bitcoin_rounded, color: DesignSystem.orange600),
                          title: Text('Achat Crypto: $quantity × $symbol'),
                          subtitle: Text(parts.join(' • ')),
                          trailing: Text(
                            '−${total.toStringAsFixed(2)} €',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: DesignSystem.gray700),
                          ),
                        );
                      }
                      if (item.stock != null) {
                        final s = item.stock!;
                        final total = (s['total'] as num?)?.toDouble() ?? 0.0;
                        final quantity = s['quantity'] as int? ?? 0;
                        final symbol = s['symbol'] as String? ?? '';
                        final name = s['name'] as String? ?? '';
                        final accountId = s['accountId'] as int?;
                        String accountLabel = '';
                        for (final a in widget.accounts) {
                          if (a.id == accountId) {
                            accountLabel = a.accountType;
                            break;
                          }
                        }
                        final parts = [if (accountLabel.isNotEmpty) accountLabel, name, dateFormat.format(item.date)].where((e) => e.toString().isNotEmpty);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.show_chart_rounded, color: DesignSystem.orange600),
                          title: Text('Achat Bourse: $quantity × $symbol'),
                          subtitle: Text(parts.join(' • ')),
                          trailing: Text(
                            '−${total.toStringAsFixed(2)} €',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: DesignSystem.gray700),
                          ),
                        );
                      }
                      final t = item.bank!;
                      final ids = widget.accounts.map((a) => a.id).toSet();
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

class _TransactionItem {
  final DateTime date;
  final Transaction? bank;
  final Map<String, dynamic>? stock;
  final Map<String, dynamic>? crypto;
  _TransactionItem({required this.date, this.bank, this.stock, this.crypto});
}
