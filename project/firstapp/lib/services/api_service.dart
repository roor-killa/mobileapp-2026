import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../config.dart';

class ApiService {
  static String get _baseUrl => apiBaseUrl;

  final _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /api/user
  Future<String> getCurrentUserEmail() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['email'] as String;
    }
    throw Exception('Impossible de récupérer l\'utilisateur');
  }

  // GET /api/wallet
  Future<Wallet> getWallet() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/wallet'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return Wallet.fromJson(jsonDecode(response.body));
    }
    throw Exception('Impossible de charger le portefeuille');
  }

  // GET /api/wallet/exchange-rate
  Future<double> getExchangeRate() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/wallet/exchange-rate'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)['EUR_TO_BKN'] as num).toDouble();
    }
    return 10.0; // fallback
  }

  // POST /api/wallet/transfer
  Future<Map<String, dynamic>> transfer(
    String recipientEmail,
    double amount, {
    String currency = 'EUR',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/wallet/transfer'),
      headers: await _headers(),
      body: jsonEncode({
        'recipient_email': recipientEmail,
        'amount': amount,
        'currency': currency,
      }),
    );
    return jsonDecode(response.body);
  }

  // POST /api/wallet/convert
  Future<Map<String, dynamic>> convert({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/wallet/convert'),
      headers: await _headers(),
      body: jsonEncode({
        'from_currency': fromCurrency,
        'to_currency': toCurrency,
        'amount': amount,
      }),
    );
    return jsonDecode(response.body);
  }

  // POST /api/wallet/topup/create-intent
  Future<String> createPaymentIntent(double amount) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/wallet/topup/create-intent'),
      headers: await _headers(),
      body: jsonEncode({'amount': amount}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['client_secret'] as String;
    }
    throw Exception('Erreur création PaymentIntent');
  }

  // POST /api/wallet/topup/confirm
  Future<Map<String, dynamic>> confirmTopUp(String paymentIntentId, double amount) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/wallet/topup/confirm'),
      headers: await _headers(),
      body: jsonEncode({'payment_intent_id': paymentIntentId, 'amount': amount}),
    );
    return jsonDecode(response.body);
  }

  // POST /api/user/fcm-token
  Future<void> saveFcmToken(String token) async {
    await http.post(
      Uri.parse('$_baseUrl/user/fcm-token'),
      headers: await _headers(),
      body: jsonEncode({'fcm_token': token}),
    );
  }

  // GET /api/wallet/transactions
  Future<List<Transaction>> getTransactions() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/wallet/transactions'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['transactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList();
    }
    throw Exception('Impossible de charger les transactions');
  }
}
