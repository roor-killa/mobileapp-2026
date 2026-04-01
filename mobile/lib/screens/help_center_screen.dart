import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Centre d'aide")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FaqTile(
            q: "Comment envoyer des BKN ?",
            a: "Va dans Envoyer, saisis un montant, puis choisis un destinataire (QR ou email).",
          ),
          _FaqTile(
            q: "Pourquoi mon solde ne se met pas à jour ?",
            a: "Vérifie ta connexion internet. Tu peux aussi appuyer sur l’icône de rafraîchissement.",
          ),
          _FaqTile(
            q: "J’ai oublié mon mot de passe",
            a: "Va dans Profil > Paramètres de sécurité > Réinitialiser le mot de passe.",
          ),
          SizedBox(height: 12),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Contact : ajoute ici un email ou un lien (plus tard).",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String q;
  final String a;

  const _FaqTile({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(q, style: TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(a, style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
