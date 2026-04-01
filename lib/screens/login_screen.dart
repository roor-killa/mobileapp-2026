import 'package:flutter/material.dart';
import 'transfer_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isRegister = false;

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    setState(() => _isLoading = true);

    if (_isRegister) {
      final success = await _apiService.register(name, email, password);
      setState(() => _isLoading = false);

      if (success) {
        _showMessage("Compte créé !");
        setState(() => _isRegister = false);
      } else {
        _showMessage("Erreur inscription");
      }
    } else {
      final result = await _apiService.login(email, password);
      setState(() => _isLoading = false);

      if (result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TransferScreen(
              user: result['user'],
              token: result['token'],
            ),
          ),
        );
      } else {
        _showMessage("Identifiants incorrects");
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _input(TextEditingController controller, String label, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔵 HEADER APP
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: const [
                  Icon(Icons.account_balance, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "MyWallet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 🧾 FORMULAIRE
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20,
                          color: Colors.black12,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isRegister ? "Créer un compte" : "Connexion",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 25),

                        if (_isRegister)
                          _input(_nameController, "Nom", Icons.person),

                        const SizedBox(height: 15),
                        _input(_emailController, "Email", Icons.email),

                        const SizedBox(height: 15),
                        _input(_passwordController, "Mot de passe", Icons.lock,
                            obscure: true),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    _isRegister
                                        ? "Créer un compte"
                                        : "Se connecter",
                                    style: const TextStyle(fontSize: 16, color: Colors.black),
                                  ),
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isRegister = !_isRegister;
                            });
                          },
                          child: Text(
                            _isRegister
                                ? "Déjà un compte ? Se connecter"
                                : "Créer un compte",
                            style: const TextStyle(color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}