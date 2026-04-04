class ApiConstants {
  ApiConstants._();

  // ─── URL de base ───────────────────────────────────────────────────────────
  // Émulateur Android  : http://10.0.2.2:8000/api
  // Simulateur iOS     : http://localhost:8000/api
  // Appareil physique  : http://<VOTRE_IP_LAN>:8000/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // ─── Auth ──────────────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login    = '/auth/login';
  static const String logout   = '/auth/logout';
  static const String me       = '/auth/me';

  // ─── Dashboard ─────────────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';

  // ─── Transactions ──────────────────────────────────────────────────────────
  static const String transactions = '/transactions';
  static const String sendMoney    = '/transactions/send';

  // ─── QR Code ───────────────────────────────────────────────────────────────
  static const String qrGenerate = '/qr/generate';
  static const String qrScan     = '/qr/scan';

  // ─── Recharge ──────────────────────────────────────────────────────────────
  static const String rechargeIntent   = '/recharge/create-intent';
  static const String rechargeConfirm  = '/recharge/confirm';

  // ─── Blockchain ────────────────────────────────────────────────────────────
  static const String blockchain       = '/blockchain';
  static const String blockchainVerify = '/blockchain/verify';

  // ─── Profil ────────────────────────────────────────────────────────────────
  static const String profile        = '/profile';
  static const String changePassword = '/profile/change-password';
  static const String changePin      = '/profile/change-pin';

  // ─── Notifications ─────────────────────────────────────────────────────────
  static const String notifications   = '/notifications';
  static const String markAllRead     = '/notifications/read-all';

  // ─── Chatbot ───────────────────────────────────────────────────────────────
  static const String chatbot = '/chatbot/chat';
}
