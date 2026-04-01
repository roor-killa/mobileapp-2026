import 'package:flutter/material.dart';
import 'package:fatoubank/widgets/settings_tile.dart';
import 'package:fatoubank/utils/colors.dart';
import 'package:fatoubank/screens/dashboard/security_screen.dart';
import 'package:fatoubank/screens/dashboard/profile_screen.dart';
import 'package:fatoubank/screens/dashboard/notifications_screen.dart';

class SettingsContent extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsContent({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          SettingsTile(
            icon: Icons.person_outline,
            title: 'Informations personnelles',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          SettingsTile(
            icon: Icons.security,
            title: 'Sécurité',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SecurityScreen(),
                ),
              );
            },
          ),

          SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SettingsTile(
            icon: Icons.logout,
            title: 'Déconnexion',
            isDestructive: true,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}