import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'etudiants_screen.dart'; // Écran vers lequel on redirige après connexion
import 'inscription_professeur_screen.dart'; // Écran d'inscription

// Écran de connexion pour les professeurs
// C'est le premier écran affiché au démarrage de l'app
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Contrôleurs pour récupérer ce que tape le professeur
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Service pour appeler l'API Laravel
  final ApiService _apiService = ApiService();

  // État du chargement (true = spinner affiché)
  bool _isLoading = false;

  // Masquer/afficher le mot de passe
  bool _passwordVisible = false;

  // Fonction appelée quand on appuie sur "Se connecter"
  Future<void> _seConnecter() async {
    // Vérification que les champs ne sont pas vides
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remplissez tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Active le spinner de chargement
    setState(() => _isLoading = true);

    try {
      // Appel à l'API de connexion
      final success = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        // Connexion réussie : on va vers l'écran des étudiants
        // pushReplacement empêche de revenir au login avec le bouton retour
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EtudiantsScreen()),
        );
      } else {
        // Connexion échouée : on affiche un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email ou mot de passe incorrect'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Erreur réseau ou serveur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur de connexion au serveur'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Désactive le spinner
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 80),

            // Logo / icône en haut
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 55),
            ),

            const SizedBox(height: 30),

            // Titre
            const Text(
              'Espace Professeur',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),

            const SizedBox(height: 8),

            // Sous-titre
            Text(
              'Connectez-vous pour gérer vos étudiants',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),

            const SizedBox(height: 50),

            // Champ email
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: Color(0xFF6C63FF)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF6C63FF), width: 2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Champ mot de passe
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible, // Cache le mot de passe
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Color(0xFF6C63FF)),
                  // Bouton pour afficher/masquer le mot de passe
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _passwordVisible = !_passwordVisible);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF6C63FF), width: 2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Bouton de connexion
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _seConnecter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                // Affiche un spinner si chargement, sinon le texte
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Bouton pour aller vers l'écran d'inscription
            TextButton(
              onPressed: () {
                // Navigue vers l'écran d'inscription
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InscriptionProfesseurScreen(),
                  ),
                );
              },
              child: const Text(
                'Pas encore de compte ? S\'inscrire',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}