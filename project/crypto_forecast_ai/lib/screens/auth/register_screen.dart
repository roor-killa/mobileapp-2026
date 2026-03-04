import 'package:flutter/material.dart';
import '../../services/api.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegistered;
  const RegisterScreen({super.key, required this.onRegistered});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _err;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      await api.register(_email.text.trim(), _pass.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compte créé !")));
      }
      widget.onRegistered();
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
      appBar: AppBar(title: const Text("Créer un compte")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
          const SizedBox(height: 10),
          TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe")),
          const SizedBox(height: 14),
          if (_err != null) Text(_err!, style: const TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _loading ? null : _register,
            child: _loading ? const CircularProgressIndicator() : const Text("Créer"),
          ),
        ],
      ),
    );
  }
}
