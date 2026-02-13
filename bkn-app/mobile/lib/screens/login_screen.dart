import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: "admin@bkn.app");
  final _passwordController = TextEditingController(text: "password");
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.login(_emailController.text, _passwordController.text);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ApiService.token = data['token'];
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      } else {
        _showError("Email ou mot de passe incorrect");
      }
    } catch (e) {
      _showError("Erreur de connexion au serveur");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER AVEC DÉGRADÉ ---
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2962FF), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.account_balance_wallet, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text("BKN APP", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const Text("Votre banque, réinventée.", style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),

            // --- FORMULAIRE ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Align(alignment: Alignment.centerLeft, child: Text("Bienvenue !", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  const Align(alignment: Alignment.centerLeft, child: Text("Connectez-vous pour continuer", style: TextStyle(color: Colors.grey))),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined), hintText: "Email"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), hintText: "Mot de passe"),
                  ),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text("Mot de passe oublié ?"))),
                  
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SE CONNECTER"),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Nouveau client ?"),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text("Ouvrir un compte", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
