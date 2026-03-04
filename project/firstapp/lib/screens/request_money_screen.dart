import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bank_service.dart';
import '../theme/design_system.dart';

/// Écran "Demander de l'argent" (bouton Recevoir). Choisir un contact, montant, envoyer la demande → notification au destinataire.
class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  final BankService _bankService = BankService();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();

  List<BeneficiaryAccount> _beneficiaries = [];
  BeneficiaryAccount? _selected;
  bool _loading = true;
  bool _sending = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _bankService.getBeneficiaries();
      if (!mounted) return;
      setState(() {
        _beneficiaries = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _sendRequest() async {
    if (_selected == null || _selected!.ownerId == null) {
      setState(() => _error = 'Choisissez un destinataire.');
      return;
    }
    final amountStr = _amountController.text.trim().replaceFirst(',', '.');
    if (amountStr.isEmpty) {
      setState(() => _error = 'Entrez un montant.');
      return;
    }
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Montant invalide.');
      return;
    }

    setState(() {
      _error = null;
      _sending = true;
    });
    try {
      await _bankService.createPaymentRequest(
        toUserId: _selected!.ownerId!,
        amount: amount,
        message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _success = 'Demande de ${amount.toStringAsFixed(2)} € envoyée à ${_selected!.ownerName}. Il recevra une notification.';
        _amountController.clear();
        _messageController.clear();
        _selected = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demander de l\'argent'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space24, vertical: DesignSystem.space16),
        children: [
          if (_success != null)
            Container(
              padding: const EdgeInsets.all(DesignSystem.space16),
              margin: const EdgeInsets.only(bottom: DesignSystem.space16),
              decoration: BoxDecoration(
                color: DesignSystem.green50,
                borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                border: Border.all(color: DesignSystem.green500.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: DesignSystem.green600, size: 24),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_success!, style: TextStyle(color: DesignSystem.green700, fontSize: 14))),
                ],
              ),
            ),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(DesignSystem.space16),
              margin: const EdgeInsets.only(bottom: DesignSystem.space16),
              decoration: BoxDecoration(
                color: DesignSystem.red50,
                borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                border: Border.all(color: DesignSystem.red500.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: DesignSystem.red500, size: 24),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_error!, style: TextStyle(color: DesignSystem.red500, fontSize: 14))),
                ],
              ),
            ),
          Text(
            'À qui demander ?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_beneficiaries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aucun bénéficiaire. Ajoutez des comptes bénéficiaires pour pouvoir leur demander de l\'argent.',
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            )
          else
            ..._beneficiaries.where((b) => b.ownerId != null).map((b) {
              final isSelected = _selected?.id == b.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isSelected ? DesignSystem.indigo50 : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                  child: InkWell(
                    onTap: () => setState(() => _selected = b),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: DesignSystem.indigo200,
                            child: Text(
                              b.ownerName.isNotEmpty ? b.ownerName.substring(0, 1).toUpperCase() : '?',
                              style: const TextStyle(color: DesignSystem.indigo600, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.ownerName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                                Text('${b.accountType} • ${b.iban}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          if (isSelected) Icon(Icons.check_circle_rounded, color: DesignSystem.indigo600, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 24),
          Text(
            'Montant (€)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0,00',
              prefixText: '€ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusMd)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Message (optionnel)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Ex: Remboursement repas',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusMd)),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sending ? null : _sendRequest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: DesignSystem.purple500,
                foregroundColor: Colors.white,
              ),
              child: _sending
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Envoyer la demande'),
            ),
          ),
        ],
      ),
    );
  }
}
