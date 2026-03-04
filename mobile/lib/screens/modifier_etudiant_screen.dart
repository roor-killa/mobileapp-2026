import 'package:flutter/material.dart';
import '../models/etudiant.dart';

class ModifierEtudiantScreen extends StatefulWidget {
  // L'étudiant à modifier, reçu en paramètre depuis la liste
  final Etudiant etudiant;

  const ModifierEtudiantScreen({super.key, required this.etudiant});

  @override
  State<ModifierEtudiantScreen> createState() => _ModifierEtudiantScreenState();
}

class _ModifierEtudiantScreenState extends State<ModifierEtudiantScreen> {
  // Contrôleurs pour chaque champ du formulaire
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    // On pré-remplit les champs avec les données de l'étudiant existant
    _nomController = TextEditingController(text: widget.etudiant.nom);
    _prenomController = TextEditingController(text: widget.etudiant.prenom);
    _emailController = TextEditingController(text: widget.etudiant.email);
    _noteController = TextEditingController(text: widget.etudiant.note.toString());
  }

  // Vérifie les champs et retourne l'étudiant modifié à l'écran précédent
  void _sauvegarder() {
    // Vérification que tous les champs sont remplis
    if (_nomController.text.isEmpty || _prenomController.text.isEmpty ||
        _emailController.text.isEmpty || _noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez tous les champs'), backgroundColor: Colors.red),
      );
      return;
    }

    // Création de l'étudiant modifié avec les nouvelles valeurs
    final etudiantModifie = Etudiant(
      id: widget.etudiant.id, // On garde le même id
      nom: _nomController.text,
      prenom: _prenomController.text,
      email: _emailController.text,
      note: double.parse(_noteController.text),
    );

    // On retourne l'étudiant modifié à l'écran précédent
    Navigator.pop(context, etudiantModifie);
  }

  // Widget réutilisable pour créer un champ de formulaire stylisé
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
        // Ombre légère sous chaque champ
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
          // Icône orange à gauche du champ
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
      // Fond gris clair pour toute la page
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800), // Orange pour différencier de l'ajout
        title: const Text('Modifier un étudiant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white), // Flèche retour en blanc
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Icône décorative en haut de la page
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

            // Champs du formulaire
            _buildChamp(controller: _prenomController, label: 'Prénom', icon: Icons.person_outline),
            _buildChamp(controller: _nomController, label: 'Nom', icon: Icons.person),
            _buildChamp(controller: _emailController, label: 'Email', icon: Icons.email_outlined, type: TextInputType.emailAddress),
            _buildChamp(controller: _noteController, label: 'Note (/20)', icon: Icons.grade_outlined, type: TextInputType.number),

            const SizedBox(height: 10),

            // Bouton de sauvegarde
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _sauvegarder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                child: const Text('Sauvegarder', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}