import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _mdpController = TextEditingController();
  final _confirmerMdpController = TextEditingController();
  final _soldeController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _mdpVisible = false;

  static final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  Future<void> _inscrire() async {
    final nom = _nomController.text.trim();
    final email = _emailController.text.trim();
    final mdp = _mdpController.text;
    final confirmerMdp = _confirmerMdpController.text;
    final soldeText = _soldeController.text.trim();

    if (nom.isEmpty || email.isEmpty || mdp.isEmpty || soldeText.isEmpty) {
      _afficherErreur('Veuillez remplir tous les champs');
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      _afficherErreur('Adresse email invalide');
      return;
    }

    if (mdp != confirmerMdp) {
      _afficherErreur('Les mots de passe ne correspondent pas');
      return;
    }

    if (mdp.length < 6) {
      _afficherErreur('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    final solde = double.tryParse(soldeText);
    if (solde == null || solde <= 0) {
      _afficherErreur('Solde initial invalide');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.inscrire(
        nom: nom,
        email: email,
        mdp: mdp,
        soldeInitial: solde,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (e.toString().contains('EMAIL_EXISTE')) {
        _afficherErreur('Cet email est déjà utilisé');
      } else {
        _afficherErreur('Une erreur est survenue, veuillez réessayer');
      }
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            TextField(
              controller: _nomController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: const Icon(Icons.person_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _mdpController,
              obscureText: !_mdpVisible,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_mdpVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _mdpVisible = !_mdpVisible),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
                helperText: 'Minimum 6 caractères',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _confirmerMdpController,
              obscureText: !_mdpVisible,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: const Icon(Icons.lock_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _soldeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Solde initial à déposer',
                prefixIcon: const Icon(Icons.euro),
                suffixText: '€',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
                helperText: 'Montant de départ de votre compte',
              ),
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _isLoading ? null : _inscrire,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Créer mon compte",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Déjà un compte ? Se connecter',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _mdpController.dispose();
    _confirmerMdpController.dispose();
    _soldeController.dispose();
    super.dispose();
  }
}
