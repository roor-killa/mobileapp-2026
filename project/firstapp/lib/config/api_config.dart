class ApiConfig {
  // Changez cette URL selon votre configuration
  // Use 10.0.2.2 so Android emulator can reach host machine
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String accountsEndpoint = '/accounts';
  static const String transactionEndpoint = '/transactions/transfer';
  static const String historyEndpoint = '/transactions';
}
