import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/main_navigation.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey         = GlobalKey<FormState>();
  final _firstNameCtrl   = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _pinCtrl         = TextEditingController();
  bool _obscurePassword  = true;
  bool _obscurePin       = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose(); _lastNameCtrl.dispose();
    _emailCtrl.dispose();     _phoneCtrl.dispose();
    _passwordCtrl.dispose();  _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      firstName: _firstNameCtrl.text.trim(),
      lastName:  _lastNameCtrl.text.trim(),
      email:     _emailCtrl.text.trim(),
      phone:     _phoneCtrl.text.trim(),
      password:  _passwordCtrl.text,
      pin:       _pinCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Erreur lors de l\'inscription'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const Icon(Icons.person_add_rounded, size: 60, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text('Créer un compte',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Rejoignez TransfertApp aujourd\'hui',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                      // Prénom + Nom
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _firstNameCtrl,
                              label: 'Prénom',
                              hint: 'Jean',
                              prefixIcon: Icons.person_outline,
                              validator: (v) => v!.isEmpty ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _lastNameCtrl,
                              label: 'Nom',
                              hint: 'Dupont',
                              validator: (v) => v!.isEmpty ? 'Requis' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'Adresse email',
                        hint: 'jean@exemple.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v!.isEmpty) return 'Email requis';
                          if (!v.contains('@')) return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      CustomTextField(
                        controller: _phoneCtrl,
                        label: 'Numéro de téléphone',
                        hint: '0612345678',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 15,
                        validator: (v) {
                          if (v!.isEmpty) return 'Téléphone requis';
                          if (v.length < 10) return 'Numéro invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      CustomTextField(
                        controller: _passwordCtrl,
                        label: 'Mot de passe',
                        hint: 'Minimum 8 caractères',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v!.isEmpty) return 'Mot de passe requis';
                          if (v.length < 8) return 'Minimum 8 caractères';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // ── PIN ──────────────────────────────────────────────
                      CustomTextField(
                        controller: _pinCtrl,
                        label: 'PIN de transaction (4-6 chiffres)',
                        hint: '1234',
                        prefixIcon: Icons.pin_outlined,
                        obscureText: _obscurePin,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 6,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscurePin = !_obscurePin),
                        ),
                        validator: (v) {
                          if (v!.isEmpty) return 'PIN requis';
                          if (v.length < 4) return 'PIN minimum 4 chiffres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '🔒 Le PIN est utilisé pour valider vos transferts',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 32),

                      Consumer<AuthProvider>(
                        builder: (_, auth, __) => CustomButton(
                          label: 'Créer mon compte',
                          isLoading: auth.isLoading,
                          onPressed: _register,
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Déjà un compte ? ',
                              style: TextStyle(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text('Se connecter',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
