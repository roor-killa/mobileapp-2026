import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import nécessaire pour le Reset
import 'transfer_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond dégradé
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo ou Icône de l'app
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 60,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 40),
                
                const Text(
                  'Bienvenue sur BKN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choisissez votre profil pour continuer',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 50),

                // Carte Utilisateur 1
                _buildUserCard(
                  context,
                  userId: 1,
                  userName: "Utilisateur 1",
                  subtitle: "Compte Personnel",
                  icon: Icons.person,
                  color: Colors.blue.shade700,
                ),
                
                const SizedBox(height: 20),

                // Carte Utilisateur 2
                _buildUserCard(
                  context,
                  userId: 2,
                  userName: "Utilisateur 2",
                  subtitle: "Compte Secondaire",
                  icon: Icons.person_outline,
                  color: Colors.orange.shade700,
                ),

                const SizedBox(height: 60),

                // --- BOUTON DASHBOARD ---
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                  label: const Text(
                    'Voir Dashboard / Historique JSON',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- BOUTON RESET (DANGER) ---
                TextButton.icon(
                  onPressed: () async {
                    // Confirmation avant reset
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Réinitialiser tout ?'),
                        content: const Text(
                          'Cela va effacer tout l\'historique des transactions et remettre les soldes initiaux (5000€ et 1500€).',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('CONFIRMER RESET'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      // Appel API Reset
                      final api = ApiService(); 
                      final success = await api.resetDatabase();
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? '✅ Système remis à zéro avec succès !' : '❌ Erreur lors du reset'),
                            backgroundColor: success ? Colors.green : Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  label: const Text(
                    'Reset Database /trash',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context, {
    required int userId,
    required String userName,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransferScreen(
                userId: userId, 
                userName: userName
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
