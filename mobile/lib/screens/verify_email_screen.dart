import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';
import 'app_shell.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sending = false;
  bool _checking = false;

  void _snack(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  bool _isConfirmed() {
    final u = Supabase.instance.client.auth.currentUser;
    try {
      // Supabase Dart SDK exposes emailConfirmedAt on User (nullable).
      final v = (u as dynamic).emailConfirmedAt;
      return v != null && v.toString().isNotEmpty;
    } catch (_) {
      // Fallback: if property is unavailable, assume not confirmed.
      return false;
    }
  }

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      // Resend signup confirmation email (requires email confirmations enabled in Supabase Auth settings).
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      _snack('📩 Email renvoyé. Vérifie ta boîte mail (et les spams).');
    } catch (e) {
      _snack('Erreur: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    try {
      // Refresh session/user
      await Supabase.instance.client.auth.refreshSession();
      if (!mounted) return;

      if (_isConfirmed()) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppShell()),
          (_) => false,
        );
      } else {
        _snack('Toujours pas confirmé. Ouvre le lien reçu par email puis reviens ici.');
      }
    } catch (e) {
      _snack('Erreur: $e');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérifie ton email')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Un email de confirmation a été envoyé à :', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            SelectableText(widget.email, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            const Text(
              '1) Ouvre le mail et clique sur le lien\n'
              '2) Reviens dans l’app\n'
              '3) Appuie sur “J’ai confirmé”',
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _checking ? null : _checkNow,
              icon: _checking ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.verified_outlined),
              label: const Text('J’ai confirmé'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _sending ? null : _resend,
              icon: _sending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.email_outlined),
              label: const Text('Renvoyer l’email'),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
