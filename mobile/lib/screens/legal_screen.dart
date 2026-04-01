import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  Future<String> _load(String assetPath) => rootBundle.loadString(assetPath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informations légales')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            context,
            title: 'Politique de confidentialité',
            subtitle: 'Comment nous traitons tes données',
            asset: 'assets/legal/privacy_policy.md',
          ),
          const SizedBox(height: 10),
          _tile(
            context,
            title: 'Conditions d’utilisation',
            subtitle: 'Règles et limitations',
            asset: 'assets/legal/terms_of_service.md',
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, {required String title, required String subtitle, required String asset}) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final text = await _load(asset);
          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _LegalTextScreen(title: title, text: text),
            ),
          );
        },
      ),
    );
  }
}

class _LegalTextScreen extends StatelessWidget {
  final String title;
  final String text;

  const _LegalTextScreen({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            text,
            style: const TextStyle(height: 1.35),
          ),
        ),
      ),
    );
  }
}
