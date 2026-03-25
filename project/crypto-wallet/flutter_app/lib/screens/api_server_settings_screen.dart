import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../config/api_config.dart';
import '../config/groq_config.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';

/// Permet de coller l’URL du backend sans passer par la ligne de commande.
class ApiServerSettingsScreen extends StatefulWidget {
  const ApiServerSettingsScreen({super.key});

  @override
  State<ApiServerSettingsScreen> createState() => _ApiServerSettingsScreenState();
}

class _ApiServerSettingsScreenState extends State<ApiServerSettingsScreen> {
  final _controller = TextEditingController();
  final _groqController = TextEditingController();
  bool _loading = true;
  bool _hideGroq = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ApiConfig.reloadFromDisk();
    await GroqDirectConfig.reloadFromDisk();
    if (mounted) {
      setState(() {
        _controller.text = ApiConfig.userSavedBaseUrl ?? '';
        _groqController.text = GroqDirectConfig.savedKeyDisplay ?? '';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _groqController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = _controller.text.trim();
    final g = _groqController.text.trim();
    await ApiConfig.saveUserBaseUrl(t.isEmpty ? null : t);
    await GroqDirectConfig.saveToPrefs(g.isEmpty ? null : g);
    if (!mounted) return;
    await context.read<AuthProvider>().syncApiToken();
    await context.read<WalletProvider>().fetch(context.read<AuthProvider>().user?.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.isEmpty ? 'Réglage automatique réactivé.' : 'Adresse enregistrée. Données actualisées.'),
        backgroundColor: AppTheme.primary,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Serveur & assistant')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Adresse du serveur NodEX (virements, carte, etc.) : URL qui se termine souvent par /api. '
                  'Laissez vide pour le réglage automatique.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  autocorrect: false,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Adresse de l’API NodEX',
                    hintText: 'URL complète se terminant par /api',
                    hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                    filled: true,
                    fillColor: AppTheme.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Clé Groq (assistant IA) : optionnelle. Si le serveur NodEX ne répond pas ou n’a pas de clé, '
                  'l’app peut interroger Groq directement (Llama 3.1 8B). Créez une clé sur console.groq.com.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _groqController,
                  autocorrect: false,
                  obscureText: _hideGroq,
                  style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    labelText: 'Clé API Groq (gsk_…)',
                    suffixIcon: IconButton(
                      icon: Icon(_hideGroq ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AppTheme.textSecondary),
                      onPressed: () => setState(() => _hideGroq = !_hideGroq),
                    ),
                    filled: true,
                    fillColor: AppTheme.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Enregistrer et actualiser'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    _controller.clear();
                    _groqController.clear();
                  },
                  child: const Text('Tout vider (API auto + sans clé Groq locale)'),
                ),
              ],
            ),
    );
  }
}
