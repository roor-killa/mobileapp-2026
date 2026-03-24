import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'main_screen.dart';
import 'register_screen.dart';

const Color bgDark = Color(0xFF09090B);
const Color cardDark = Color(0xFF18181B);
const Color emerald500 = Color(0xFF10B981);
const Color textGray = Color(0xFF71717A);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

 void _login() async {
    setState(() => _isLoading = true);

    try {
      final result = await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print("========== REPONSE LOGIN ==========");
      print(result);
      print("===================================");

      if (!mounted) return;

      // LA CORRECTION EST ICI : On vérifie "status" == 'success'
      if (result != null && result['status'] == 'success') {
        
        // On sauvegarde le token secret dans le téléphone ! 🔐
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['token']);

        if (!mounted) return;

        // On ouvre enfin les portes du Dashboard ! 🚀
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Identifiants incorrects'), 
            backgroundColor: Colors.red
          ),
        );
      }
    } catch (e) {
      print("Erreur fatale lors du login : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de joindre le serveur. (Voir la console)'), 
            backgroundColor: Colors.red
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo / Icône
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: emerald500.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.lock_outline, size: 40, color: emerald500),
                ),
                const SizedBox(height: 30),
                
                // Titre
                const Text('Bienvenue', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Connectez-vous pour accéder à votre BKN Wallet.', style: TextStyle(color: textGray, fontSize: 14)),
                const SizedBox(height: 40),

                // Formulaire
                _buildInputLabel('ADRESSE EMAIL'),
                const SizedBox(height: 10),
                _buildTextField(_emailController, 'exemple@email.com', false),
                
                const SizedBox(height: 25),
                
                _buildInputLabel('MOT DE PASSE'),
                const SizedBox(height: 10),
                _buildTextField(_passwordController, '••••••••', true),
                
                const SizedBox(height: 40),

                // Bouton Connexion
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: emerald500))
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: emerald500,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('SE CONNECTER', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ),

                const SizedBox(height: 20),

                // Lien vers l'inscription
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  },
                  child: const Text("Pas de compte ? S'inscrire", style: TextStyle(color: emerald500, fontWeight: FontWeight.bold)),
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