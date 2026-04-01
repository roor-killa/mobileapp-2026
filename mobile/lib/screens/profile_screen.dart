import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';
import 'security_screen.dart';
import 'help_center_screen.dart';
import 'stats_screen.dart';
import 'account_switcher_screen.dart';
import '../services/account_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final api = SupabaseService();

  bool _loading = true;

  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _tel = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _tel.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final p = await api.getProfile();
      if (!mounted) return;
      setState(() {
        _nom.text = (p['nom'] ?? '').toString();
        _prenom.text = (p['prenom'] ?? '').toString();
        _tel.text = (p['telephone'] ?? '').toString();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur profil: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      await api.updateProfile(
        nom: _nom.text.trim(),
        prenom: _prenom.text.trim(),
        telephone: _tel.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil mis à jour ✅')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur sauvegarde: $e')));
    }
  }

  Future<void> _resetPassword() async {
    final email = api.currentEmail;
    if (email == null) return;
    await api.sendPasswordResetEmail(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email de réinitialisation envoyé ✅')),
    );
  }

  Future<void> _logout() async {
    await api.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = api.currentEmail ?? '—';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_circle, size: 40),
              title: Text(email),
              subtitle: const Text('Compte'),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Column(
                      children: [
                        TextField(
                          controller: _nom,
                          decoration: const InputDecoration(labelText: 'Nom'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _prenom,
                          decoration: const InputDecoration(
                            labelText: 'Prénom',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _tel,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save),
                            label: const Text('Enregistrer'),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.switch_account_rounded),
                  title: const Text('Changer de compte'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await AccountManager().saveCurrentSession();
                    if (!mounted) return;
                    final switched = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountSwitcherScreen(),
                      ),
                    );
                    if (switched == true && mounted) {
                      await _load();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Compte changé ✅')),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security_rounded),
                  title: const Text('Paramètres de sécurité'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SecurityScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: const Text("Centre d'aide"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bar_chart_rounded),
                  title: const Text('Statistiques'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatsScreen()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Réinitialiser le mot de passe'),
                  onTap: _resetPassword,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Se déconnecter'),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
