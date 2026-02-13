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
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void login() async {
    try {
      final data = await ApiService.login(emailCtrl.text, passCtrl.text);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(token: data['token'])));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Identifiants incorrects')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion BKN')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text('Se connecter')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text('Créer un compte'),
            )
          ],
        ),
      ),
    );
  }
}
