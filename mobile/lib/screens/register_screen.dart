import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'verify_email_screen.dart';
import 'app_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _tel = TextEditingController();
  final _email = TextEditingController();
  final _pwd = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  final api = SupabaseService();

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _tel.dispose();
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  void _snack(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await api.signUp(
        email: _email.text.trim(),
        password: _pwd.text,
        nom: _nom.text.trim(),
        prenom: _prenom.text.trim(),
        telephone: _tel.text.trim(),
      );
      if (!mounted) return;
      _snack('✅ Compte créé. Bienvenue !');

      final user = Supabase.instance.client.auth.currentUser;
      final confirmed = (() {
        try {
          final v = (user as dynamic).emailConfirmedAt;
          return v != null && v.toString().isNotEmpty;
        } catch (_) {
          return true; // if SDK doesn't expose it, don't block.
        }
      })();

      if (!confirmed && user?.email != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: user!.email!)),
          (_) => false,
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    } catch (e) {
      _snack('Erreur inscription: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Créer un compte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nom,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Nom invalide' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _prenom,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Prénom invalide' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _tel,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().length < 6) ? 'Téléphone invalide' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Email requis';
                      final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
                      return ok ? null : 'Email invalide';
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _pwd,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 caractères' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Envoyer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
