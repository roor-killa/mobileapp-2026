import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app_bkn/theme/app_theme.dart';
import 'package:app_bkn/providers/user_provider.dart';
import 'package:app_bkn/services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Félicité'), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(user).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildInfoTile(icon: Icons.phone_outlined, title: 'Téléphone', value: user['phone'] ?? 'Non renseigné')
                              .animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1, end: 0),
                          _buildInfoTile(icon: Icons.email_outlined, title: 'Email', value: user['email'])
                              .animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.1, end: 0),
                          _buildInfoTile(icon: Icons.date_range, title: 'Membre depuis', value: _formatDate(user['created_at']))
                              .animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: -0.1, end: 0),
                          _buildInfoTile(icon: Icons.verified, title: 'Vérification', value: user['verification_level'] ?? 'Niveau 1', color: AppTheme.secondaryGreen)
                              .animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: -0.1, end: 0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildSettingTile(icon: Icons.edit_outlined, title: 'Modifier le profil', onTap: () {})
                              .animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(begin: -0.1, end: 0),
                          _buildSettingTile(icon: Icons.security_outlined, title: 'Paramètres de sécurité', onTap: () {})
                              .animate().fadeIn(duration: 400.ms, delay: 600.ms).slideX(begin: -0.1, end: 0),
                          _buildSettingTile(icon: Icons.help_outlined, title: 'Centre d\'aide', onTap: () => Navigator.pushNamed(context, '/chatbot'))
                              .animate().fadeIn(duration: 400.ms, delay: 700.ms).slideX(begin: -0.1, end: 0),
                          _buildSettingTile(icon: Icons.analytics_outlined, title: 'Statistiques', onTap: () => Navigator.pushNamed(context, '/analytics'))
                              .animate().fadeIn(duration: 400.ms, delay: 800.ms).slideX(begin: -0.1, end: 0),
                          _buildSettingTile(icon: Icons.logout, title: 'Déconnexion', color: AppTheme.errorRed, onTap: () => _showLogoutDialog(context))
                              .animate().fadeIn(duration: 400.ms, delay: 900.ms).slideX(begin: -0.1, end: 0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text('Version 2.0.0', style: TextStyle(color: Colors.grey.shade400, fontSize: 12))
                        .animate().fadeIn(duration: 400.ms, delay: 1000.ms),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Color(0xFFF5F7FA)]),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: Text(user['prenom'][0], style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          Text('${user['prenom']} ${user['nom']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(30)),
            child: Text(user['pseudo'], style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String value, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color ?? AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, required VoidCallback onTap, Color color = AppTheme.textPrimary}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Janvier 2024';
    try {
      final date = DateTime.parse(dateStr);
      const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Janvier 2024';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.errorRed.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.logout, color: AppTheme.errorRed, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Déconnexion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Voulez-vous vous déconnecter ?', textAlign: TextAlign.center),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              await ApiService.clearSession();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}