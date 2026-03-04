import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'screens/transfer_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService(); // Instance du service
  bool _isLoading = false;

  Future<void> login() async {
    // Vérification basique des champs
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _afficherMessage("Veuillez remplir tous les champs", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final String url = "http://10.0.2.2:8000/api/login"; 

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['access_token'];
        
        print("✅ Login réussi ! Token: $token");

        // --- ÉTAPE CRUCIALE ---
        // On enregistre le token dans l'ApiService AVANT de changer d'écran
        _apiService.token = token; 

        if (!mounted) return;
        
        setState(() => _isLoading = false);

        // Navigation vers l'écran de transfert
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TransferScreen()),
        );
      } else {
        setState(() => _isLoading = false);
        final errorData = jsonDecode(response.body);
        _afficherMessage(errorData['message'] ?? "Identifiants incorrects", isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Erreur de connexion : $e");
      _afficherMessage("Erreur de connexion au serveur", isError: true);
    }
  }

  void _afficherMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Réinitialisation"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Entrez votre email pour recevoir un lien de récupération."),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _afficherMessage("Un lien de récupération a été envoyé (Simulation)");
            },
            child: const Text("Envoyer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connexion Wallet"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blue),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Mot de passe",
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("Se connecter", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text("Pas de compte ? Inscrivez-vous"),
            ),
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text("Mot de passe oublié ?", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}