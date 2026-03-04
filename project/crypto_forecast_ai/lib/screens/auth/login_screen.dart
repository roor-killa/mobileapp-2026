import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/auth_store.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoggedIn;
  const LoginScreen({super.key, required this.onLoggedIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _err;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final token = await api.login(_email.text.trim(), _pass.text);
      await AuthStore.saveToken(token);
      widget.onLoggedIn();
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Wallet Démo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
          const SizedBox(height: 10),
          TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe")),
          const SizedBox(height: 14),
          if (_err != null) Text(_err!, style: const TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _loading ? null : _login,
            child: _loading ? const CircularProgressIndicator() : const Text("Se connecter"),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _loading
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterScreen(onRegistered: () => Navigator.pop(context)),
                      ),
                    ),
            child: const Text("Créer un compte"),
          ),
        ],
      ),
    );
  }
}
