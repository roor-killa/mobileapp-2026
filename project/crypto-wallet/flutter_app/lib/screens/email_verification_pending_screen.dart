import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/auth_provider.dart';

/// Écran affiché après inscription quand une vérification email est requise.
/// Supabase a envoyé un email avec un lien de confirmation.
class EmailVerificationPendingScreen extends StatelessWidget {
  const EmailVerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().pendingVerificationEmail ?? '';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_unread_rounded, size: 72, color: AppTheme.primary),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Vérifiez votre email',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nous avons envoyé un email de vérification à',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: const TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cliquez sur le lien dans l\'email pour activer votre compte. Vérifiez aussi vos spams.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _ResendButton(),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.read<AuthProvider>().clearPendingVerification(),
                  child: const Text('Retour à la connexion', style: TextStyle(color: AppTheme.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResendButton extends StatefulWidget {
  @override
  State<_ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends State<_ResendButton> {
  bool _loading = false;
  bool _cooldown = false;
  int _cooldownSecs = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    setState(() {
      _cooldown = true;
      _cooldownSecs = 60;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _cooldownSecs--);
      if (_cooldownSecs <= 0) {
        setState(() => _cooldown = false);
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loading || _cooldown
                ? null
                : () async {
                    setState(() => _loading = true);
                    try {
                      await context.read<AuthProvider>().resendVerificationEmail();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email renvoyé ! Vérifiez votre boîte mail.'),
                            backgroundColor: AppTheme.accent,
                          ),
                        );
                        _startCooldown();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceFirst('Exception: ', '')),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
            icon: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.refresh_rounded, size: 22),
            label: Text(_cooldown ? 'Renvoyer dans ${_cooldownSecs}s' : 'Renvoyer l\'email'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
      ],
    );
  }
}
