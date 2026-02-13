import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final userCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void register() async {
    try {
      final data = await ApiService.register(userCtrl.text, nameCtrl.text, emailCtrl.text, passCtrl.text);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(token: data['token'])));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur inscription')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'ID Perso (ex: dark_sasuke)')),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom complet')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: register, child: const Text("S'inscrire & Commencer")),
            ],
          ),
        ),
      ),
    );
  }
}
