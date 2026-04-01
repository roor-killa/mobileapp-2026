import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ResetRequestScreen extends StatefulWidget {
  const ResetRequestScreen({super.key});

  @override
  State<ResetRequestScreen> createState() => _ResetRequestScreenState();
}

class _ResetRequestScreenState extends State<ResetRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;

  final api = SupabaseService();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _snack(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await api.sendPasswordResetEmail(_email.text.trim());
      _snack('📩 Email envoyé. Vérifie ta boîte mail (et les spams).');
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
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Envoyer le lien'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tu recevras un lien de réinitialisation.\n'
                'Selon ta config Supabase, le lien peut ouvrir le navigateur ou revenir dans l’app.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
