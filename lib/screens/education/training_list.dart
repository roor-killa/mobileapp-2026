import 'package:flutter/material.dart';

class TrainingListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Éducation & Aide Bancaire'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildTrainingCard(
            'Gérer sa bourse d\'étude',
            'Conseils pour les étudiants de l\'UA.',
            Icons.school,
            Colors.orange,
          ),
          _buildTrainingCard(
            'Espace Famille',
            'Partager son solde en sécurité.',
            Icons.family_restroom,
            Colors.green,
          ),
          _buildTrainingCard(
            'Cyber-Sécurité',
            'Protéger son compte des piratages.',
            Icons.security,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(
    String title,
    String desc,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
