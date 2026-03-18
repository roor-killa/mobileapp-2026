import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/services/api_service.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _amountCtrl   = TextEditingController();
  final _pinCtrl      = TextEditingController();
  final _noteCtrl     = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _amountCtrl.dispose();
    _pinCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _transfer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final amountEuros = double.parse(_amountCtrl.text.replaceAll(',', '.'));
      final amountCents = (amountEuros * 100).round();
      final txProvider   = context.read<TransactionProvider>();
      final authProvider = context.read<AuthProvider>();
      await txProvider.transfer(
            receiverEmail: _emailCtrl.text.trim(),
            amountCents:   amountCents,
            pin:           _pinCtrl.text,
            note:          _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
          );
      await authProvider.refreshUser();
      await txProvider.loadHistory();
      if (mounted) {
        _formKey.currentState!.reset();
        _emailCtrl.clear();
        _amountCtrl.clear();
        _pinCtrl.clear();
        _noteCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfert effectué avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Envoyer de l\'argent')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ─── Carte solde ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Solde disponible',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      user?.balanceFormatted ?? '—',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ─── Email destinataire ───────────────────────────────────
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email du destinataire',
                  prefixIcon: Icon(Icons.person_search_outlined),
                ),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Email invalide' : null,
              ),
              const SizedBox(height: 16),

              // ─── Montant ──────────────────────────────────────────────
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Montant (€)',
                  prefixIcon: Icon(Icons.euro_outlined),
                  hintText: '10.00',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Montant requis';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Montant invalide';
                  if (n < 1) return 'Minimum 1,00 €';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ─── Note (optionnel) ─────────────────────────────────────
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note (optionnel)',
                  prefixIcon: Icon(Icons.note_outlined),
                  hintText: 'Ex: Remboursement repas',
                ),
              ),
              const SizedBox(height: 16),

              // ─── PIN ──────────────────────────────────────────────────
              TextFormField(
                controller: _pinCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Votre PIN',
                  prefixIcon: Icon(Icons.lock_outline),
                  counterText: '',
                ),
                validator: (v) =>
                    v == null || v.length != 6 ? 'PIN à 6 chiffres requis' : null,
              ),
              const SizedBox(height: 28),

              // ─── Bouton ───────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: _loading ? null : _transfer,
                icon: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: const Text('Envoyer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

