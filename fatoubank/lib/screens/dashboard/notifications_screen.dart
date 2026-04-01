import 'package:flutter/material.dart';
import 'package:fatoubank/utils/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool pushEnabled = true;
  bool emailEnabled = true;
  bool balanceAlerts = true;
  bool marketingEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Canaux de communication'),
          _buildToggleTile('Notifications Push', 'Recevez des alertes sur votre mobile.', pushEnabled, (v) => setState(() => pushEnabled = v)),
          _buildToggleTile('Emails', 'Recevez vos relevés et alertes par email.', emailEnabled, (v) => setState(() => emailEnabled = v)),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Alertes de compte'),
          _buildToggleTile('Alertes de solde', 'Soyez notifié en cas de solde bas.', balanceAlerts, (v) => setState(() => balanceAlerts = v)),
          _buildToggleTile('Mouvements suspects', 'Alertes sur les transactions inhabituelles.', true, null),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Offres et promotions'),
          _buildToggleTile('Offres partenaires', 'Recevez des bons plans de nos partenaires.', marketingEnabled, (v) => setState(() => marketingEnabled = v)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _buildToggleTile(String title, String subtitle, bool value, ValueChanged<bool>? onChanged) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }
}
