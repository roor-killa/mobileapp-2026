import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/main_navigation.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()));
    } else {
      _showError(auth.error ?? 'Identifiants incorrects');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header gradient ──────────────────────────────────────────
              Container(
                height: 280,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        size: 72, color: Colors.white),
                    SizedBox(height: 16),
                    Text('TransfertApp',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    SizedBox(height: 8),
                    Text('Connectez-vous à votre compte',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),

              // ── Formulaire ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text('Connexion',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      const Text('Bon retour parmi nous !',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 28),

                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'Adresse email',
                        hint: 'jean@exemple.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v!.isEmpty ? 'Email requis' : null,
                      ),
                      const SizedBox(height: 18),

                      CustomTextField(
                        controller: _passwordCtrl,
                        label: 'Mot de passe',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Mot de passe requis' : null,
                      ),
                      const SizedBox(height: 32),

                      Consumer<AuthProvider>(
                        builder: (_, auth, __) => CustomButton(
                          label: 'Se connecter',
                          isLoading: auth.isLoading,
                          onPressed: _login,
                        ),
                      ),
                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Pas encore de compte ? ',
                              style: TextStyle(
                                  color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const RegisterPage())),
                            child: const Text("S'inscrire",
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
