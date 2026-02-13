import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Veuillez remplir tous les champs");
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.register(
        _nameController.text,
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        ApiService.token = data['token'];
        if (mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
        }
      } else {
        _showError("Erreur : Vérifiez vos informations");
      }
    } catch (e) {
      _showError("Erreur réseau");
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Créer un compte", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2962FF))),
            const SizedBox(height: 8),
            const Text("Rejoignez BKN App en quelques secondes.", style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 40),

            TextField(controller: _nameController, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline), hintText: "Nom complet")),
            const SizedBox(height: 16),
            TextField(controller: _usernameController, decoration: const InputDecoration(prefixIcon: Icon(Icons.alternate_email), hintText: "Nom d'utilisateur")),
            const SizedBox(height: 16),
            TextField(controller: _emailController, decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined), hintText: "Email")),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), hintText: "Mot de passe")),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("S'INSCRIRE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
