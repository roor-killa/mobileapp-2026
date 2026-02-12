import 'package:flutter/material.dart';
import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Utilisateur exemple
  static final User currentUser = User(
    id: '1',
    lastName: 'Doe',
    firstName: 'John',
    email: 'john.doe@email.com',
    phone: '06 12 34 56 78',
    bknBalance: 1500,
    registeredAt: DateTime(2024, 1, 15),
    verificationLevel: 'Niveau 2',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Félicité'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec photo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0A2472).withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF0A2472).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF0A2472),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2472),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser.email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Informations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.phone,
                    title: 'Téléphone',
                    value: currentUser.phone,
                  ),
                  _buildInfoTile(
                    icon: Icons.date_range,
                    title: 'Membre depuis',
                    value: 'Janvier 2024',
                  ),
                  _buildInfoTile(
                    icon: Icons.verified,
                    title: 'Vérification',
                    value: currentUser.verificationLevel,
                    color: const Color(0xFF00C9A7),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Paramètres
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.edit,
                    title: 'Modifier le profil',
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.security,
                    title: 'Paramètres de sécurité',
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.help,
                    title: 'Centre d\'aide',
                    onTap: () {
                      Navigator.pushNamed(context, '/chatbot');
                    },
                  ),
                  _buildSettingTile(
                    icon: Icons.logout,
                    title: 'Déconnexion',
                    color: Colors.red,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Déconnexion'),
                          content: const Text('Voulez-vous vous déconnecter ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Déconnexion'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? const Color(0xFF0A2472)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF0A2472),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}