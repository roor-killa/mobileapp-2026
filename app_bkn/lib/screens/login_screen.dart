import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:app_bkn/theme/app_theme.dart';
import 'package:app_bkn/services/api_service.dart';
import 'package:app_bkn/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final users = await ApiService.getUsers();
    setState(() => _users = users);
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    // Simulation de connexion (à remplacer par vraie auth)
    if (_emailController.text.isNotEmpty) {
      // Chercher utilisateur par email
      final user = _users.firstWhere(
        (u) => u['email'] == _emailController.text,
        orElse: () => _users.isNotEmpty ? _users[0] : null,
      );
      
      if (user != null) {
        await ApiService.saveSession(
          user['id'],
          user['pseudo'],
          user['email'],
        );
        
        if (mounted) {
          await context.read<UserProvider>().loadUser(user['id']);
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _selectUser(Map<String, dynamic> user) async {
    await ApiService.saveSession(
      user['id'],
      user['pseudo'],
      user['email'],
    );
    
    if (mounted) {
      await context.read<UserProvider>().loadUser(user['id']);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
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
                    child: const Center(
                      child: Text(
                        'BKN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .animate()
                .scale(duration: 500.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 50),
                
                // Title
                const Text(
                  'Bon retour 👋',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Connectez-vous à votre espace BKN',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 40),
                
                // Email
                _buildEmailField()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms)
                    .slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 16),
                
                // Password
                _buildPasswordField()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 500.ms)
                    .slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 16),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 600.ms),
                
                const SizedBox(height: 24),
                
                // Login button
                _buildLoginButton()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 700.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                
                const SizedBox(height: 32),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OU',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 800.ms),
                
                const SizedBox(height: 24),
                
                // Quick user selection
                _buildUserSelection()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 900.ms),
                
                const SizedBox(height: 32),
                
                // Sign up
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas encore de compte ? ',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 1000.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'john.doe@email.com',
          labelText: 'Adresse email',
          prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          hintText: '••••••••',
          labelText: 'Mot de passe',
          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryBlue),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.textSecondary,
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
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
                'Se connecter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildUserSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Utilisateurs de démonstration',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ..._users.take(3).map((user) => _buildUserCard(user)),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
          child: Text(
            user['prenom'][0],
            style: const TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          '${user['prenom']} ${user['nom']}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['pseudo'],
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${user['solde']} BKN',
                style: const TextStyle(
                  color: AppTheme.secondaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        onTap: () => _selectUser(user),
      ),
    );
  }
}