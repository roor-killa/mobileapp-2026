import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';

/// URL de l’API (tout ce qui finit par `/api` : carte, virements, assistant).
///
/// Ordre de priorité : **valeur enregistrée dans Réglages** → variable de compilation
/// `API_BASE_URL` → valeurs par défaut selon la plateforme.
class ApiConfig {
  static const String _prefsKey = 'nodex_api_base_url';
  static const String _fromEnv = String.fromEnvironment('API_BASE_URL');

  /// Chargée au lancement de l’app et après modification dans les réglages.
  static String? _savedInPrefs;

  static String _normalizeApiBase(String raw) {
    var u = raw.trim();
    if (u.endsWith('/')) u = u.substring(0, u.length - 1);
    if (!u.endsWith('/api')) u = '$u/api';
    return u;
  }

  /// À appeler dans `main()` avant `runApp`.
  static Future<void> loadFromDisk() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_prefsKey)?.trim();
    _savedInPrefs = (v == null || v.isEmpty) ? null : _normalizeApiBase(v);
  }

  /// Relecture disque (écran réglages).
  static Future<void> reloadFromDisk() => loadFromDisk();

  /// URL enregistrée par l’utilisateur (normalisée), ou null si automatique.
  static String? get userSavedBaseUrl => _savedInPrefs;

  /// Enregistre ou efface l’URL personnalisée.
  static Future<void> saveUserBaseUrl(String? raw) async {
    final p = await SharedPreferences.getInstance();
    if (raw == null || raw.trim().isEmpty) {
      await p.remove(_prefsKey);
      _savedInPrefs = null;
      return;
    }
    final n = _normalizeApiBase(raw.trim());
    await p.setString(_prefsKey, n);
    _savedInPrefs = n;
  }

  /// Origine pour le web : sans afficher de port si c’est 80 (http) ou 443 (https).
  static String _webOrigin(Uri u) {
    if (!u.hasScheme || u.host.isEmpty) return 'http://127.0.0.1';
    final def = u.scheme == 'https' ? 443 : 80;
    final port = u.hasPort ? u.port : def;
    final showPort = port != def;
    return '${u.scheme}://${u.host}${showPort ? ':$port' : ''}';
  }

  static String get baseUrl {
    if (_savedInPrefs != null && _savedInPrefs!.isNotEmpty) {
      return _savedInPrefs!;
    }
    if (_fromEnv.isNotEmpty) {
      return _normalizeApiBase(_fromEnv);
    }
    if (kIsWeb) {
      final u = Uri.base;
      if (u.host.isNotEmpty) {
        return '${_webOrigin(u)}/api';
      }
      // Même machine : `php artisan serve` annonce en général le port 8000.
      return 'http://127.0.0.1:8000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }
}
