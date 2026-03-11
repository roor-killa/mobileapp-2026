import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isSuccess = false;
    });

    final result = await ApiService.forgotPassword(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _isSuccess = true;
      });
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Une erreur est survenue';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
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
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 40),

                  // Titre
                  const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                  const SizedBox(height: 8),

                  const Text(
                    'Entrez votre adresse email pour recevoir un lien de réinitialisation',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: 40),

                  // Message de succès
                  if (_isSuccess)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.secondaryGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryGreen.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppTheme.secondaryGreen,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Email envoyé !',
                                      style: TextStyle(
                                        color: AppTheme.secondaryGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Vérifiez votre boîte de réception',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Le lien de réinitialisation expire dans 24 heures',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),

                  // Message d'erreur
                  if (_errorMessage != null && !_isSuccess)
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

                  const SizedBox(height: 24),

                  // Champ Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isSuccess,
                    decoration: InputDecoration(
                      hintText: 'votre@email.com',
                      labelText: 'Adresse email',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email requis';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                  const SizedBox(height: 30),

                  // Bouton Envoyer
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: _isSuccess 
                          ? AppTheme.successGradient 
                          : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (_isSuccess ? AppTheme.secondaryGreen : AppTheme.primaryBlue)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: (_isLoading || _isSuccess) ? null : _handleForgotPassword,
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
                          : Text(
                              _isSuccess ? 'EMAIL ENVOYÉ' : 'ENVOYER',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                  const SizedBox(height: 24),

                  // Lien retour si succès
                  if (_isSuccess)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Retour à la connexion',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

                  // Lien retour normal
                  if (!_isSuccess)
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Retour à la connexion',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
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
}