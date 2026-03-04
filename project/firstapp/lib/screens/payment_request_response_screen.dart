import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bank_service.dart';
import '../theme/design_system.dart';

/// Écran pour accepter ou refuser une demande d'argent reçue (depuis les notifications).
class PaymentRequestResponseScreen extends StatefulWidget {
  final Map<String, dynamic> paymentRequest;

  const PaymentRequestResponseScreen({super.key, required this.paymentRequest});

  @override
  State<PaymentRequestResponseScreen> createState() => _PaymentRequestResponseScreenState();
}

class _PaymentRequestResponseScreenState extends State<PaymentRequestResponseScreen> {
  final BankService _bankService = BankService();
  List<Account> _accounts = [];
  Account? _selectedAccount;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  int get _prId => (widget.paymentRequest['id'] as num?)?.toInt() ?? 0;
  String get _fromName => widget.paymentRequest['from_user_name'] as String? ?? 'Un utilisateur';
  double get _amount => (widget.paymentRequest['amount'] as num?)?.toDouble() ?? 0;
  String get _message => widget.paymentRequest['message'] as String? ?? '';
  String get _status => widget.paymentRequest['status'] as String? ?? 'pending';

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _loading = true);
    try {
      await _bankService.init();
      final accounts = await _bankService.getAccounts();
      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        _loading = false;
        if (accounts.isNotEmpty && _selectedAccount == null) {
          _selectedAccount = accounts.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _accept() async {
    if (_selectedAccount == null) {
      setState(() => _error = 'Choisissez un compte à débiter.');
      return;
    }
    if ((_selectedAccount!.balance) < _amount) {
      setState(() => _error = 'Solde insuffisant sur ce compte.');
      return;
    }
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _error = null;
      _submitting = true;
    });
    try {
      await _bankService.acceptPaymentRequest(_prId, _selectedAccount!.id);
      if (!mounted) return;
      nav.pop(true);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Virement effectué. Demande acceptée.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: DesignSystem.green500,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _decline() async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _error = null;
      _submitting = true;
    });
    try {
      await _bankService.declinePaymentRequest(_prId);
      if (!mounted) return;
      nav.pop(true);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Demande refusée.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = _status == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande d\'argent'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space24, vertical: DesignSystem.space16),
        children: [
          Container(
            padding: const EdgeInsets.all(DesignSystem.space24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            ),
            child: Column(
              children: [
                Text(
                  _fromName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'vous demande',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_amount.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: DesignSystem.indigo600,
                      ),
                ),
                if (_message.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _message,
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignSystem.red50,
                borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                border: Border.all(color: DesignSystem.red500.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: DesignSystem.red500, size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_error!, style: TextStyle(fontSize: 13, color: DesignSystem.red500))),
                ],
              ),
            ),
          ],
          if (!isPending) ...[
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _status == 'accepted' ? DesignSystem.green50 : DesignSystem.gray200,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _status == 'accepted' ? 'Demande acceptée' : 'Demande refusée',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _status == 'accepted' ? DesignSystem.green700 : DesignSystem.gray600,
                  ),
                ),
              ),
            ),
          ],
          if (isPending && !_loading) ...[
            const SizedBox(height: 24),
            Text(
              'Compte à débiter',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            ..._accounts.map((account) {
              final selected = _selectedAccount?.id == account.id;
              final hasEnough = account.balance >= _amount;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: selected ? DesignSystem.indigo50 : null,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                  child: InkWell(
                    onTap: hasEnough
                        ? () => setState(() => _selectedAccount = account)
                        : null,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(
                            selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                            color: hasEnough ? DesignSystem.indigo600 : DesignSystem.gray400,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.accountType,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '${account.balance.toStringAsFixed(2)} ${account.currency}',
                                  style: TextStyle(fontSize: 13, color: DesignSystem.gray500),
                                ),
                              ],
                            ),
                          ),
                          if (!hasEnough)
                            Text(
                              'Solde insuffisant',
                              style: TextStyle(fontSize: 12, color: DesignSystem.red500),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _accept,
                icon: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_circle_rounded, size: 22),
                label: Text(_submitting ? 'En cours…' : 'Accepter et payer'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: DesignSystem.green500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _submitting ? null : _decline,
                icon: const Icon(Icons.cancel_rounded, size: 22),
                label: const Text('Refuser'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: DesignSystem.red500,
                  side: const BorderSide(color: DesignSystem.red500),
                ),
              ),
            ),
          ],
          if (_loading && isPending)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
