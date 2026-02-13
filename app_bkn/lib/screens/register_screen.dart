import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app_bkn/theme/app_theme.dart';
import 'package:app_bkn/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _pseudoController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _pseudoController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final result = await ApiService.createUser(
      email: _emailController.text,
      nom: _nomController.text,
      prenom: _prenomController.text,
      pseudo: _pseudoController.text,
      phone: _telephoneController.text,
    );
    
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    if (result['success']) {
      final data = result['data'];
      await ApiService.saveSession(
        data['user_id'],
        data['pseudo'],
        data['email'],
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Bienvenue ! ${data['bonus']} BKN offerts'),
          backgroundColor: AppTheme.secondaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['data']['error'] ?? 'Erreur lors de l\'inscription'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 40),
                
                const Text(
                  'Nom',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 8),
                
                _buildTextField(
                  controller: _nomController,
                  hint: 'Votre nom',
                  icon: Icons.person_outline,
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Prénom',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 8),
                
                _buildTextField(
                  controller: _prenomController,
                  hint: 'Votre prénom',
                  icon: Icons.person_outline,
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 8),
                
                _buildTextField(
                  controller: _emailController,
                  hint: 'exemple@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Pseudo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 8),
                
                _buildTextField(
                  controller: _pseudoController,
                  hint: '@pseudo',
                  icon: Icons.alternate_email,
                ).animate().fadeIn(duration: 400.ms, delay: 800.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Téléphone',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 900.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 8),
                
                _buildTextField(
                  controller: _telephoneController,
                  hint: '06 12 34 56 78',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ).animate().fadeIn(duration: 400.ms, delay: 1000.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 40),
                
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: AppTheme.successGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryGreen.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
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
                            'CRÉER MON COMPTE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 1100.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                
                const SizedBox(height: 24),
                
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Déjà un compte ? Se connecter',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 1200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ce champ est requis';
          }
          return null;
        },
      ),
    );
  }
}