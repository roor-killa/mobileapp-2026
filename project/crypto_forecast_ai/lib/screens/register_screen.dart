import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/session_store.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();

  bool _busy = false;

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  bool _isEmailValid(String s) {
    final v = s.trim();
    return v.contains("@") && v.contains(".");
  }

  Future<void> _doRegister() async {
    final first = _first.text.trim();
    final last = _last.text.trim();

    // Garder seulement chiffres + "+"
    final phone = _phone.text.trim().replaceAll(RegExp(r'[^0-9+]'), "");

    final email = _email.text.trim().toLowerCase();
    final p1 = _pass1.text;
    final p2 = _pass2.text;

    if (first.length < 2) return _snack("Prénom trop court.");
    if (last.length < 2) return _snack("Nom trop court.");
    if (phone.length < 8) return _snack("Téléphone invalide (min 8 chiffres).");
    if (!_isEmailValid(email)) return _snack("Email invalide.");
    if (p1.length < 6) return _snack("Mot de passe trop court (min 6).");
    if (p1 != p2) return _snack("Les mots de passe ne correspondent pas.");

    setState(() => _busy = true);
    try {
      // ✅ Register (la bonne méthode dans ton api.dart)
      await api.register(
        email: email,
        password: p1,
        firstName: first,
        lastName: last,
        phone: phone,
      );

      // Login direct après inscription
      final data = await api.login(email, p1);
      final token = (data["access_token"] ?? "").toString();
      final refresh = (data["refresh_token"] ?? "").toString();
      await SessionStore.saveToken(token);
      if (refresh.isNotEmpty) await SessionStore.saveRefreshToken(refresh);
      api.setToken(token);
      api.setRefreshToken(refresh);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed("/app");
      _snack("Compte créé ✅");
    } catch (e) {
      _snack("Erreur inscription: $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _email.dispose();
    _pass1.dispose();
    _pass2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF070B10),
      appBar: AppBar(title: const Text("Créer un compte")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Informations personnelles",
            style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface),
          ),
          const SizedBox(height: 10),

          _Field(controller: _first, label: "Prénom", icon: Icons.badge_rounded),
          const SizedBox(height: 10),
          _Field(controller: _last, label: "Nom", icon: Icons.badge_outlined),
          const SizedBox(height: 10),
          _Field(
            controller: _phone,
            label: "Téléphone",
            icon: Icons.phone_rounded,
            keyboard: TextInputType.phone,
            hint: "+596...",
          ),

          const SizedBox(height: 16),
          Text(
            "Identifiants",
            style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface),
          ),
          const SizedBox(height: 10),

          _Field(
            controller: _email,
            label: "Email",
            icon: Icons.alternate_email_rounded,
            keyboard: TextInputType.emailAddress,
            hint: "ex: a@test.com",
          ),
          const SizedBox(height: 10),
          _Field(
            controller: _pass1,
            label: "Mot de passe",
            icon: Icons.lock_rounded,
            obscure: true,
            hint: "min 6 caractères",
          ),
          const SizedBox(height: 10),
          _Field(
            controller: _pass2,
            label: "Confirmer le mot de passe",
            icon: Icons.lock_outline_rounded,
            obscure: true,
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _busy ? null : _doRegister,
            icon: _busy
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.person_add_alt_1_rounded),
            label: const Text("Créer le compte", style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),

          const SizedBox(height: 10),

          TextButton(
            onPressed: _busy ? null : () => Navigator.pop(context),
            child: Text(
              "J’ai déjà un compte",
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final String? hint;
  final TextInputType? keyboard;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.hint,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: cs.surface.withOpacity(0.55),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}