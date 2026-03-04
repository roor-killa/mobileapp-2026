import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/bank_service.dart';
import '../theme/design_system.dart';

class AccountDetailsScreen extends StatefulWidget {
  final Account account;
  final VoidCallback? onAccountDeleted;

  const AccountDetailsScreen({super.key, required this.account, this.onAccountDeleted});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final BankService _bankService = BankService();

  bool _loading = true;
  bool _deleting = false;
  String? _error;
  List<Transaction> _transactions = const [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _bankService.init();
    await _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tx = await _bankService.getAccountTransactions(widget.account.id);
      setState(() => _transactions = tx);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currency = widget.account.currency;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final canDelete = widget.account.balance == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.accountType),
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _deleting ? null : () => _confirmDelete(context),
              tooltip: 'Supprimer le compte',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.accountNumber,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.account.balance.toStringAsFixed(2)} $currency',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'IBAN: ${widget.account.iban}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 18),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Card(
                color: scheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    _error!,
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              )
            else if (_transactions.isEmpty)
              Text('Aucune transaction.', style: TextStyle(color: scheme.onSurfaceVariant))
            else
              ..._transactions.map((t) {
                final isOutgoing = t.fromAccountId == widget.account.id;
                final sign = isOutgoing ? '-' : '+';
                final color = isOutgoing ? scheme.error : scheme.tertiary;
                final counterparty = isOutgoing ? (t.toOwnerName ?? 'Bénéficiaire') : (t.fromOwnerName ?? 'Compte externe');
                final label = isOutgoing ? 'Sortant' : 'Entrant';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(isOutgoing ? Icons.call_made : Icons.call_received, color: color),
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
                  subtitle: Text('${dateFormat.format(t.transactionDate)} • ${isOutgoing ? 'À' : 'De'} $counterparty'),
                  trailing: Text(
                    '$sign${t.amount.toStringAsFixed(2)} $currency',
                    style: TextStyle(fontWeight: FontWeight.w800, color: color),
                  ),
                );
              }),
            if (canDelete) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: _deleting ? null : () => _confirmDelete(context),
                  icon: _deleting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.delete_outline_rounded),
                  label: Text(_deleting ? 'Suppression…' : 'Supprimer ce compte'),
                  style: OutlinedButton.styleFrom(foregroundColor: DesignSystem.red500, side: const BorderSide(color: DesignSystem.red500)),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final nav = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le compte ?'),
        content: Text(
          'Le compte ${widget.account.accountType} (${widget.account.accountNumber}) sera définitivement supprimé. Cette action est irréversible.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: DesignSystem.red500, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await _bankService.deleteAccount(widget.account.id);
      if (!mounted) return;
      widget.onAccountDeleted?.call();
      nav.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }
}

