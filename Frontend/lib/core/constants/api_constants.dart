class ApiConstants {
  // Android émulateur → 10.0.2.2 | iOS simulateur / physique → IP de ta machine
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // Auth
  static const String register = '$baseUrl/auth/register';
  static const String login    = '$baseUrl/auth/login';
  static const String logout   = '$baseUrl/auth/logout';
  static const String me       = '$baseUrl/auth/me';

  // Transfert
  static const String transfer = '$baseUrl/transfer';

  // Recharge
  static const String createIntent = '$baseUrl/recharge/create-intent';

  // Historique
  static const String history = '$baseUrl/history';

  // Profil
  static const String profile         = '$baseUrl/profile';
  static const String changePassword  = '$baseUrl/profile/password';
  static const String changePin       = '$baseUrl/profile/pin';

  // QR Code
  static const String qrGenerate = '$baseUrl/qr/generate';
  static const String qrScan     = '$baseUrl/qr/scan';

  // Chatbot
  static const String chatbot = '$baseUrl/chatbot/message';
}
