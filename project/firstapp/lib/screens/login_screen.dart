import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/bank_service.dart';
import 'dashboard_screen.dart';
import '../theme/app_theme.dart';

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
  bool _isRegistering = false;
  String? _errorMessage;

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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _HeaderCard(isRegistering: _isRegistering),
                const SizedBox(height: 16),
                if (kDebugMode && !_isRegistering)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connexion rapide (tests)',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              label: const Text('Jean Dupont'),
                              onPressed: () => _fillDemo('jean.dupont@example.com'),
                            ),
                            ActionChip(
                              label: const Text('Marie Martin'),
                              onPressed: () => _fillDemo('marie.martin@example.com'),
                            ),
                            ActionChip(
                              label: const Text('Pierre Bernard'),
                              onPressed: () => _fillDemo('pierre.bernard@example.com'),
                            ),
                            ActionChip(
                              label: const Text('Sophie Lefebvre'),
                              onPressed: () => _fillDemo('sophie.lefebvre@example.com'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Mot de passe: password123",
                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.error.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                  ),
                if (!_isRegistering) ..._buildLoginFields() else ..._buildRegisterFields(),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_isRegistering ? _register : _login),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isRegistering ? "S'inscrire" : 'Se connecter',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => setState(() {
                    _isRegistering = !_isRegistering;
                    _errorMessage = null;
                  }),
                  child: Text(
                    _isRegistering ? 'Vous avez déjà un compte ? Se connecter' : 'Créer un nouveau compte',
                    style: TextStyle(color: scheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLoginFields() {
    return [
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
        validator: (value) => (value?.isEmpty ?? true) ? 'Veuillez entrer votre email' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Mot de passe', prefixIcon: Icon(Icons.lock)),
        validator: (value) => (value?.isEmpty ?? true) ? 'Veuillez entrer votre mot de passe' : null,
      ),
    ];
  }

  List<Widget> _buildRegisterFields() {
    return [
      TextFormField(
        controller: _firstNameController,
        decoration: const InputDecoration(labelText: 'Prénom', prefixIcon: Icon(Icons.person)),
        validator: (value) => (value?.isEmpty ?? true) ? 'Veuillez entrer votre prénom' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _lastNameController,
        decoration: const InputDecoration(labelText: 'Nom', prefixIcon: Icon(Icons.person)),
        validator: (value) => (value?.isEmpty ?? true) ? 'Veuillez entrer votre nom' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
        validator: (value) => (value?.isEmpty ?? true) ? 'Veuillez entrer votre email' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone)),
        validator: (value) => (value?.isEmpty ?? true) ? 'Veuillez entrer votre téléphone' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Mot de passe', prefixIcon: Icon(Icons.lock)),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Veuillez entrer votre mot de passe';
          if (value.length < 8) return 'Le mot de passe doit contenir au moins 8 caractères';
          return null;
        },
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _passwordConfirmController,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Confirmer le mot de passe', prefixIcon: Icon(Icons.lock)),
        validator: (value) => (value?.isEmpty ?? true) ? 'Veuillez confirmer votre mot de passe' : null,
      ),
    ];
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isRegistering;

  const _HeaderCard({required this.isRegistering});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.brand, AppTheme.brand2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                ),
                child: const Icon(Icons.account_balance, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MyBank', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text(
                      'Banque mobile • Comptes • Virements',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isRegistering ? 'Créer un compte' : 'Connexion sécurisée',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Accédez à vos comptes et effectuez un virement en quelques secondes.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}