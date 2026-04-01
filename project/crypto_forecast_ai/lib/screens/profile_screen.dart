import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/secure_store.dart';

class ProfileScreen extends StatefulWidget {
  final Future<void> Function()? onLogout;

  const ProfileScreen({super.key, this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  Map<String, dynamic>? _me;

  bool _biometric = false;

  final _old = TextEditingController();
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();

  bool _changing = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _old.dispose();
    _new1.dispose();
    _new2.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _boot() async {
    try {
      _biometric = await SecureStore.getBiometricEnabled();
      final me = await api.me();
      setState(() {
        _me = me;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _snack("Impossible de charger le profil: $e");
    }
  }

  Future<void> _toggleBiometric(bool v) async {
    setState(() => _biometric = v);
    await SecureStore.setBiometricEnabled(v);
    _snack(v ? "BiomÃ©trie activÃ©e (option)" : "BiomÃ©trie dÃ©sactivÃ©e");
  }

  Future<void> _changePassword() async {
    final oldp = _old.text.trim();
    final n1 = _new1.text.trim();
    final n2 = _new2.text.trim();

    if (n1 != n2) return _snack("Les nouveaux mots de passe ne correspondent pas.");
    if (n1.length < 6) return _snack("Nouveau mot de passe trop court (min 6).");
    if (oldp.isEmpty) return _snack("Ancien mot de passe requis.");

    setState(() => _changing = true);
    try {
      final res = await api.changePassword(oldp, n1);
      _snack(res["message"]?.toString() ?? "Mot de passe modifiÃ©.");
      _old.clear();
      _new1.clear();
      _new2.clear();
    } catch (e) {
      _snack("Erreur: $e");
    } finally {
      if (mounted) setState(() => _changing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final me = _me ?? {};
    final first = (me["first_name"] ?? "").toString();
    final last = (me["last_name"] ?? "").toString();
    final phone = (me["phone"] ?? "").toString();
    final email = (me["email"] ?? "").toString();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: cs.surface.withOpacity(0.55),
            border: Border.all(color: cs.onSurface.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: cs.primaryContainer,
                child: Icon(Icons.person_rounded, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (first.isEmpty && last.isEmpty) ? "Utilisateur" : "$first $last",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(email, style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
                    if (phone.isNotEmpty)
                      Text(phone, style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
                  ],
                ),
              ),

                    const SizedBox(height: 16),
                    if (widget.onLogout != null)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await widget.onLogout!.call();
                          },
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Se dÃ©connecter', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),

            ],
          ),
        ),

        const SizedBox(height: 14),

        SwitchListTile(
          value: _biometric,
          onChanged: _toggleBiometric,
          title: const Text("Mode biomÃ©trie (option)"),
          subtitle: Text(
            "DÃ©mo: option stockÃ©e en local.",
            style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
          ),
        ),

        const SizedBox(height: 14),

        Text("Changer le mot de passe", style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface)),
        const SizedBox(height: 10),

        _Field(controller: _old, label: "Ancien mot de passe", icon: Icons.lock_outline_rounded, obscure: true),
        const SizedBox(height: 10),
        _Field(controller: _new1, label: "Nouveau mot de passe", icon: Icons.lock_rounded, obscure: true),
        const SizedBox(height: 10),
        _Field(controller: _new2, label: "Confirmer nouveau mot de passe", icon: Icons.lock_rounded, obscure: true),

        const SizedBox(height: 14),

        ElevatedButton.icon(
          onPressed: _changing ? null : _changePassword,
          icon: _changing
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.key_rounded),
          label: const Text("Mettre Ã  jour", style: TextStyle(fontWeight: FontWeight.w900)),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: cs.surface.withOpacity(0.55),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
