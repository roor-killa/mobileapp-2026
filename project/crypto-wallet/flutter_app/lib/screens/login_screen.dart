import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) {
      _showError('Veuillez remplir tous les champs.');
      return;
    }
    if (_isRegister && _name.text.trim().isEmpty) {
      _showError('Veuillez entrer votre nom.');
      return;
    }
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      if (_isRegister) {
        await auth.register(_email.text.trim(), _password.text, _name.text.trim());
      } else {
        await auth.login(_email.text.trim(), _password.text);
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppTheme.primary),
                const SizedBox(height: 16),
                const Text('NodEX', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  _isRegister ? 'Créez votre compte' : 'Connectez-vous à votre portefeuille',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 40),
                if (_isRegister) ...[
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nom complet', prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary)),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary)),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_isRegister ? "S'inscrire" : 'Se connecter'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isRegister = !_isRegister),
                  child: Text(_isRegister ? 'Déjà un compte ? Se connecter' : "Pas de compte ? S'inscrire", style: const TextStyle(color: AppTheme.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
