import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/transfer_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    // ATTENTION : Utilisez votre adresse IP locale (ex: 192.168.1.xx) 
    // ou 10.0.2.2 pour l'émulateur Android, pas 127.0.0.1
    final String url = "http://10.0.2.2:8000/api/login"; 

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Login réussi ! Token: ${data['access_token']}");

        if (!mounted) return; // Sécurité pour éviter les erreurs si l'écran est fermé
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TransferScreen()),
        );
      } else {
        print("Échec de la connexion : ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec de la connexion : ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Erreur de connexion : $e");
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Réinitialisation"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Entrez votre email pour recevoir un lien de récupération."),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
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
              // Ici, on ferme le dialogue
              Navigator.pop(context);
              // On affiche une confirmation en bas de l'écran
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Un lien de récupération a été envoyé (Simulation)"),
                  backgroundColor: Colors.green,
                ),
              );
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
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Mot de passe"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text("Se connecter")),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text("Pas de compte ? Inscrivez-vous"),
            ),
            TextButton(
              onPressed: () {
                // Simulation du mot de passe oublié
                _showForgotPasswordDialog();
              },
              child: const Text("Mot de passe oublié ?"),
            ),
                      ],
        ),
      ),
    );
  }
}