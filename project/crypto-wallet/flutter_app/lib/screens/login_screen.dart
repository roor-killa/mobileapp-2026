import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/security_provider.dart';

/// Méthode d'authentification choisie par l'utilisateur.
enum AuthMethod { emailPassword, emailOTP, phone, magicURL }

/// Retourne un score de force du mot de passe (0-4).
int _passwordStrength(String pwd) {
  if (pwd.isEmpty) return 0;
  int score = 0;
  if (pwd.length >= 8) score++;
  if (pwd.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(pwd) && RegExp(r'[a-z]').hasMatch(pwd)) score++;
  if (RegExp(r'[0-9]').hasMatch(pwd) || RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pwd)) score++;
  return score.clamp(0, 4);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _otpCode = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  AuthMethod _authMethod = AuthMethod.emailPassword;
  String? _pendingOTPUserId; // userId retourné après envoi du code (Email OTP ou Phone)

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _name.dispose();
    _phone.dispose();
    _otpCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final sec = context.read<SecurityProvider>();

    // Flux OTP : étape 2 (vérification du code)
    if (_pendingOTPUserId != null) {
      final code = _otpCode.text.trim();
      if (code.isEmpty) {
        _showError('Veuillez entrer le code reçu.');
        return;
      }
      setState(() => _loading = true);
      try {
        if (_authMethod == AuthMethod.emailOTP) {
          await auth.verifyEmailOTP(_pendingOTPUserId!, code);
        } else {
          await auth.verifyPhoneOTP(_pendingOTPUserId!, code);
        }
        if (mounted) {
          sec.addLog('login', 'Connexion réussie');
          setState(() => _pendingOTPUserId = null);
        }
      } catch (e) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }

    // Flux OTP : étape 1 (envoi du code)
    if (_authMethod == AuthMethod.emailOTP) {
      final email = _email.text.trim();
      if (email.isEmpty) {
        _showError('Veuillez entrer votre email.');
        return;
      }
      setState(() => _loading = true);
      try {
        final userId = await auth.sendEmailOTP(email);
        if (mounted) setState(() => _pendingOTPUserId = userId);
      } catch (e) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }

    if (_authMethod == AuthMethod.phone) {
      final phone = _phone.text.trim();
      if (phone.isEmpty) {
        _showError('Veuillez entrer votre numéro de téléphone.');
        return;
      }
      setState(() => _loading = true);
      try {
        final userId = await auth.sendPhoneOTP(phone);
        if (mounted) setState(() => _pendingOTPUserId = userId);
      } catch (e) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }

    if (_authMethod == AuthMethod.magicURL) {
      final email = _email.text.trim();
      if (email.isEmpty) {
        _showError('Veuillez entrer votre email.');
        return;
      }
      setState(() => _loading = true);
      try {
        await auth.sendMagicURLToken(email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Un lien de connexion a été envoyé à $email. Cliquez sur le lien dans l\'email.'),
              backgroundColor: AppTheme.accent,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }

    // Flux Email/Mot de passe
    final email = _email.text.trim();
    final pwd = _password.text;
    final pwdConfirm = _passwordConfirm.text;

    if (email.isEmpty || pwd.isEmpty) {
      _showError('Veuillez remplir tous les champs.');
      return;
    }
    if (_isRegister) {
      if (_name.text.trim().isEmpty) {
        _showError('Veuillez entrer votre nom.');
        return;
      }
      if (pwd.length < 8) {
        _showError('Le mot de passe doit contenir au moins 8 caractères.');
        return;
      }
      if (pwd != pwdConfirm) {
        _showError('Les mots de passe ne correspondent pas.');
        return;
      }
      if (!_acceptTerms) {
        _showError('Veuillez accepter les conditions d\'utilisation.');
        return;
      }
    }

    setState(() => _loading = true);
    try {
      if (_isRegister) {
        await auth.register(email, pwd, _name.text.trim());
        if (mounted && auth.pendingVerificationEmail == null) {
          sec.addLog('login', 'Inscription réussie');
        }
      } else {
        if (sec.isLoginLocked) {
          _showError(
            'Connexion bloquée sur cet appareil : trop de mots de passe incorrects. '
            'Attendez ${sec.remainingLockMinutes} min ou utilisez « Débloquer sur cet appareil » ci-dessous.',
          );
          return;
        }
        await auth.login(email, pwd);
        await sec.resetFailedAttempts();
        if (mounted) sec.addLog('login', 'Connexion réussie');
      }
    } catch (e) {
      if (!_isRegister && mounted) {
        final locked = await context.read<SecurityProvider>().recordFailedLogin();
        if (locked) {
          _showError('Trop de tentatives échouées. Compte verrouillé 15 minutes.');
        } else {
          _showError(e.toString().replaceFirst('Exception: ', ''));
        }
      } else {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _email.text.trim());
    bool loading = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: AppTheme.primary),
              SizedBox(width: 12),
              Text('Mot de passe oublié', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Entrez votre adresse email. Nous vous enverrons un lien pour réinitialiser votre mot de passe.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez entrer votre email'), backgroundColor: Colors.redAccent),
                        );
                        return;
                      }
                      setDialogState(() => loading = true);
                      try {
                        await context.read<AuthProvider>().requestPasswordReset(email);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email envoyé ! Vérifiez votre boîte mail.'),
                              backgroundColor: AppTheme.accent,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => loading = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceFirst('Exception: ', '')),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
              child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pwdStrength = _passwordStrength(_password.text);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.loginBackgroundDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandIconGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      boxShadow: AppTheme.cardShadowStrong,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, size: 52, color: Color(0xFF042028)),
                  ),
                  const SizedBox(height: 22),
                  const Text('NodEX', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -1)),
                  const SizedBox(height: 6),
                  Text(
                    'Votre portefeuille crypto, simple et sécurisé',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 15, fontWeight: FontWeight.w500, height: 1.35),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _pendingOTPUserId != null
                        ? 'Entrez le code reçu'
                        : (_isRegister ? 'Créez votre compte' : 'Connectez-vous à votre portefeuille'),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                  ),
                  const SizedBox(height: 22),
                  Consumer<SecurityProvider>(
                    builder: (context, sec, _) {
                      if (!sec.isLoginLocked) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: AppTheme.warningSurface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(color: AppTheme.warningBorder.withValues(alpha: 0.6)),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.schedule_rounded, color: AppTheme.warningText, size: 22),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Protection NodEX : après 5 essais incorrects, l’app attend ${sec.remainingLockMinutes} min. Ce n’est pas un « mot de passe oublié » côté serveur.',
                                        style: const TextStyle(color: AppTheme.warningText, fontSize: 13, height: 1.35),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Débloquer sur cet appareil ?'),
                                          content: const Text(
                                            'Cela efface uniquement le compteur sur ce navigateur. '
                                            'Utilisez-le si vous êtes sûr de votre mot de passe Appwrite.',
                                          ),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Débloquer')),
                                          ],
                                        ),
                                      );
                                      if (ok == true && context.mounted) {
                                        await context.read<SecurityProvider>().clearLoginLockOnDevice();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Vous pouvez réessayer de vous connecter.'), backgroundColor: AppTheme.accent),
                                          );
                                        }
                                      }
                                    },
                                    child: Text('Débloquer sur cet appareil', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Material(
                    color: AppTheme.card,
                    elevation: 0,
                    shadowColor: Colors.black26,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        border: Border.all(color: AppTheme.border.withOpacity(0.6)),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                if (_pendingOTPUserId == null) ...[
                  _buildMethodSelector(),
                  const SizedBox(height: 24),
                ],
                if (_pendingOTPUserId != null) ...[
                  Text(
                    _authMethod == AuthMethod.emailOTP
                        ? 'Un code à 6 chiffres a été envoyé à ${_email.text.trim()}'
                        : 'Un code a été envoyé au ${_phone.text.trim()}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _otpCode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'Code à 6 chiffres',
                      prefixIcon: Icon(Icons.pin_outlined, color: AppTheme.textSecondary),
                      counterText: '',
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, letterSpacing: 8),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _pendingOTPUserId = null),
                    child: const Text('Retour', style: TextStyle(color: AppTheme.primary)),
                  ),
                  const SizedBox(height: 16),
                ] else if (_authMethod == AuthMethod.emailPassword) ...[
                  if (_isRegister)
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Nom complet', prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary)),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  if (_isRegister) const SizedBox(height: 16),
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
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: _isRegister ? 'Min. 8 caractères' : null,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                if (_isRegister && _password.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(4, (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i < pwdStrength ? _strengthColor(pwdStrength) : AppTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _strengthLabel(pwdStrength),
                    style: TextStyle(color: _strengthColor(pwdStrength), fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_isRegister) ...[
                  TextField(
                    controller: _passwordConfirm,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      prefixIcon: const Icon(Icons.lock_rounded, color: AppTheme.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _acceptTerms,
                          onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                          activeColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                          child: const Text(
                            'J\'accepte les conditions d\'utilisation et la politique de confidentialité de NodEX.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                ] else if (_authMethod == AuthMethod.emailOTP) ...[
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Un code à 6 chiffres sera envoyé à votre email.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                ] else if (_authMethod == AuthMethod.phone) ...[
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      hintText: '+33612345678',
                      prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.textSecondary),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Un code sera envoyé par SMS. Format : +33XXXXXXXXX (indicatif pays requis).',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                ] else if (_authMethod == AuthMethod.magicURL) ...[
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Un lien de connexion sera envoyé à votre email. Cliquez dessus pour vous connecter.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_authMethod == AuthMethod.emailPassword && !_isRegister)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: const Text('Mot de passe oublié ?', style: TextStyle(color: AppTheme.primary, fontSize: 14)),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _loading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                            _pendingOTPUserId != null
                                ? 'Vérifier'
                                : (_authMethod == AuthMethod.emailOTP || _authMethod == AuthMethod.phone)
                                    ? 'Envoyer le code'
                                    : (_authMethod == AuthMethod.magicURL)
                                        ? 'Envoyer le lien'
                                        : (_isRegister ? "S'inscrire" : 'Se connecter'),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_authMethod == AuthMethod.emailPassword)
                  TextButton(
                    onPressed: () => setState(() => _isRegister = !_isRegister),
                    child: Text(_isRegister ? 'Déjà un compte ? Se connecter' : "Pas de compte ? S'inscrire", style: const TextStyle(color: AppTheme.primary)),
                  ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _strengthColor(int s) {
    if (s <= 1) return Colors.redAccent;
    if (s == 2) return Colors.orange;
    if (s == 3) return AppTheme.accent;
    return AppTheme.accent;
  }

  String _strengthLabel(int s) {
    if (s <= 1) return 'Faible';
    if (s == 2) return 'Moyen';
    if (s == 3) return 'Bon';
    return 'Très bon';
  }

  Widget _buildMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.border.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _methodChip(AuthMethod.emailPassword, Icons.email_outlined, 'Email'),
          _methodChip(AuthMethod.emailOTP, Icons.mark_email_read_outlined, 'Code'),
          _methodChip(AuthMethod.phone, Icons.phone_android_outlined, 'SMS'),
          _methodChip(AuthMethod.magicURL, Icons.link_rounded, 'Lien'),
        ],
      ),
    );
  }

  Widget _methodChip(AuthMethod method, IconData icon, String label) {
    final selected = _authMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _authMethod = method;
          if (method != AuthMethod.emailPassword) _isRegister = false;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: selected ? AppTheme.primary : AppTheme.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
