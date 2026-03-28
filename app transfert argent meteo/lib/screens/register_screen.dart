import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/bank_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _balanceCtrl   = TextEditingController(text: '1000');
  bool _obscure = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose(); _lastNameCtrl.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose(); _balanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final balance = double.tryParse(_balanceCtrl.text.replaceAll(',', '.')) ?? 1000.0;

    // ✅ CORRIGÉ : appel avec la bonne signature (firstName, lastName, email, password, initialBalance)
    final ok = await auth.register(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      initialBalance: balance,
    );
    if (!mounted) return;
    if (ok) {
      await context.read<BankProvider>().loadAll();
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      final errorMsg = auth.error ?? 'Une erreur est survenue.';
      final isEmailTaken = errorMsg.toLowerCase().contains('already') ||
                          errorMsg.toLowerCase().contains('email') ||
                          errorMsg.toLowerCase().contains('exist');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isEmailTaken
            ? 'Cette adresse email est déjà utilisée.'
            : errorMsg),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Icon(Icons.person_add_outlined, size: 56, color: Color(0xFF1565C0)),
              const SizedBox(height: 24),
              // ✅ CORRIGÉ : deux champs séparés prénom / nom
              Row(children: [
                Expanded(child: TextFormField(
                  controller: _firstNameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis.' : null,
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _lastNameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis.' : null,
                )),
              ]),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis.';
                  if (!v.contains('@')) return 'Email invalide.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6) ? 'Min. 6 caractères.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Solde initial (€)',
                    prefixIcon: Icon(Icons.euro)),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (n == null || n < 0) return 'Montant invalide.';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              auth.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _register, child: const Text("S'inscrire")),
            ]),
          ),
        ),
      ),
    );
  }
}