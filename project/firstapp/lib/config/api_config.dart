import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base URL de l'API. Choisie automatiquement selon la plateforme :
  /// - Web (Chrome) : http://127.0.0.1:8000/api
  /// - Android (émulateur) : http://10.0.2.2:8000/api
  /// Surcharge possible au lancement : --dart-define=API_BASE_URL=http://...
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    return 'http://10.0.2.2:8000/api';
  }

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String changePasswordEndpoint = '/auth/change-password';
  static const String accountsEndpoint = '/accounts';
  static const String beneficiariesEndpoint = '/beneficiaries';
  static const String transactionEndpoint = '/transactions/transfer';
  static const String historyEndpoint = '/transactions';
  static const String paymentRequestsEndpoint = '/payment-requests';
}
