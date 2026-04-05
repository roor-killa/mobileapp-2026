import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/pin_dialog.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose(); _amountCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final pin = await PinDialog.show(context,
        title: 'Confirmer le transfert',
        subtitle: 'Entrez votre PIN pour envoyer ${_amountCtrl.text}€');
    if (pin == null || !mounted) return;

    final txProvider = context.read<TransactionProvider>();
    final result = await txProvider.sendMoney(
      receiverEmail: _emailCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
      pin: pin,
      description: _descCtrl.text.trim(),
    );

    if (!mounted) return;

    if (result != null) {
      final newBalance = (result['new_balance'] as num?)?.toDouble();
      if (newBalance != null) {
        context.read<AuthProvider>().updateBalance(newBalance);
      }
      // Rafraîchir le dashboard et l'historique
      context.read<DashboardProvider>().loadDashboard();
      context.read<TransactionProvider>().loadTransactions(refresh: true);
      _showSuccess(result['message'] ?? 'Transfert réussi !');
    } else {
      _showError(txProvider.error ?? 'Erreur lors du transfert');
    }
  }

  void _showSuccess(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFE8FFF6), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 20),
            const Text('Transfert réussi !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(msg, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Retour',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<AuthProvider>().user?.balance ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Envoyer de l\'argent',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Solde disponible
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Solde disponible',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text('${balance.toStringAsFixed(2)} €',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              CustomTextField(
                controller: _emailCtrl,
                label: 'Email du destinataire',
                hint: 'exemple@email.com',
                prefixIcon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.isEmpty) return 'Email requis';
                  if (!v.contains('@') || !v.contains('.')) return 'Email invalide';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              CustomTextField(
                controller: _amountCtrl,
                label: 'Montant (€)',
                hint: '50.00',
                prefixIcon: Icons.euro_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}'))],
                validator: (v) {
                  if (v!.isEmpty) return 'Montant requis';
                  final amount = double.tryParse(v.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) return 'Montant invalide';
                  if (amount > balance) return 'Solde insuffisant';
                  if (amount > 1000) return 'Maximum 1 000€ par transfert';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              CustomTextField(
                controller: _descCtrl,
                label: 'Description (optionnel)',
                hint: 'Remboursement restaurant...',
                prefixIcon: Icons.note_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Le destinataire doit être inscrit sur TransfertApp. Votre PIN sera demandé pour valider.',
                        style: TextStyle(color: AppColors.warning, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Consumer<TransactionProvider>(
                builder: (_, tx, __) => CustomButton(
                  label: 'Envoyer',
                  isLoading: tx.isSending,
                  icon: Icons.send_rounded,
                  onPressed: _send,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
