import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pwd1 = TextEditingController();
  final _pwd2 = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  final api = SupabaseService();

  @override
  void dispose() {
    _pwd1.dispose();
    _pwd2.dispose();
    super.dispose();
  }

  void _snack(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await api.updatePassword(_pwd1.text);
      _snack('✅ Mot de passe mis à jour. Connecte-toi.');
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _snack('Erreur: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau mot de passe')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _pwd1,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6) ? '6 caractères minimum' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pwd2,
                obscureText: _obscure,
                decoration: const InputDecoration(labelText: 'Confirmer'),
                validator: (v) => (v != _pwd1.text) ? 'Les mots de passe ne correspondent pas' : null,
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Mettre à jour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
