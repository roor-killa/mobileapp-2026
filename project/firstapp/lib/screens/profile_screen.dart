import 'package:flutter/material.dart';
import '../services/api_service.dart';

// Correction du nom : ProfileScreen au lieu de ProfilePage
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du compte"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        // Utilisation de la méthode de ton ApiService
        future: ApiService().getUserInfo(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 10),
                  Text("Erreur de récupération des données"),
                ],
              ),
            );
          }

          final user = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: const Icon(Icons.person, size: 60, color: Colors.blueAccent),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              _buildInfoTile("Nom complet", user['name'] ?? "Non défini", Icons.badge),
              _buildInfoTile("Adresse Email", user['email'] ?? "Non défini", Icons.email),
              _buildInfoTile("Numéro de compte", "ID #${user['id']}", Icons.tag),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(),
              ),
              
              // Affichage du solde avec un style un peu plus "Banque"
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _buildInfoTile(
                  "Solde actuel", 
                  "${user['balance']} €", 
                  Icons.account_balance_wallet,
                  color: Colors.blueAccent
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon, {Color color = Colors.blueAccent}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      subtitle: Text(
        value, 
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)
      ),
    );
  }
}