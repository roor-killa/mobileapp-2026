import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/styles.dart';
import '../../core/widgets/negs_logo.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  String? emailError;
  String? passwordError;
  bool showSuccess = false;

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        emailError = 'Email requis';
      } else if (!value.contains('@')) {
        emailError = 'Email invalide';
      } else {
        emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        passwordError = 'Mot de passe requis';
      } else if (value.length < 6) {
        passwordError = 'Minimum 6 caractères';
      } else {
        passwordError = null;
      }
    });
  }

  void _login() {
    _validateEmail(emailController.text);
    _validatePassword(passwordController.text);

    if (emailError == null && passwordError == null && emailController.text.isNotEmpty) {
      setState(() => isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            isLoading = false;
            showSuccess = true;
          });

          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) widget.onLoginSuccess();
          });
        }
      });
    }
  }

  void _loginWithFaceID() {
    setState(() => isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLoading = false;
          showSuccess = true;
        });

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) widget.onLoginSuccess();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSuccess) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: NEGsGradients.bgDeepGradient),
        child: Stack(
          children: [
            _buildDecorativeCircles(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: NEGsLogo(size: 100)),
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          NEGsLogoText(fontSize: 36),
                          const SizedBox(height: 12),
                          const Text(
                            'Se connecter à votre compte',
                            style: TextStyle(
                              fontSize: 14,
                              color: NEGsColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NEGsColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: emailController,
                      hintText: 'vous@exemple.com',
                      icon: Icons.email,
                      onChanged: _validateEmail,
                      error: emailError,
                    ),
                    if (emailError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        emailError!,
                        style: const TextStyle(
                          color: NEGsColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      'Mot de passe',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NEGsColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: passwordController,
                      hintText: '••••••••',
                      icon: Icons.lock,
                      obscureText: obscurePassword,
                      onChanged: _validatePassword,
                      onSuffixTap: () => setState(() => obscurePassword = !obscurePassword),
                      suffixIcon: obscurePassword ? Icons.visibility_off : Icons.visibility,
                      error: passwordError,
                    ),
                    if (passwordError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        passwordError!,
                        style: const TextStyle(
                          color: NEGsColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: NEGsColors.primaryViolet,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildFaceIDButton(),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Pas encore de compte ? ',
                            style: TextStyle(
                              color: NEGsColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "S'inscrire",
                              style: TextStyle(
                                color: NEGsColors.primaryCyan,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    Function(String)? onChanged,
    String? error,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: error != null
              ? NEGsColors.danger.withOpacity(0.5)
              : Colors.white.withOpacity(0.15),
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        style: const TextStyle(color: NEGsColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: NEGsColors.textSecondary),
          prefixIcon: Icon(icon, color: NEGsColors.primaryViolet),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: NEGsColors.primaryViolet),
                  onPressed: onSuffixTap,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: NEGsColors.textSecondary, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: TextStyle(color: NEGsColors.textSecondary, fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: NEGsColors.textSecondary, height: 1)),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: NEGsGradients.mainGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: NEGsColors.primaryViolet.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Se connecter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFaceIDButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: NEGsColors.primaryCyan.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _loginWithFaceID,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.05),
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.face, color: NEGsColors.primaryCyan, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Face ID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: NEGsColors.primaryCyan,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: NEGsGradients.bgDeepGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: AlwaysStoppedAnimation(1.0),
                    curve: Curves.elasticOut,
                  ),
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: NEGsGradients.mainGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Connexion réussie !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bienvenue sur NEG\'s',
                style: TextStyle(
                  fontSize: 14,
                  color: NEGsColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  NEGsColors.primaryViolet.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  NEGsColors.primaryCyan.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
