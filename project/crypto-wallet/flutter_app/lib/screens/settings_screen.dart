import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/security_provider.dart';
import '../providers/wallet_provider.dart';
import 'api_server_settings_screen.dart';
import 'chat_screen.dart';
import 'ondes_screen.dart';
import 'security_settings_screen.dart';

String _initial(String s) => s.trim().isNotEmpty ? s.trim()[0].toUpperCase() : '?';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Réglages')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final u = auth.user;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ProfileScreen(name: u?.name, email: u?.email))),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primary, radius: 28,
                        child: Text(_initial(u?.name ?? u?.email ?? '?'), style: const TextStyle(color: Color(0xFF042028), fontWeight: FontWeight.bold, fontSize: 22)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (u?.name != null && u!.name!.isNotEmpty) Text(u.name!, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                        Text(u?.email ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                      ])),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _section('Général', [
                _item(Icons.dns_rounded, 'Serveur & assistant (IA)', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApiServerSettingsScreen()))),
                _item(Icons.waves_rounded, 'Ondes', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OndesScreen()))),
                _item(Icons.language_rounded, 'Devise', 'EUR', () => _showDeviseDialog(context)),
                _item(Icons.palette_outlined, 'Thème', 'Sombre', () => _showSnack(context, 'Thème sombre activé')),
                _item(Icons.notifications_none_rounded, 'Notifications', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _NotifSettingsScreen()))),
              ]),
              const SizedBox(height: 16),
              _section('Sécurité', [
                _item(Icons.security_rounded, 'Paramètres de sécurité', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()))),
                _item(Icons.devices_rounded, 'Se déconnecter de tous les appareils', null, () => _showSignOutAllDialog(context, auth)),
                _item(Icons.fingerprint_rounded, 'Biométrie', null, () => _showBiometricDialog(context)),
                _item(Icons.lock_outline_rounded, 'Changer le mot de passe', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _ChangePasswordScreen()))),
                _item(Icons.shield_outlined, 'Authentification 2FA', null, () => _show2FADialog(context)),
              ]),
              const SizedBox(height: 16),
              _section('Compte', [
                _item(Icons.receipt_long_rounded, 'Relevés de compte', null, () => _showSnack(context, 'Relevés téléchargés')),
                _item(Icons.help_outline_rounded, 'Aide & Support', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _HelpScreen()))),
                _item(Icons.star_outline_rounded, 'Noter l\'application', null, () => _showSnack(context, 'Merci pour votre avis !')),
              ]),
              const SizedBox(height: 16),
              _section('À propos', [
                _item(Icons.info_outline_rounded, 'Version', '1.0.0', null),
                _item(Icons.description_outlined, 'Conditions d\'utilisation', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _LegalScreen(title: 'Conditions d\'utilisation')))),
                _item(Icons.privacy_tip_outlined, 'Politique de confidentialité', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _LegalScreen(title: 'Politique de confidentialité')))),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    context.read<SecurityProvider>().addLog('logout', 'Déconnexion');
                    context.read<WalletProvider>().resetForLogout();
                    await auth.logout();
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  label: const Text('Se déconnecter', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _showDeleteDialog(context, auth),
                  child: const Text('Supprimer mon compte', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500))),
      Container(
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppTheme.border, indent: 52),
            items[i],
          ],
        ]),
      ),
    ]);
  }

  Widget _item(IconData icon, String label, String? trailing, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 22),
      title: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (trailing != null) Text(trailing, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
      ]),
      onTap: onTap,
    );
  }

  static void _showSnack(BuildContext ctx, String msg) => ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.primary));

  static void _showDeviseDialog(BuildContext ctx) {
    showDialog(context: ctx, builder: (c) => SimpleDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Devise', style: TextStyle(color: AppTheme.textPrimary)),
      children: ['EUR (\u20AC)', 'USD (\$)', 'GBP (£)', 'CHF'].map((d) => SimpleDialogOption(
        onPressed: () { Navigator.pop(c); _showSnack(ctx, 'Devise : $d'); },
        child: Text(d, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
      )).toList(),
    ));
  }

  static void _showBiometricDialog(BuildContext ctx) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Biométrie', style: TextStyle(color: AppTheme.textPrimary)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.fingerprint_rounded, color: AppTheme.primary, size: 64),
        const SizedBox(height: 16),
        const Text('Utilisez Face ID ou Touch ID pour déverrouiller NodEX et confirmer les paiements.', style: TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annuler')),
        ElevatedButton(onPressed: () { Navigator.pop(c); _showSnack(ctx, 'Biométrie activée'); }, child: const Text('Activer')),
      ],
    ));
  }

  static void _show2FADialog(BuildContext ctx) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Double authentification', style: TextStyle(color: AppTheme.textPrimary)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.shield_rounded, color: AppTheme.primary, size: 64),
        const SizedBox(height: 16),
        const Text('Protégez votre compte avec un code à usage unique via une app d\'authentification (Google Authenticator, Authy).', style: TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annuler')),
        ElevatedButton(onPressed: () { Navigator.pop(c); _showSnack(ctx, '2FA activé'); }, child: const Text('Activer')),
      ],
    ));
  }

  static void _showSignOutAllDialog(BuildContext ctx, AuthProvider auth) {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion de tous les appareils', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Vous serez déconnecté sur cet appareil et sur tous les autres (téléphone, tablette, etc.). Vous devrez vous reconnecter partout.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(c);
              c.read<WalletProvider>().resetForLogout();
              await auth.logoutFromAllDevices();
              if (c.mounted) _showSnack(c, 'Déconnecté de tous les appareils');
            },
            child: const Text('Déconnecter partout'),
          ),
        ],
      ),
    );
  }

  static void _showDeleteDialog(BuildContext ctx, AuthProvider auth) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Supprimer le compte', style: TextStyle(color: Colors.redAccent)),
      content: const Text('Cette action est irréversible. Toutes vos données et vos fonds seront perdus.', style: TextStyle(color: AppTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annuler')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () { Navigator.pop(c); c.read<WalletProvider>().resetForLogout(); auth.logout(); }, child: const Text('Supprimer')),
      ],
    ));
  }
}

