import 'package:flutter/material.dart';
import 'package:app_bkn/theme/app_theme.dart';
import 'package:app_bkn/services/api_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  bool _twoFactorEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (ApiService.currentUserId == null) return;

    final settings =
        await ApiService.getUserSettings(ApiService.currentUserId!);

    if (!mounted) return;

    setState(() {
      _biometricEnabled = settings['biometric_enabled'] ?? false;
      _notificationsEnabled = settings['notifications_enabled'] ?? true;
      _twoFactorEnabled = settings['two_factor_enabled'] ?? false;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(String type, bool value) async {
    if (ApiService.currentUserId == null) return;

    await ApiService.updateUserSettings(
      userId: ApiService.currentUserId!,
      biometricEnabled: type == 'biometric' ? value : null,
      notificationsEnabled: type == 'notifications' ? value : null,
      twoFactorEnabled: type == 'twoFactor' ? value : null,
    );
  }

  Future<void> _showSessionsDialog() async {
    if (ApiService.currentUserId == null) return;

    final sessions =
        await ApiService.getUserSessions(ApiService.currentUserId!);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Appareils connectés'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  leading: Icon(
                    Icons.devices,
                    color: AppTheme.primaryBlue,
                  ),
                  title:
                      Text(session['device_name'] ?? 'Appareil inconnu'),
                  subtitle:
                      Text(session['last_active'] ?? 'Inconnu'),
                  trailing: IconButton(
                    icon: Icon(Icons.logout, color: AppTheme.errorRed),
                    onPressed: () async {
                      await ApiService.terminateSession(session['id']);
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();
                      _showSessionsDialog();
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fermer'),
            ),
            TextButton(
              onPressed: () async {
                await ApiService.terminateAllSessions(
                    ApiService.currentUserId!);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Toutes les sessions ont été déconnectées'),
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                );
              },
              child: const Text(
                'Tout déconnecter',
                style: TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
              ),
              onPressed: () async {
                await ApiService.clearSession();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sécurité & Confidentialité'),
          backgroundColor: AppTheme.primaryBlue,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité & Confidentialité'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Connexion biométrique'),
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() => _biometricEnabled = value);
                _updateSetting('biometric', value);
              },
              activeThumbColor: AppTheme.primaryBlue,
              activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
            ),
            SwitchListTile(
              title: const Text('Notifications push'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _updateSetting('notifications', value);
              },
              activeThumbColor: AppTheme.primaryBlue,
              activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
            ),
            SwitchListTile(
              title: const Text('Double authentification'),
              value: _twoFactorEnabled,
              onChanged: (value) {
                setState(() => _twoFactorEnabled = value);
                _updateSetting('twoFactor', value);
              },
              activeThumbColor: AppTheme.primaryBlue,
              activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
              onPressed: _showSessionsDialog,
              child: const Text('Appareils connectés'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
              ),
              onPressed: _showLogoutDialog,
              child: const Text('Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }
}