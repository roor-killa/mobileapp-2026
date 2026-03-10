import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _apiService.login(
      emailController.text,
      passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);

      // ---> LES 2 LIGNES MAGIQUES À AJOUTER <---
      // On lit le solde envoyé par Laravel et on le range dans le coffre
      final soldeInitial = double.parse(result['user']['solde'].toString());
      await prefs.setDouble('solde', soldeInitial);
      // ----------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bienvenue !"), backgroundColor: Colors.green),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // Si le mot de passe est faux, on affiche une erreur rouge
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${result['message'] ?? 'Identifiants invalides'}"), backgroundColor: Colors.red),
      );
    }
  } 
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion BKN Wallet'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blue),
            const SizedBox(height: 30),
            
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
            
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Se connecter', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
            
            const SizedBox(height: 20),
            
            // Le bouton pour aller vers l'inscription
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text("Pas encore de compte ? S'inscrire", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}