class _ProfileScreen extends StatelessWidget {
  final String? name;
  final String? email;
  const _ProfileScreen({this.name, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(child: CircleAvatar(backgroundColor: AppTheme.primary, radius: 48, child: Text(_initial(name ?? email ?? '?'), style: const TextStyle(color: Color(0xFF042028), fontSize: 36, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 24),
        _infoTile('Nom', name ?? '-'),
        _infoTile('Email', email ?? '-'),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour'), backgroundColor: AppTheme.primary)), child: const Text('Modifier le profil')),
      ]),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _ChangePasswordScreen extends StatefulWidget {
  const _ChangePasswordScreen();

  @override
  State<_ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<_ChangePasswordScreen> {
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  @override
  void dispose() { _new1.dispose(); _new2.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final pwd = _new1.text;
    final conf = _new2.text;

    if (pwd.isEmpty || conf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.redAccent));
      return;
    }
    if (pwd.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le mot de passe doit contenir au moins 8 caractères'), backgroundColor: Colors.redAccent));
      return;
    }
    if (pwd != conf) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les mots de passe ne correspondent pas'), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().updatePassword(pwd);
      if (mounted) {
        context.read<SecurityProvider>().addLog('password_change', 'Mot de passe modifié');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe changé avec succès'), backgroundColor: AppTheme.primary));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changer le mot de passe')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _new1,
              obscureText: _obscure1,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe (min. 8 caractères)',
                prefixIcon: const Icon(Icons.lock_rounded, color: AppTheme.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _new2,
              obscureText: _obscure2,
              decoration: InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
                prefixIcon: const Icon(Icons.lock_rounded, color: AppTheme.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Utilisez un mot de passe fort : majuscules, minuscules, chiffres et caractères spéciaux.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _loading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Changer le mot de passe'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifSettingsScreen extends StatefulWidget {
  const _NotifSettingsScreen();

  @override
  State<_NotifSettingsScreen> createState() => _NotifSettingsScreenState();
}

class _NotifSettingsScreenState extends State<_NotifSettingsScreen> {
  bool _push = true;
  bool _email = true;
  bool _transactions = true;
  bool _security = true;
  bool _promos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _sw('Notifications push', _push, (v) => setState(() => _push = v)),
        _sw('Notifications email', _email, (v) => setState(() => _email = v)),
        _sw('Transactions', _transactions, (v) => setState(() => _transactions = v)),
        _sw('Alertes sécurité', _security, (v) => setState(() => _security = v)),
        _sw('Promotions', _promos, (v) => setState(() => _promos = v)),
      ]),
    );
  }

  Widget _sw(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
      child: SwitchListTile(title: Text(label, style: const TextStyle(color: AppTheme.textPrimary)), value: value, onChanged: onChanged, activeColor: AppTheme.primary),
    );
  }
}

class _HelpScreen extends StatelessWidget {
  const _HelpScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aide & Support')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _faq('Comment envoyer des cryptos ?', 'Allez dans Accueil > Envoyer, sélectionnez le wallet, entrez l\'adresse et le montant.'),
        _faq('Comment acheter des cryptos ?', 'Allez dans Accueil > Acheter, choisissez la crypto et le montant en euros.'),
        _faq('Comment recevoir un virement ?', 'Allez dans Virement > Recevoir : vous y voyez votre IBAN et pseudonyme. Copiez le RIB ou l’IBAN et envoyez-les à celui qui doit vous virer de l’argent.'),
        _faq('Comment bloquer ma carte ?', 'Allez dans Carte > Bloquer. Vous pouvez la débloquer à tout moment.'),
        _faq('Comment contacter le support ?', 'Envoyez un email à support@nodex.app ou appelez le 01 23 45 67 89.'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.chat_rounded),
          label: const Text('Assistant NodEX'),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
        ),
      ]),
    );
  }

  Widget _faq(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        title: Text(q, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
        iconColor: AppTheme.primary, collapsedIconColor: AppTheme.textSecondary,
        children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text(a, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)))],
      ),
    );
  }
}

class _LegalScreen extends StatelessWidget {
  final String title;
  const _LegalScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          'NodEX - $title\n\n'
          'Dernière mise à jour : 4 mars 2026\n\n'
          '1. Acceptation des conditions\nEn utilisant l\'application NodEX, vous acceptez les présentes conditions d\'utilisation.\n\n'
          '2. Services proposés\nNodEX fournit des services de portefeuille de crypto-monnaies, de virements bancaires et de carte de paiement virtuelle.\n\n'
          '3. Responsabilité\nNodEX ne peut être tenu responsable des pertes liées aux fluctuations des marchés de crypto-monnaies.\n\n'
          '4. Données personnelles\nVos données sont traitées conformément au RGPD. Pour plus d\'informations, consultez notre politique de confidentialité.\n\n'
          '5. Contact\nPour toute question : support@nodex.app',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.6),
        ),
      ),
    );
  }
}
