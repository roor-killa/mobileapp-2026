import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/design_system.dart';
import '../theme/app_theme.dart';
import '../services/bank_service.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'security_screen.dart';

/// Écran Profil (style Figma ProfileScreen).
/// Bannière gradient, stats, bannière vérification, menus (Compte, Préférences, Support).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final BankService _bankService = BankService();
  Map<String, dynamic>? _user;
  bool _biometricOn = true;
  int _transactionsCount = 0;
  int _accountsCount = 0;
  String _savingsLabel = '—';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStats();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_data');
    if (raw == null) return;
    try {
      setState(() {
        _user = jsonDecode(raw) as Map<String, dynamic>;
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadStats() async {
    try {
      await _bankService.init();
      final accounts = await _bankService.getAccounts();
      final transactions = await _bankService.getTransactions();
      final total = accounts.fold<double>(0, (s, a) => s + a.balance);
      String savingsStr = '—';
      if (total >= 1000) {
        savingsStr = '${(total / 1000).toStringAsFixed(1)} k €';
      } else if (accounts.isNotEmpty) {
        savingsStr = '${total.toStringAsFixed(0)} €';
      }
      if (!mounted) return;
      setState(() {
        _transactionsCount = transactions.length;
        _accountsCount = accounts.length;
        _savingsLabel = savingsStr;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _transactionsCount = 0;
          _accountsCount = 0;
          _savingsLabel = '—';
        });
      }
    }
  }

  Future<void> _logout() async {
    await _bankService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (_user?['full_name'] ?? _user?['name'] ?? '') as String? ?? '';
    final email = (_user?['email'] ?? '') as String? ?? '';
    final initials = name.isEmpty ? '?' : name.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
    final darkModeOn = ThemeModeHolder.isDark;

    return Scaffold(
      backgroundColor: DesignSystem.gray100,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: DesignSystem.gray100,
        foregroundColor: DesignSystem.gray900,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Bannière gradient + avatar + stats
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(DesignSystem.space24, DesignSystem.space24, DesignSystem.space24, DesignSystem.space32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [DesignSystem.indigo600, DesignSystem.purple500],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: DesignSystem.indigo200,
                              child: Text(
                                initials,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DesignSystem.indigo600),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: DesignSystem.green400,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? 'Utilisateur' : name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            if (email.isNotEmpty)
                              Text(
                                email,
                                style: TextStyle(fontSize: 13, color: DesignSystem.indigo200),
                              ),
                            Text(
                              'Membre',
                              style: TextStyle(fontSize: 12, color: DesignSystem.indigo200),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _statCard('Transactions', '$_transactionsCount'),
                      const SizedBox(width: 12),
                      _statCard('Comptes', '$_accountsCount'),
                      const SizedBox(width: 12),
                      _statCard('Épargne', _savingsLabel),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bannière "Compte vérifié"
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DesignSystem.space24, 12, DesignSystem.space24, DesignSystem.space16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignSystem.white,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: DesignSystem.green100, shape: BoxShape.circle),
                      child: const Icon(Icons.verified_user_rounded, size: 18, color: DesignSystem.green600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Compte vérifié', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesignSystem.gray800)),
                          Text('Votre identité a été confirmée', style: TextStyle(fontSize: 11, color: DesignSystem.gray400)),
                        ],
                      ),
                    ),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: DesignSystem.green400, shape: BoxShape.circle)),
                  ],
                ),
              ),
            ),
          ),

          // Menus : Compte
          ..._buildMenuSection('Compte', [
            _MenuItem(icon: Icons.credit_card_rounded, label: 'Moyens de paiement', color: DesignSystem.indigo600, onTap: () => _showSnackBar('Vos comptes sont visibles dans l\'onglet Accueil et Cartes.')),
            _MenuItem(icon: Icons.shield_rounded, label: 'Sécurité et confidentialité', color: DesignSystem.green500, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen()))),
            _MenuItem(icon: Icons.notifications_rounded, label: 'Notifications', color: const Color(0xFFf59e0b), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          ]),

          // Préférences
          ..._buildMenuSection('Préférences', [
            _MenuItem(icon: Icons.dark_mode_rounded, label: 'Mode sombre', color: const Color(0xFF6366f1), toggle: true, value: darkModeOn, onToggle: () async { await ThemeModeHolder.setDark(!ThemeModeHolder.isDark); setState(() {}); }),
            _MenuItem(icon: Icons.fingerprint_rounded, label: 'Connexion biométrique', color: const Color(0xFF8b5cf6), toggle: true, value: _biometricOn, onToggle: () => setState(() => _biometricOn = !_biometricOn)),
            _MenuItem(icon: Icons.language_rounded, label: 'Langue', color: const Color(0xFF0ea5e9), valueText: 'Français', onTap: () => _showLanguageDialog(context)),
          ]),

          // Support
          ..._buildMenuSection('Support', [
            _MenuItem(icon: Icons.help_center_rounded, label: 'Centre d\'aide', color: DesignSystem.gray500, onTap: () => _showHelpDialog(context)),
            _MenuItem(icon: Icons.logout_rounded, label: 'Se déconnecter', color: DesignSystem.red500, danger: true, onTap: _logout),
          ]),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Center(
                child: Text(
                  'Version 2.4.1 • NeoBank © 2026',
                  style: TextStyle(fontSize: 11, color: DesignSystem.gray400),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: DesignSystem.gray800,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Langue'),
        content: const Text('L\'application est en français. D\'autres langues pourront être ajoutées ultérieurement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Centre d\'aide'),
        content: const SingleChildScrollView(
          child: Text(
            '• Consultez vos comptes depuis l\'onglet Accueil.\n'
            '• Effectuez un virement via l\'onglet Virement ou le bouton sur l\'Accueil.\n'
            '• Gérez vos cartes dans l\'onglet Cartes.\n'
            '• Consultez les analytiques dans l\'onglet Analytiques.\n'
            '• En cas de problème, contactez le support client.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(label, style: TextStyle(fontSize: 10, color: DesignSystem.indigo200)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuSection(String title, List<_MenuItem> entries) {
    final list = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DesignSystem.space24, 8, DesignSystem.space24, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DesignSystem.gray400, letterSpacing: 0.5),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space24),
          child: Container(
            decoration: BoxDecoration(
              color: DesignSystem.gray50,
              borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
            ),
            child: Column(
              children: entries.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMenuTile(item),
                    if (i < entries.length - 1) Divider(height: 1, color: DesignSystem.gray200),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    ];
    return list;
  }

  Widget _buildMenuTile(_MenuItem item) {
    return Material(
      color: item.danger ? DesignSystem.red50.withValues(alpha: 0.5) : null,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(fontSize: 14, color: item.danger ? DesignSystem.red500 : DesignSystem.gray900),
                ),
              ),
              if (item.toggle != null && item.toggle!)
                Switch(
                  value: item.value ?? false,
                  onChanged: (_) => item.onToggle?.call(),
                  activeTrackColor: DesignSystem.indigo600,
                )
              else if (item.valueText != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.valueText!, style: TextStyle(fontSize: 13, color: DesignSystem.gray400)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 18, color: DesignSystem.gray400),
                  ],
                )
              else if (!item.danger)
                Icon(Icons.chevron_right_rounded, size: 18, color: DesignSystem.gray400),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final bool? toggle;
  final bool? value;
  final String? valueText;
  final bool danger;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    this.toggle,
    this.value,
    this.valueText,
    this.danger = false,
    this.onTap,
    this.onToggle,
  });
}
