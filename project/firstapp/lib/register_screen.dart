import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/transfer_screen.dart'; // Vérifie bien le chemin de l'import

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  /// Fonction pour afficher une boîte de dialogue ou une SnackBar
  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> register() async {
    // 1. Validation basique côté client
    if (_passwordController.text.length < 8) {
      _showMessage("Le mot de passe doit contenir au moins 8 caractères.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage("Les mots de passe ne correspondent pas.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/register"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Indispensable pour recevoir du JSON
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Succès
        _showMessage("Compte créé !", isError: false);
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const TransferScreen())
        );
      } else if (response.statusCode == 422) {
        // Erreurs de validation Laravel (ex: mot de passe trop court, email déjà pris)
        String errorMsg = "Erreur de validation";
        if (data['errors'] != null) {
          // Récupère la première erreur disponible
          var errors = data['errors'] as Map<String, dynamic>;
          errorMsg = errors.values.first[0]; 
        } else if (data['message'] != null) {
          errorMsg = data['message'];
        }
        _showMessage(errorMsg);
      } else {
        _showMessage("Erreur serveur : ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Impossible de se connecter au serveur. Vérifiez votre connexion.");
      print("Erreur : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inscription"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            
            TextField(
              controller: _nameController, 
              decoration: const InputDecoration(labelText: "Nom complet", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _emailController, 
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _passwordController, 
              decoration: const InputDecoration(
                labelText: "Mot de passe", 
                hintText: "8 caractères minimum",
                border: OutlineInputBorder()
              ), 
              obscureText: true,
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _confirmPasswordController, 
              decoration: const InputDecoration(labelText: "Confirmer le mot de passe", border: OutlineInputBorder()), 
              obscureText: true,
            ),
            
            const SizedBox(height: 30),
            
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text("CRÉER MON COMPTE", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
          ],
        ),
      ),
    );
  }
}