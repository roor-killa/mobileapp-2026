import 'package:flutter/material.dart';

import '../services/account_manager.dart';

class AccountSwitcherScreen extends StatefulWidget {
  const AccountSwitcherScreen({super.key});

  @override
  State<AccountSwitcherScreen> createState() => _AccountSwitcherScreenState();
}

class _AccountSwitcherScreenState extends State<AccountSwitcherScreen> {
  final mgr = AccountManager();
  bool loading = true;
  List<Map<String, dynamic>> accounts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      accounts = await mgr.listAccounts();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _switch(Map<String, dynamic> a) async {
    final token = (a['refreshToken'] ?? '').toString();
    if (token.isEmpty) return;

    try {
      await mgr.switchToRefreshToken(token);
      if (!mounted) return;
      Navigator.pop(context, true); // switched
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur switch: $e')),
      );
    }
  }

  Future<void> _remove(Map<String, dynamic> a) async {
    final uid = (a['uid'] ?? '').toString();
    if (uid.isEmpty) return;
    await mgr.removeAccount(uid);
    await _load();
  }

  Future<void> _add() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _AddAccountDialog(),
    );
    if (ok == true) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte ajouté ✅')),
      );
      // Note: addAccount signs in => active session changed already.
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changer de compte')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Column(
                    children: [
                      if (accounts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Aucun compte enregistré pour l’instant.'),
                        ),
                      for (final a in accounts)
                        ListTile(
                          leading: const Icon(Icons.person_outline_rounded),
                          title: Text((a['label'] ?? a['email'] ?? 'Compte').toString()),
                          subtitle: Text((a['email'] ?? '').toString()),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'remove') _remove(a);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'remove', child: Text('Supprimer')),
                            ],
                          ),
                          onTap: () => _switch(a),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un compte'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Astuce: Tu peux enregistrer un compte en te connectant une fois puis en revenant ici.',
                  style: TextStyle(color: Colors.white60),
                ),
              ],
            ),
    );
  }
}

class _AddAccountDialog extends StatefulWidget {
  const _AddAccountDialog();

  @override
  State<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<_AddAccountDialog> {
  final mgr = AccountManager();
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final e = email.text.trim();
    final p = pass.text;
    if (e.isEmpty || p.isEmpty) return;

    setState(() => loading = true);
    try {
      await mgr.addAccount(email: e, password: p);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $err')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un compte'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: pass,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Mot de passe'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: loading ? null : _submit,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
