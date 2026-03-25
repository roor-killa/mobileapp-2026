import 'package:shared_preferences/shared_preferences.dart';

/// Modèle Groq (API compatible OpenAI). Sur GroqCloud, le plus **léger** en production
/// pour le chat texte est **Llama 3.1 8B** (`llama-3.1-8b-instant`). Les vrais modèles ~3B
/// type « Llama 3.2 3B » ont été retirés côté Groq ; voir la liste à jour sur
/// https://console.groq.com/docs/models
///
/// Alternative possible dans `.env` Laravel : `GROQ_MODEL=openai/gpt-oss-20b`
class GroqConfig {
  static const String model = 'llama-3.1-8b-instant';
}

/// Clé Groq pour l’assistant **sans** passer par Laravel (secours).
/// Priorité : `--dart-define=GROQ_API_KEY=...` → valeur enregistrée dans les réglages.
class GroqDirectConfig {
  static const String _prefsKey = 'nodex_groq_api_key';
  static const String fromEnvironment = String.fromEnvironment('GROQ_API_KEY');

  static String? _fromPrefs;

  static Future<void> loadFromDisk() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_prefsKey)?.trim();
    _fromPrefs = (v == null || v.isEmpty) ? null : v;
  }

  static Future<void> reloadFromDisk() => loadFromDisk();

  /// Clé utilisable pour un appel direct à api.groq.com (vide si aucune).
  static String get effectiveKey {
    if (fromEnvironment.isNotEmpty) return fromEnvironment;
    return _fromPrefs ?? '';
  }

  static String? get savedKeyDisplay => _fromPrefs;

  static Future<void> saveToPrefs(String? raw) async {
    final p = await SharedPreferences.getInstance();
    if (raw == null || raw.trim().isEmpty) {
      await p.remove(_prefsKey);
      _fromPrefs = null;
      return;
    }
    final t = raw.trim();
    await p.setString(_prefsKey, t);
    _fromPrefs = t;
  }
}
