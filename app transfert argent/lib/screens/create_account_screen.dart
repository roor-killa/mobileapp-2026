import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bank_provider.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  State<CreateAccountScreen> createState() => _State();
}

class _State extends State<CreateAccountScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController(text: 'Compte courant');
  final _balCtrl   = TextEditingController(text: '0');
  bool _loading = false;

  @override
  void dispose() { _labelCtrl.dispose(); _balCtrl.dispose(); super.dispose(); }

  // ✅ CORRIGÉ : méthode async (createAccount est Future)
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final balance = double.tryParse(_balCtrl.text.replaceAll(',', '.')) ?? 0;
    final error = await context.read<BankProvider>().createAccount(_labelCtrl.text.trim(), balance);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red.shade700));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Compte créé !'), backgroundColor: Colors.green.shade700));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau compte')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(children: [
            const Icon(Icons.account_balance, size: 56, color: Color(0xFF1565C0)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _labelCtrl,
              decoration: const InputDecoration(labelText: 'Libellé du compte',
                  prefixIcon: Icon(Icons.label_outline)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Solde initial (€)',
                  prefixIcon: Icon(Icons.euro)),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                if (n == null || n < 0) return 'Montant invalide.';
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Créer le compte'),
                      onPressed: _submit),
            ),
          ]),
        ),
      ),
    );
  }
}