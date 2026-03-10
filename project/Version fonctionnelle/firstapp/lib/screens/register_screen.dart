import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'transfer_screen.dart'; // Pour naviguer vers l'écran du prof après succès
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    // Vérification basique
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir les champs obligatoires"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Appel à ton API Laravel
    final result = await _apiService.register(
      nameController.text,
      prenomController.text,
      emailController.text,
      telController.text,
      passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['status'] == 'success') {
      // 1. On ouvre le coffre-fort
      final prefs = await SharedPreferences.getInstance();
      
      // 2. On sauvegarde le token
      final token = result['token'] ?? result['access_token']; 
      if (token != null) {
        await prefs.setString('token', token);
      }

      // ---> LES 2 LIGNES MAGIQUES À AJOUTER ICI AUSSI <---
      // On sauvegarde le solde initial (qui est de 0.00 pour un nouveau compte)
      final soldeInitial = double.parse(result['user']['solde'].toString());
      await prefs.setDouble('solde', soldeInitial);
      // ----------------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inscription réussie !"), backgroundColor: Colors.green),
      );

      // 3. On redirige vers le nouveau squelette avec les onglets
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false, 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenue sur BKN Wallet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Les champs de texte stylisés
            _buildTextField(nameController, 'Nom', Icons.person),
            const SizedBox(height: 15),
            _buildTextField(prenomController, 'Prénom', Icons.person_outline),
            const SizedBox(height: 15),
            _buildTextField(emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 15),
            _buildTextField(telController, 'Téléphone', Icons.phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 15),
            _buildTextField(passwordController, 'Mot de passe', Icons.lock, obscureText: true),
            
            const SizedBox(height: 30),
            
            // Le bouton de validation
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('S\'inscrire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
          ],
        ),
      ),
    );
  }

  // Petite fonction utilitaire pour créer des champs de texte propres
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}