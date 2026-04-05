import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/login_page.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Profil',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── En-tête profil ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          user?.initials ?? '??',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: AppColors.primary, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName ?? '...',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(user?.phone ?? '',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.kycStatus == 'approved' ? '✓ Vérifié' : '⏳ En attente',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Menu ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _MenuSection(title: 'Compte', items: [
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Modifier mon profil',
                      onTap: () => _showEditProfile(context),
                    ),
                    _MenuItem(
                      icon: Icons.lock_outline_rounded,
                      label: 'Changer le mot de passe',
                      onTap: () => _showChangePassword(context),
                    ),
                    _MenuItem(
                      icon: Icons.pin_outlined,
                      label: 'Changer le PIN',
                      onTap: () => _showChangePin(context),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _MenuSection(title: 'Sécurité', items: [
                    _MenuItem(
                      icon: Icons.security_rounded,
                      label: 'Vérification KYC',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Bientôt',
                            style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.devices_rounded,
                      label: 'Sessions actives',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Bientôt',
                            style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _MenuSection(title: 'Application', items: [
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'À propos',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'TransfertApp',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2026 TransfertApp',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Déconnexion
                  CustomButton(
                    label: 'Se déconnecter',
                    isOutlined: true,
                    icon: Icons.logout_rounded,
                    color: AppColors.error,
                    onPressed: () => _confirmLogout(context),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Modifier le profil ────────────────────────────────────────────────────
  void _showEditProfile(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final firstCtrl = TextEditingController(text: user?.firstName);
    final lastCtrl  = TextEditingController(text: user?.lastName);
    final emailCtrl = TextEditingController(text: user?.email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Modifier le profil',
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: CustomTextField(controller: firstCtrl, label: 'Prénom')),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(controller: lastCtrl, label: 'Nom')),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(controller: emailCtrl, label: 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Enregistrer',
              onPressed: () async {
                try {
                  await ApiService.instance.put(ApiConstants.profile, {
                    'first_name': firstCtrl.text.trim(),
                    'last_name': lastCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                  });
                  if (context.mounted) {
                    await context.read<AuthProvider>().checkAuth();
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Profil mis à jour !'),
                      backgroundColor: AppColors.success,
                    ));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.error,
                    ));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Changer mot de passe ─────────────────────────────────────────────────
  void _showChangePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Changer le mot de passe',
        child: Column(
          children: [
            CustomTextField(controller: currentCtrl, label: 'Mot de passe actuel', obscureText: true, prefixIcon: Icons.lock_outline),
            const SizedBox(height: 14),
            CustomTextField(controller: newCtrl, label: 'Nouveau mot de passe', obscureText: true, prefixIcon: Icons.lock_rounded),
            const SizedBox(height: 14),
            CustomTextField(controller: confirmCtrl, label: 'Confirmer le nouveau', obscureText: true, prefixIcon: Icons.lock_rounded),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Changer le mot de passe',
              onPressed: () async {
                if (newCtrl.text != confirmCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Les mots de passe ne correspondent pas'),
                    backgroundColor: AppColors.error,
                  ));
                  return;
                }
                try {
                  await ApiService.instance.post(ApiConstants.changePassword, {
                    'current_password': currentCtrl.text,
                    'password': newCtrl.text,
                    'password_confirmation': confirmCtrl.text,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().logout();
                  }
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (_) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.error,
                    ));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Changer PIN ───────────────────────────────────────────────────────────
  void _showChangePin(BuildContext context) {
    final passwordCtrl  = TextEditingController();
    final currentPinCtrl = TextEditingController();
    final newPinCtrl    = TextEditingController();
    final confirmPinCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Changer le PIN',
        child: Column(
          children: [
            CustomTextField(controller: passwordCtrl, label: 'Mot de passe', obscureText: true, prefixIcon: Icons.lock_outline),
            const SizedBox(height: 14),
            CustomTextField(controller: currentPinCtrl, label: 'PIN actuel', obscureText: true, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], maxLength: 6),
            const SizedBox(height: 14),
            CustomTextField(controller: newPinCtrl, label: 'Nouveau PIN', obscureText: true, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], maxLength: 6),
            const SizedBox(height: 14),
            CustomTextField(controller: confirmPinCtrl, label: 'Confirmer le PIN', obscureText: true, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], maxLength: 6),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Changer le PIN',
              onPressed: () async {
                if (newPinCtrl.text != confirmPinCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Les PIN ne correspondent pas'),
                    backgroundColor: AppColors.error,
                  ));
                  return;
                }
                try {
                  await ApiService.instance.post(ApiConstants.changePin, {
                    'password': passwordCtrl.text,
                    'current_pin': currentPinCtrl.text,
                    'new_pin': newPinCtrl.text,
                    'new_pin_confirmation': confirmPinCtrl.text,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('PIN changé avec succès !'),
                      backgroundColor: AppColors.success,
                    ));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.error,
                    ));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Confirmer déconnexion ─────────────────────────────────────────────────
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Déconnecter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets réutilisables ───────────────────────────────────────────────────
class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    const Divider(height: 1, indent: 56, color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _BottomSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
