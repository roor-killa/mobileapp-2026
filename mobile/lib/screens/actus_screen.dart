import 'package:flutter/material.dart';

class ActusScreen extends StatelessWidget {
  const ActusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actus')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ActuCard(
            title: 'Bienvenue 👋',
            subtitle: 'Ici tu peux afficher des actus / annonces plus tard.',
          ),
          SizedBox(height: 12),
          _ActuCard(
            title: 'Astuce',
            subtitle: 'Connecte cette page à une table Supabase (ex: actus).',
          ),
        ],
      ),
    );
  }
}

class _ActuCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ActuCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
