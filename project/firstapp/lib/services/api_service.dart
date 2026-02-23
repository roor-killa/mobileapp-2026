import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8001/api';

  final _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
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

  // POST /api/wallet/transfer
  Future<Map<String, dynamic>> transfer(String recipientEmail, double amount) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/wallet/transfer'),
      headers: await _headers(),
      body: jsonEncode({'recipient_email': recipientEmail, 'amount': amount}),
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
