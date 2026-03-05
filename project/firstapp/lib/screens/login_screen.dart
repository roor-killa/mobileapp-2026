import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/bank_service.dart';
import 'dashboard_screen.dart';
import 'forgot_password_screen.dart';
import '../theme/design_system.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final BankService _bankService = BankService();
  
  late TextEditingController _firstNameController,
      _lastNameController,
      _emailController,
      _phoneController,
      _passwordController,
      _passwordConfirmController;

  bool _isLoading = false;
  String? _errorMessage;
  /// Étape d'affichage (design Figma) : welcome → login ou register
  String _step = 'welcome'; // 'welcome' | 'login' | 'register'
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _bankService.init();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _bankService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _passwordConfirmController.text) {
        setState(() => _errorMessage = 'Les mots de passe ne correspondent pas');
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _bankService.register(
          _firstNameController.text,
          _lastNameController.text,
          _emailController.text,
          _phoneController.text,
          _passwordController.text,
          _passwordConfirmController.text,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _fillDemo(String email) {
    _emailController.text = email;
    _passwordController.text = 'password123';
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_step == 'welcome') {
      return Scaffold(
        backgroundColor: DesignSystem.white,
        body: SafeArea(
          child: _buildWelcomeStep(context),
        ),
      );
    }
    return Scaffold(
      backgroundColor: DesignSystem.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: _step == 'login' ? _buildLoginStep(context, scheme) : _buildRegisterStep(context, scheme),
          ),
        ),
      ),
    );
  }

  /// Écran d'accueil Figma : hero gradient + panneau blanc avec boutons
  Widget _buildWelcomeStep(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFA855F7)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Center(child: Text('🏦', style: TextStyle(fontSize: 36))),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'MyBank',
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Votre banque mobile, comptes et virements.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: DesignSystem.indigo200, fontSize: 15, height: 1.5),
                        ),
                        const SizedBox(height: 48),
                        _buildWelcomeCards(),
                      ],
                    ),
                  ),
                  Positioned(top: -64, right: -64, child: _buildDecoCircle(224)),
                  Positioned(top: 96, left: -48, child: _buildDecoCircle(160)),
                  Positioned(bottom: -40, right: 40, child: _buildDecoCircle(128)),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Transform.translate(
            offset: const Offset(0, 28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: const BoxDecoration(
                color: DesignSystem.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bonjour 👋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: DesignSystem.gray900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gérez vos finances en toute sécurité.',
                style: TextStyle(fontSize: 14, color: DesignSystem.gray400),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _step = 'login';
                    _errorMessage = null;
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.indigo600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Se connecter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _step = 'register';
                    _errorMessage = null;
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignSystem.indigo600,
                    side: const BorderSide(color: DesignSystem.indigo200),
                    backgroundColor: DesignSystem.indigo50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Créer un compte', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(() {
                  _step = 'register';
                  _errorMessage = null;
                }),
                child: const Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Pas encore de compte ? ",
                      style: TextStyle(fontSize: 12, color: DesignSystem.gray400),
                      children: [
                        TextSpan(text: 'Créer un compte', style: TextStyle(fontWeight: FontWeight.w600, color: DesignSystem.indigo600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    ],
    );
  }

  Widget _buildDecoCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
    );
  }

  Widget _buildWelcomeCards() {
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-24, 20),
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 240,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('•••• •••• •••• 7832', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 8),
                    const Text('3 240,00 €', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(24, 0),
            child: Transform.rotate(
              angle: 0.07,
              child: Container(
                width: 240,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('•••• •••• •••• 4291', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 8),
                    const Text('12 849,50 €', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginStep(BuildContext context, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => setState(() => _step = 'welcome'),
          child: const Text('← Retour', style: TextStyle(fontSize: 14, color: DesignSystem.indigo600)),
        ),
        const SizedBox(height: 24),
        const Text('Connexion', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: DesignSystem.gray900)),
        const SizedBox(height: 4),
        const Text('Entrez vos identifiants pour accéder à votre espace.', style: TextStyle(fontSize: 14, color: DesignSystem.gray400)),
        const SizedBox(height: 32),
        if (kDebugMode)
          _buildDemoChips(scheme),
        if (_errorMessage != null) _buildErrorBanner(scheme),
        _buildFigmaField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          icon: Icons.mail_outline_rounded,
          validator: (v) => (v?.isEmpty ?? true) ? 'Veuillez entrer votre email' : null,
        ),
        const SizedBox(height: 16),
        const Text('Mot de passe', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesignSystem.gray600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: !_showPassword,
          validator: (v) => (v?.isEmpty ?? true) ? 'Veuillez entrer votre mot de passe' : null,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: DesignSystem.gray400),
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: DesignSystem.gray400),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
            filled: true,
            fillColor: DesignSystem.gray50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: DesignSystem.indigo600, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
            },
            child: const Text('Mot de passe oublié ?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: DesignSystem.indigo600)),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.indigo600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Se connecter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() {
            _step = 'register';
            _errorMessage = null;
          }),
          child: const Center(
            child: Text.rich(
              TextSpan(
                text: "Pas encore de compte ? ",
                style: TextStyle(fontSize: 12, color: DesignSystem.gray400),
                children: [
                  TextSpan(text: 'Créer un compte', style: TextStyle(fontWeight: FontWeight.w600, color: DesignSystem.indigo600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterStep(BuildContext context, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => setState(() => _step = 'welcome'),
          child: const Text('← Retour', style: TextStyle(fontSize: 14, color: DesignSystem.indigo600)),
        ),
        const SizedBox(height: 24),
        const Text('Créer un compte', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: DesignSystem.gray900)),
        const SizedBox(height: 4),
        const Text('Remplissez le formulaire pour vous inscrire.', style: TextStyle(fontSize: 14, color: DesignSystem.gray400)),
        const SizedBox(height: 32),
        if (_errorMessage != null) _buildErrorBanner(scheme),
        _buildFigmaField(label: 'Prénom', controller: _firstNameController, icon: Icons.person_outline_rounded, validator: (v) => (v?.isEmpty ?? true) ? 'Veuillez entrer votre prénom' : null),
        const SizedBox(height: 16),
        _buildFigmaField(label: 'Nom', controller: _lastNameController, icon: Icons.person_outline_rounded, validator: (v) => (v?.isEmpty ?? true) ? 'Veuillez entrer votre nom' : null),
        const SizedBox(height: 16),
        _buildFigmaField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress, icon: Icons.mail_outline_rounded, validator: (v) => (v?.isEmpty ?? true) ? 'Veuillez entrer votre email' : null),
        const SizedBox(height: 16),
        _buildFigmaField(label: 'Téléphone', controller: _phoneController, keyboardType: TextInputType.phone, icon: Icons.phone_outlined, validator: (v) => (v?.isEmpty ?? true) ? 'Veuillez entrer votre téléphone' : null),
        const SizedBox(height: 16),
        _buildFigmaPasswordField(
          label: 'Mot de passe',
          controller: _passwordController,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Veuillez entrer votre mot de passe';
            if (v.length < 8) return 'Le mot de passe doit contenir au moins 8 caractères';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFigmaPasswordField(
          label: 'Confirmer le mot de passe',
          controller: _passwordConfirmController,
          validator: (v) => (v?.isEmpty ?? true) ? 'Veuillez confirmer votre mot de passe' : null,
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.indigo600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("S'inscrire", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() {
            _step = 'login';
            _errorMessage = null;
          }),
          child: const Center(
            child: Text.rich(
              TextSpan(
                text: 'Vous avez déjà un compte ? ',
                style: TextStyle(fontSize: 12, color: DesignSystem.gray400),
                children: [
                  TextSpan(text: 'Se connecter', style: TextStyle(fontWeight: FontWeight.w600, color: DesignSystem.indigo600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoChips(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DesignSystem.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DesignSystem.gray200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Connexion rapide (tests)', style: TextStyle(fontWeight: FontWeight.w800, color: DesignSystem.gray900)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(label: const Text('Jean Dupont'), onPressed: () => _fillDemo('jean.dupont@example.com')),
                ActionChip(label: const Text('Marie Martin'), onPressed: () => _fillDemo('marie.martin@example.com')),
                ActionChip(label: const Text('Pierre Bernard'), onPressed: () => _fillDemo('pierre.bernard@example.com')),
                ActionChip(label: const Text('Sophie Lefebvre'), onPressed: () => _fillDemo('sophie.lefebvre@example.com')),
              ],
            ),
            const SizedBox(height: 6),
            const Text("Mot de passe: password123", style: TextStyle(color: DesignSystem.gray500, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: DesignSystem.red50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignSystem.red500.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 20, color: scheme.error),
          const SizedBox(width: 12),
          Expanded(child: Text(_errorMessage!, style: TextStyle(color: scheme.error, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildFigmaField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesignSystem.gray600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: label,
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

  Widget _buildFigmaPasswordField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesignSystem.gray600)),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: !_showPassword,
          validator: validator,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: DesignSystem.gray400),
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: DesignSystem.gray400),
              onPressed: () => setState(() => _showPassword = !_showPassword),
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