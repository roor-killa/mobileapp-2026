import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/security_provider.dart';
import 'app_lock_screen.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sécurité')),
      body: Consumer<SecurityProvider>(
        builder: (context, sec, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Verrouillage', [
              _switchTile(Icons.pin_rounded, 'Code PIN', 'Verrouiller l\'app au démarrage', sec.pinEnabled, (v) => _togglePin(context, sec, v)),
              _tile(Icons.timer_outlined, 'Verrouillage automatique', sec.timeoutMinutes == 0 ? 'Jamais' : '${sec.timeoutMinutes} min d\'inactivité', () => _showTimeoutDialog(context, sec)),
              if (!kIsWeb) _switchTile(Icons.fingerprint_rounded, 'Biométrie', 'Déverrouiller avec empreinte/Face ID', sec.biometricEnabled, (v) => sec.setBiometricEnabled(v)),
            ]),
            const SizedBox(height: 16),
            _section('Données sensibles', [
              _switchTile(Icons.content_paste_off_rounded, 'Effacer le presse-papiers', 'Vider après 30 s après copie', sec.clipboardClearEnabled, (v) => sec.setClipboardClearEnabled(v)),
            ]),
            const SizedBox(height: 16),
            _section('Journal', [
              _tile(Icons.history_rounded, 'Journal de sécurité', 'Voir l\'historique des événements', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _SecurityLogScreen()))),
            ]),
            const SizedBox(height: 24),
            _securityTipsCard(),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePin(BuildContext context, SecurityProvider sec, bool enable) async {
    if (enable) {
      final pin = await _showPinSetupDialog(context);
      if (pin != null && context.mounted) await sec.setPin(pin);
    } else {
      final ok = await _showConfirmDialog(context, 'Désactiver le PIN', 'Entrez votre PIN actuel pour confirmer.');
      if (ok != null && ok && context.mounted) await sec.setPinEnabled(false);
    }
  }

  Future<String?> _showPinSetupDialog(BuildContext context) async {
    String pin = '';
    String confirm = '';
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Définir le code PIN', style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (v) => pin = v,
                decoration: const InputDecoration(labelText: 'PIN (4-6 chiffres)', counterText: ''),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (v) => confirm = v,
                decoration: const InputDecoration(labelText: 'Confirmer le PIN', counterText: ''),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                if (pin.length >= 4 && pin == confirm) {
                  Navigator.pop(ctx, pin);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Les PIN doivent correspondre (min. 4 chiffres)'), backgroundColor: Colors.redAccent),
                  );
                }
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String msg) async {
    final ctrl = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'PIN actuel'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final sec = context.read<SecurityProvider>();
              final ok = await sec.verifyPin(ctrl.text);
              if (ctx.mounted) Navigator.pop(ctx, ok);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog(BuildContext context, SecurityProvider sec) {
    final options = [0, 1, 2, 5, 10, 15, 30, 45];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Verrouillage automatique', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((m) => ListTile(
            title: Text(m == 0 ? 'Jamais' : '$m minute${m > 1 ? 's' : ''}', style: const TextStyle(color: AppTheme.textPrimary)),
            trailing: sec.timeoutMinutes == m ? const Icon(Icons.check_rounded, color: AppTheme.primary) : null,
            onTap: () {
              sec.setTimeoutMinutes(m);
              Navigator.pop(ctx);
            },
          )).toList(),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Container(
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppTheme.border, indent: 52),
              items[i],
            ],
          ]),
        ),
      ],
    );
  }

  Widget _switchTile(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primary, size: 22),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primary,
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 22),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }

  Widget _securityTipsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primary, size: 24),
              SizedBox(width: 10),
              Text('Conseils sécurité', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          _tip('Activez le PIN pour protéger l\'accès à votre portefeuille'),
          _tip('Ne partagez jamais votre clé privée ou votre phrase de récupération'),
          _tip('Vérifiez toujours l\'adresse avant d\'envoyer des fonds'),
          _tip('Méfiez-vous des emails et SMS demandant vos identifiants'),
          _tip('Utilisez un mot de passe fort et unique pour votre compte'),
        ],
      ),
    );
  }

  Widget _tip(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        Expanded(child: Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4))),
      ],
    ),
  );
}

class _SecurityLogScreen extends StatelessWidget {
  const _SecurityLogScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal de sécurité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              await context.read<SecurityProvider>().clearLog();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Consumer<SecurityProvider>(
        builder: (context, sec, _) {
          if (sec.securityLog.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Aucun événement', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sec.securityLog.length,
            itemBuilder: (_, i) {
              final e = sec.securityLog[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                child: Row(
                  children: [
                    Icon(_iconForType(e.type), color: AppTheme.primary, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.description, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(_formatDate(e.date), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'login': return Icons.login_rounded;
      case 'logout': return Icons.logout_rounded;
      case 'password_change': return Icons.lock_rounded;
      case 'copy': return Icons.copy_rounded;
      default: return Icons.security_rounded;
    }
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month && d.year == now.year) {
      return 'Aujourd\'hui ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
