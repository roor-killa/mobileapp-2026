import 'package:flutter/material.dart';
import '../services/bank_service.dart';
import '../theme/design_system.dart';

/// Écran en 2 étapes : 1) Saisie email → envoi du code  2) Code + nouveau mot de passe.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final BankService _bankService = BankService();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _step2 = false; // false = demande email, true = code + nouveau mdp
  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _showPassword = false;
  bool _showPasswordConfirm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre adresse email.';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _bankService.requestPasswordReset(email);
      if (!mounted) return;
      setState(() {
        _step2 = true;
        _loading = false;
        _successMessage = 'Si un compte existe avec cette adresse, vous avez reçu un code par email. Entrez-le ci-dessous.';
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _successMessage = null;
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirm = _passwordConfirmController.text;

    if (token.isEmpty) {
      setState(() => _errorMessage = 'Veuillez entrer le code reçu par email.');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage = 'Le mot de passe doit contenir au moins 8 caractères.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Les deux mots de passe ne correspondent pas.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await _bankService.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: confirm,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final nav = Navigator.of(context);
      setState(() => _loading = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Mot de passe réinitialisé. Vous pouvez vous connecter.'),
          backgroundColor: DesignSystem.green500,
        ),
      );
      nav.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: DesignSystem.gray900,
        ),
        title: const Text(
          'Mot de passe oublié',
          style: TextStyle(color: DesignSystem.gray900, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_step2) ...[
                const Text(
                  'Saisissez l’adresse email de votre compte. Nous vous enverrons un code pour réinitialiser votre mot de passe.',
                  style: TextStyle(fontSize: 14, color: DesignSystem.gray500, height: 1.4),
                ),
                const SizedBox(height: 24),
                _buildField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.mail_outline_rounded,
                ),
                if (_errorMessage != null) _buildError(_errorMessage!),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.indigo600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Envoyer le code', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: DesignSystem.green50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: DesignSystem.green400.withValues(alpha: 0.5)),
                    ),
                    child: Text(_successMessage!, style: const TextStyle(fontSize: 13, color: DesignSystem.green700)),
                  ),
                _buildField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress, icon: Icons.mail_outline_rounded, readOnly: true),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Code reçu par email',
                  controller: _tokenController,
                  icon: Icons.key_rounded,
                  hint: 'Collez le code reçu',
                ),
                const SizedBox(height: 16),
                _buildPasswordField(label: 'Nouveau mot de passe', controller: _passwordController, show: _showPassword, onToggle: () => setState(() => _showPassword = !_showPassword)),
                const SizedBox(height: 16),
                _buildPasswordField(label: 'Confirmer le mot de passe', controller: _passwordConfirmController, show: _showPasswordConfirm, onToggle: () => setState(() => _showPasswordConfirm = !_showPasswordConfirm)),
                if (_errorMessage != null) _buildError(_errorMessage!),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.indigo600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Réinitialiser le mot de passe', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _step2 = false;
                    _errorMessage = null;
                    _successMessage = null;
                    _tokenController.clear();
                    _passwordController.clear();
                    _passwordConfirmController.clear();
                  }),
                  child: const Text('Utiliser une autre adresse email', style: TextStyle(color: DesignSystem.indigo600)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 20, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.error))),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesignSystem.gray600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint ?? label,
            prefixIcon: Icon(icon, size: 20, color: DesignSystem.gray400),
            filled: true,
            fillColor: DesignSystem.gray50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: DesignSystem.indigo600, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool show,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesignSystem.gray600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: !show,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: DesignSystem.gray400),
            suffixIcon: IconButton(
              icon: Icon(show ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: DesignSystem.gray400),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: DesignSystem.gray50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: DesignSystem.indigo600, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
