import 'package:flutter/material.dart';
import '../models/etudiant.dart';

// Écran pour modifier un étudiant existant
// Les notes sont gérées séparément par matière
class ModifierEtudiantScreen extends StatefulWidget {
  final Etudiant etudiant; // L'étudiant à modifier, reçu en paramètre

  const ModifierEtudiantScreen({super.key, required this.etudiant});

  @override
  State<ModifierEtudiantScreen> createState() => _ModifierEtudiantScreenState();
}

class _ModifierEtudiantScreenState extends State<ModifierEtudiantScreen> {
  // Contrôleurs pré-remplis avec les données de l'étudiant existant
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // On pré-remplit les champs avec les données actuelles de l'étudiant
    _nomController = TextEditingController(text: widget.etudiant.nom);
    _prenomController = TextEditingController(text: widget.etudiant.prenom);
    _emailController = TextEditingController(text: widget.etudiant.email);
  }

  // Vérifie les champs et retourne l'étudiant modifié
  void _sauvegarder() {
    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remplissez tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Crée l'étudiant modifié avec les nouvelles valeurs
    final etudiantModifie = Etudiant(
      id: widget.etudiant.id, // On garde le même id
      nom: _nomController.text,
      prenom: _prenomController.text,
      email: _emailController.text,
    );

    // Retourne l'étudiant modifié à l'écran précédent
    Navigator.pop(context, etudiantModifie);
  }

  // Widget réutilisable pour créer un champ stylisé
  Widget _buildChamp({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFFF9800)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.grey),
          // Bordure orange quand le champ est sélectionné
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800), // Orange pour différencier
        title: const Text(
          'Modifier un étudiant',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Icône décorative
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFFE66D)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 40),
            ),

            const SizedBox(height: 30),

            // Champs du formulaire (sans le champ note)
            _buildChamp(
              controller: _prenomController,
              label: 'Prénom',
              icon: Icons.person_outline,
            ),
            _buildChamp(
              controller: _nomController,
              label: 'Nom',
              icon: Icons.person,
            ),
            _buildChamp(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              type: TextInputType.emailAddress,
            ),

            const SizedBox(height: 10),

            // Bouton sauvegarder
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _sauvegarder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Sauvegarder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}