import 'package:flutter/material.dart';
import '../models/etudiant.dart';

class AjouterEtudiantScreen extends StatefulWidget {
  const AjouterEtudiantScreen({super.key});

  @override
  State<AjouterEtudiantScreen> createState() => _AjouterEtudiantScreenState();
}

class _AjouterEtudiantScreenState extends State<AjouterEtudiantScreen> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  void _sauvegarder() {
    if (_nomController.text.isEmpty || _prenomController.text.isEmpty ||
        _emailController.text.isEmpty || _noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez tous les champs'), backgroundColor: Colors.red),
      );
      return;
    }

    final etudiant = Etudiant(
      nom: _nomController.text,
      prenom: _prenomController.text,
      email: _emailController.text,
      note: double.parse(_noteController.text),
    );

    Navigator.pop(context, etudiant);
  }

  Widget _buildChamp({required TextEditingController controller, required String label, required IconData icon, TextInputType type = TextInputType.text}) {
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
          prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.grey),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
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
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text('Ajouter un étudiant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Icône en haut
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person_add, color: Colors.white, size: 40),
            ),

            const SizedBox(height: 30),

            _buildChamp(controller: _prenomController, label: 'Prénom', icon: Icons.person_outline),
            _buildChamp(controller: _nomController, label: 'Nom', icon: Icons.person),
            _buildChamp(controller: _emailController, label: 'Email', icon: Icons.email_outlined, type: TextInputType.emailAddress),
            _buildChamp(controller: _noteController, label: 'Note (/20)', icon: Icons.grade_outlined, type: TextInputType.number),

            const SizedBox(height: 10),

            // Bouton sauvegarder
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _sauvegarder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
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