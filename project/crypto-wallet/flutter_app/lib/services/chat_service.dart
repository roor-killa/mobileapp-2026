import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/groq_config.dart';
import 'api_client.dart';

/// Assistant NodEX : d’abord le proxy Laravel (contexte compte réel), sinon Groq direct
/// (clé `GROQ_API_KEY` en dart-define ou dans Réglages → Serveur NodEX).
class ChatService {
  static const _systemPrompt =
      'Tu es l\'assistant virtuel de NodEX, une application de portefeuille crypto. '
      'Tu aides avec les virements, l\'achat de cryptos, la carte virtuelle, etc. '
      'Réponds de manière concise et utile en français. '
      'Pour le solde en euros, les montants de crypto et les virements du compte connecté, '
      'tu dois t\'appuyer sur le bloc « Données réelles » ou « Contexte local » ; '
      'ne jamais inventer de chiffres.';

  final List<Map<String, String>> _history = [];

  static bool _shouldTryDirectGroq(int statusCode) {
    return statusCode == 503 || statusCode == 502 || statusCode == 500 || statusCode == 404;
  }

  /// Réponse texte Groq uniquement si HTTP 200.
  Future<String> _callGroqDirectHttp(List<Map<String, dynamic>> messages) async {
    final key = GroqDirectConfig.effectiveKey;
    final res = await http
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $key',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': GroqConfig.model,
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': 1024,
          }),
        )
        .timeout(const Duration(seconds: 50));
    if (res.statusCode != 200) {
      final short = res.body.length > 180 ? '${res.body.substring(0, 180)}…' : res.body;
      throw Exception('HTTP ${res.statusCode} : $short');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    final msg = choices?.isNotEmpty == true ? choices!.first['message'] as Map<String, dynamic>? : null;
    return msg?['content'] as String? ?? 'Aucune réponse.';
  }

  /// Essaie Groq direct ; en cas de succès ajoute à l’historique et renvoie le texte + note affichée.
  Future<String?> _tryDirectGroq({
    required List<Map<String, dynamic>> messages,
    required String modeNote,
  }) async {
    if (GroqDirectConfig.effectiveKey.isEmpty) return null;
    try {
      final content = await _callGroqDirectHttp(messages);
      _history.add({'role': 'assistant', 'content': content});
      return '$content\n\n$modeNote';
    } catch (e) {
      return 'Groq direct a échoué : ${e.toString().length > 200 ? '${e.toString().substring(0, 200)}…' : e}';
    }
  }

  /// [localAccountFacts] : solde / IBAN affichés dans l’app (mode secours).
  Future<String> sendMessage(String text, {String? localAccountFacts}) async {
    _history.add({'role': 'user', 'content': text});
    var tail = List<Map<String, String>>.from(_history);
    if (tail.length > 16) tail = tail.sublist(tail.length - 16);

    final systemLaravel = _systemPrompt;
    final systemDirect = localAccountFacts != null && localAccountFacts.trim().isNotEmpty
        ? '$_systemPrompt\n\n--- Contexte local (écran de l’app, peut être incomplet) ---\n${localAccountFacts.trim()}'
        : _systemPrompt;

    List<Map<String, dynamic>> directMessages() => [
          {'role': 'system', 'content': systemDirect},
          ...tail.map((m) => {'role': m['role']!, 'content': m['content']!}),
        ];

    const notePasServeur =
        '_(Mode secours : réponse via **Groq** (Llama 3.1 8B), sans le serveur NodEX — soldes peut‑être partiels.)_';
    const note503 =
        '_(Mode secours : le serveur NodEX n’expose pas la clé Groq ; réponse directe avec le contexte local.)_';
    const note401 =
        '_(Mode secours : session serveur non reconnue ; réponse basée sur le contexte local.)_';

    try {
      final res = await ApiClient().post('/chat/groq', {
        'model': GroqConfig.model,
        'messages': [
          {'role': 'system', 'content': systemLaravel},
          ...tail,
        ],
        'temperature': 0.7,
        'max_tokens': 1024,
      });

      if (res.statusCode == 401) {
        final r = await _tryDirectGroq(messages: directMessages(), modeNote: note401);
        if (r != null) return r;
        return 'Session expirée ou non connecté. Reconnectez-vous pour utiliser l’assistant via le serveur NodEX.';
      }

      if (res.statusCode == 503) {
        final r = await _tryDirectGroq(messages: directMessages(), modeNote: note503);
        if (r != null) return r;
        return 'Le serveur NodEX n’a pas de clé Groq. Ajoutez GROQ_API_KEY dans le .env du backend '
            '(https://console.groq.com/keys), ou une clé dans Réglages → Serveur NodEX.';
      }

      if (res.statusCode != 200) {
        if (_shouldTryDirectGroq(res.statusCode)) {
          final r = await _tryDirectGroq(messages: directMessages(), modeNote: notePasServeur);
          if (r != null) return r;
        }
        try {
          final errMap = jsonDecode(res.body) as Map<String, dynamic>?;
          final m = errMap?['message'];
          if (m != null) return m is String ? m : m.toString();
        } catch (_) {}
        final err = res.body.length > 120 ? '${res.body.substring(0, 120)}…' : res.body;
        return 'Erreur API (${res.statusCode}) : $err';
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      final msg = choices?.isNotEmpty == true ? choices!.first['message'] as Map<String, dynamic>? : null;
      final content = msg?['content'] as String? ?? 'Aucune réponse.';
      _history.add({'role': 'assistant', 'content': content});
      return content;
    } catch (e) {
      final s = e.toString();
      final isNet = s.contains('SocketException') ||
          s.contains('Connection refused') ||
          s.contains('Failed host lookup') ||
          s.contains('Network is unreachable') ||
          s.contains('TimeoutException');

      if (isNet) {
        final r = await _tryDirectGroq(messages: directMessages(), modeNote: notePasServeur);
        if (r != null) return r;
        return 'Pas de connexion au serveur NodEX et aucune clé Groq dans l’app. '
            'Ouvrez Réglages → Serveur NodEX (adresse API + clé Groq optionnelle), '
            'ou lancez Laravel avec GROQ_API_KEY dans le .env.';
      }
      return 'Erreur : ${s.length > 220 ? '${s.substring(0, 220)}…' : s}';
    }
  }
}
