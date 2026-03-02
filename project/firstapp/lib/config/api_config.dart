class ApiConfig {
  /// Base URL de l'API.
  ///
  /// Par défaut: `10.0.2.2` permet à l'émulateur Android d'accéder au PC hôte.
  /// Tu peux surcharger au build/run avec:
  /// `--dart-define=API_BASE_URL=http://<ip-locale>:8000/api`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
  
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String accountsEndpoint = '/accounts';
  static const String beneficiariesEndpoint = '/beneficiaries';
  static const String transactionEndpoint = '/transactions/transfer';
  static const String historyEndpoint = '/transactions';
}
