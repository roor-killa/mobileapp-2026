import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  static String routeName = 'Settings';
  static String routePath = '/settings';

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final _auth = FirebaseAuth.instance;

  Future<void> _seDeconnecter() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/page-de-connexion', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = _auth.currentUser;

    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus(); FocusManager.instance.primaryFocus?.unfocus(); },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Header avec email ──────────────────
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                        ),
                        child: Stack(
                          children: [
                            // Fond dégradé
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [cs.primary.withOpacity(0.3), cs.primaryContainer],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // Avatar + email
                            Positioned(
                              bottom: 16,
                              left: 24,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: cs.primary,
                                    child: Icon(Icons.person, size: 36, color: cs.onPrimary),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    user?.email ?? 'Non connecté',
                                    style: TextStyle(
                                      color: cs.onSurface.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Section Information ────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
                        child: Text('Information', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 14)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: _buildMenuItem(
                          context,
                          icon: Icons.info_outline,
                          label: 'À Propos',
                          onTap: () => Navigator.pushNamed(context, '/a-propos'),
                        ),
                      ),

                      // ── Section Confidentialité ────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
                        child: Text('Confidentialité', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 14)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: _buildMenuItem(
                          context,
                          icon: Icons.privacy_tip_rounded,
                          label: 'Confidentialité',
                          onTap: () => Navigator.pushNamed(context, '/confidentialite'),
                        ),
                      ),

                      // ── Bouton déconnexion ─────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                        child: Center(
                          child: OutlinedButton(
                            onPressed: _seDeconnecter,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cs.error,
                              side: BorderSide(color: cs.outline),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Se déconnecter', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Navbar ─────────────────────────────────
              _buildNavbar(cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: cs.onSurface.withOpacity(0.6), size: 24),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbar(ColorScheme cs) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [BoxShadow(color: cs.onSurface.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: Icon(Icons.home_outlined, color: cs.onSurface.withOpacity(0.6)), onPressed: () => Navigator.pushNamed(context, '/accueil')),
          IconButton(icon: Icon(Icons.lock_outlined, color: cs.onSurface.withOpacity(0.6)), onPressed: () => Navigator.pushNamed(context, '/mot-de-passe')),
          IconButton(icon: Icon(Icons.settings, color: cs.primary), onPressed: () {}),
        ],
      ),
    );
  }
}
