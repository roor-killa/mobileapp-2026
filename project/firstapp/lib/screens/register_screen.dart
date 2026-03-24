import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

const Color bgDark = Color(0xFF09090B);
const Color cardDark = Color(0xFF18181B);
const Color emerald500 = Color(0xFF10B981);
const Color textGray = Color(0xFF71717A);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  
  bool _isLoading = false;

  void _register() async {
    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les mots de passe ne correspondent pas'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    final result = await _apiService.register(
      _nameController.text.trim(),
      _prenomController.text.trim(),
      _emailController.text.trim(),
      _telephoneController.text.trim(),
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compte créé avec succès !'), backgroundColor: emerald500));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Erreur'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête
                const Text('Créer un compte', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Rejoignez la révolution BKN dès aujourd\'hui.', style: TextStyle(color: textGray, fontSize: 14)),
                const SizedBox(height: 40),

                // Formulaire
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('PRÉNOM'),
                          const SizedBox(height: 10),
                          _buildTextField(_prenomController, 'Jean', false),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('NOM'),
                          const SizedBox(height: 10),
                          _buildTextField(_nameController, 'Dupont', false),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                _buildInputLabel('ADRESSE EMAIL'),
                const SizedBox(height: 10),
                _buildTextField(_emailController, 'exemple@email.com', false),

                const SizedBox(height: 20),
                _buildInputLabel('TÉLÉPHONE'),
                const SizedBox(height: 10),
                _buildTextField(_telephoneController, '+33 6 12 34 56 78', false),

                const SizedBox(height: 20),
                _buildInputLabel('MOT DE PASSE'),
                const SizedBox(height: 10),
                _buildTextField(_passwordController, '••••••••', true),

                const SizedBox(height: 20),
                _buildInputLabel('CONFIRMER LE MOT DE PASSE'),
                const SizedBox(height: 10),
                _buildTextField(_passwordConfirmController, '••••••••', true),

                const SizedBox(height: 40),

                // Bouton Inscription
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: emerald500))
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: emerald500,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('CRÉER MON COMPTE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ),

                const SizedBox(height: 20),

                // Lien vers la connexion
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  child: const Text("Déjà un compte ? Se connecter", style: TextStyle(color: emerald500, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(label, style: const TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5));
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade800),
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade900)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade900)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: emerald500)),
      ),
    );
  }
}