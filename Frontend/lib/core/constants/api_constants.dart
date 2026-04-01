import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Pour le debug local / emulator. Adapte automatiquement selon la plateforme.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api/v1';
    if (Platform.isAndroid)
      return 'http://172.26.143.160:8000/api/v1'; // IP de l'hôte Windows
    if (Platform.isIOS) return 'http://localhost:8000/api/v1';
    return 'http://localhost:8000/api/v1';
  }

  // Auth
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get logout => '$baseUrl/auth/logout';
  static String get me => '$baseUrl/auth/me';

  // Transfert
  static String get transfer => '$baseUrl/transfer';

  // Recharge
  static String get createIntent => '$baseUrl/recharge/create-intent';

  // Historique
  static String get history => '$baseUrl/history';

  // Profil
  static String get profile => '$baseUrl/profile';
  static String get changePassword => '$baseUrl/profile/password';
  static String get changePin => '$baseUrl/profile/pin';

  // QR Code
  static String get qrGenerate => '$baseUrl/qr/generate';
  static String get qrScan => '$baseUrl/qr/scan';

  // Chatbot
  static String get chatbot => '$baseUrl/chatbot/message';
}
