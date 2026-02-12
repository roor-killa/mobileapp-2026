import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/transfer_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> register() async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/api/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text, // Important pour Laravel
      }),
    );

    if (response.statusCode == 201) {
      // Succès -> Rediriger vers l'accueil
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TransferScreen()));
    } else {
      // Afficher l'erreur
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: SingleChildScrollView( // Pour éviter les erreurs de pixels avec le clavier
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Nom")),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Mot de passe"), obscureText: true),
            TextField(controller: _confirmPasswordController, decoration: InputDecoration(labelText: "Confirmer le mot de passe"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: Text("Créer mon compte")),
          ],
        ),
      ),
    );
  }
}