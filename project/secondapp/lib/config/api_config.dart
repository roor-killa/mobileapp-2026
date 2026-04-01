import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Base URL du json-server Docker (`SECONDAPP/docker-compose.yml` → port 3001).
///
/// Surcharge : `flutter run --dart-define=JSON_SERVER_BASE_URL=http://192.168.x.x:3001`
class ApiConfig {
  ApiConfig._();

  static const String _envKey = 'JSON_SERVER_BASE_URL';

  static String get jsonServerBaseUrl {
    const fromEnv = String.fromEnvironment(_envKey, defaultValue: '');
    if (fromEnv.isNotEmpty) {
      return fromEnv.replaceAll(RegExp(r'/$'), '');
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:3001';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://127.0.0.1:3001';
  }

  static Uri get dashboardUri => Uri.parse('$jsonServerBaseUrl/dashboard');
}
