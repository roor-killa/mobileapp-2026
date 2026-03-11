import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;

  const ResetPasswordScreen({super.key, this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  bool _isTokenValid = true;
  bool _isCheckingToken = true;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      _validateToken();
    } else {
      setState(() {
        _isTokenValid = false;
        _isCheckingToken = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _validateToken() async {
    final isValid = await ApiService.validateResetToken(widget.token!);
    if (mounted) {
      setState(() {
        _isTokenValid = isValid;
        _isCheckingToken = false;
      });
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.token == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.resetPassword(
      token: widget.token!,
      newPassword: _passwordController.text,
    );

    if (!mounted) return;

    if (result['success']) {
      setState(() => _isSuccess = true);
      
      // Redirection automatique après 3 secondes
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Échec de la réinitialisation';
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement
    if (_isCheckingToken) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vérification'),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryBlue),
                SizedBox(height: 20),
                Text(
                  'Vérification du lien...',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Token invalide
    if (!_isTokenValid) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lien invalide'),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppTheme.errorRed.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Lien invalide ou expiré',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ce lien de réinitialisation n\'est plus valide. Veuillez faire une nouvelle demande.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacementNamed(context, '/forgot-password');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'NOUVELLE DEMANDE',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Succès
    if (_isSuccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Succès'),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppTheme.secondaryGreen,
                      size: 100,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mot de passe réinitialisé !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Votre mot de passe a été modifié avec succès. Vous allez être redirigé vers la page de connexion.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(color: AppTheme.primaryBlue),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Formulaire de réinitialisation
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau mot de passe'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Icône
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppTheme.successGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondaryGreen.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.password,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 40),

                  // Titre
                  const Text(
                    'Nouveau mot de passe',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                  const SizedBox(height: 8),

                  const Text(
                    'Choisissez un mot de passe sécurisé',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: 40),

                  // Message d'erreur
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.errorRed.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppTheme.errorRed,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: AppTheme.errorRed,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),

                  const SizedBox(height: 20),

                  // Nouveau mot de passe
                  _buildPasswordField(
                    controller: _passwordController,
                    label: 'Nouveau mot de passe',
                    hint: 'Minimum 6 caractères',
                    isVisible: _isPasswordVisible,
                    onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                  const SizedBox(height: 20),

                  // Confirmation
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    hint: 'Retapez votre mot de passe',
                    isVisible: _isConfirmPasswordVisible,
                    onToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    isConfirm: true,
                    passwordController: _passwordController,
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                  const SizedBox(height: 30),

                  // Bouton
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.successGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryGreen.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'RÉINITIALISER',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    bool isConfirm = false,
    TextEditingController? passwordController,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryBlue),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.textSecondary,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Mot de passe requis';
        }
        if (!isConfirm && value.length < 6) {
          return 'Minimum 6 caractères';
        }
        if (isConfirm && value != passwordController?.text) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      },
    );
  }
}