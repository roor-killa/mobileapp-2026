import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web/Desktop
  // For Windows desktop, we can use localhost
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        return data;
      } else {
        throw Exception(data['error'] ?? 'Échec de la connexion');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Account Infos
  static Future<Map<String, dynamic>> getAccountInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/accounts/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Échec de la récupération des données du compte');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Transactions
  static Future<List<dynamic>> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['transactions'] ?? [];
      } else {
        throw Exception('Échec de la récupération des transactions');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Make Transfer
  static Future<Map<String, dynamic>> makeTransfer({
    required String recipientName,
    required double amount,
    required String description,
  }) async {
    try {
      // Logic: For this demo, we assume the user has one primary account.
      // We first need the account ID.
      final account = await getAccountInfo();
      final accountId = account['id'];

      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: _headers,
        body: jsonEncode({
          'accountId': accountId,
          'transactionType': 'transfer',
          'amount': -amount, // Amount is negative for transfer out
          'description': description,
          'recipientName': recipientName,
          'category': 'Virement',
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Échec du virement');
      }
    } catch (e) {
      rethrow;
    }
  }
}
