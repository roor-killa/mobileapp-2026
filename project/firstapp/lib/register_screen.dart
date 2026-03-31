import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Nécessaire pour limiter la saisie
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/transfer_screen.dart'; 

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
  final _pinController = TextEditingController(); // Nouveau contrôleur pour le PIN
  
  bool _isLoading = false;

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
    // 1. Validations côté client
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      _showMessage("Veuillez remplir tous les champs.");
      return;
    }

    if (_passwordController.text.length < 8) {
      _showMessage("Le mot de passe doit contenir au moins 8 caractères.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage("Les mots de passe ne correspondent pas.");
      return;
    }

    if (_pinController.text.length != 4) {
      _showMessage("Le code PIN doit contenir exactement 4 chiffres.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        // Uri.parse("http://172.26.131.224/api/register"),
        Uri.parse("http://192.168.1.12/api/register"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
          'pin': _pinController.text, // On envoie le PIN à Laravel
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _showMessage("Compte créé avec succès !", isError: false);
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const TransferScreen())
        );
      } else if (response.statusCode == 422) {
        String errorMsg = "Erreur de validation";
        if (data['errors'] != null) {
          var errors = data['errors'] as Map<String, dynamic>;
          errorMsg = errors.values.first[0]; 
        }
        _showMessage(errorMsg);
      } else {
        _showMessage("Erreur serveur : ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Impossible de se connecter au serveur.");
      print("Erreur : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un compte"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.shield_outlined, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            
            TextField(
              controller: _nameController, 
              decoration: const InputDecoration(labelText: "Nom complet", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _emailController, 
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 15),

            // --- NOUVEAU CHAMP PIN ---
            TextField(
              controller: _pinController, 
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4, // Limite visuelle
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Autorise uniquement les chiffres
              decoration: const InputDecoration(
                labelText: "Code PIN de transaction", 
                hintText: "4 chiffres",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                counterText: "", // Masque le compteur de caractères par défaut
              ),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _passwordController, 
              decoration: const InputDecoration(
                labelText: "Mot de passe", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.password),
              ), 
              obscureText: true,
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _confirmPasswordController, 
              decoration: const InputDecoration(
                labelText: "Confirmer le mot de passe", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.check_circle_outline),
              ), 
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("S'INSCRIRE", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
          ],
        ),
      ),
    );
  }
}