import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final api = SupabaseService();
  bool loading = false;

  Future<void> _sendReset() async {
    final email = api.currentUserEmail;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email introuvable. Reconnecte-toi.")),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await api.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email de réinitialisation envoyé à $email ✅")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres de sécurité")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_reset_rounded),
              title: const Text("Réinitialiser le mot de passe"),
              subtitle: Text(
                "Un email sera envoyé à ${api.currentUserEmail ?? 'ton adresse'}",
              ),
              trailing: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded),
              onTap: loading ? null : _sendReset,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              "Conseil : vérifie aussi les spams.",
              style: TextStyle(color: Colors.white60),
            ),
          ),
        ],
      ),
    );
  }
}
