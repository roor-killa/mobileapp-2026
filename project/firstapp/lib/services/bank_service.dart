import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/models.dart';

class BankService {
  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Map<String, String> _jsonHeaders({bool withAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        if (data['message'] is String) return data['message'] as String;
        final errors = data['errors'];
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            return first.first.toString();
          }
        }
      }
    } catch (_) {
      // ignore
    }
    return 'Erreur réseau (code ${response.statusCode})';
  }

  // Authentification
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: _jsonHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', jsonEncode(data['user']));

        return data;
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
    String firstName,
    String lastName,
    String email,
    String phone,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: _jsonHeaders(),
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', jsonEncode(data['user']));

        return data;
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
        headers: _jsonHeaders(withAuth: true),
      );
    } finally {
      _token = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
    }
  }

  // Comptes
  Future<List<Account>> getAccounts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.accountsEndpoint}'),
        headers: _jsonHeaders(withAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Account> accounts = (data['accounts'] as List)
            .map((account) => Account.fromJson(account))
            .toList();
        return accounts;
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BeneficiaryAccount>> getBeneficiaries() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.beneficiariesEndpoint}'),
        headers: _jsonHeaders(withAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<BeneficiaryAccount> accounts =
            (data['beneficiaries'] as List<dynamic>)
                .map((b) => BeneficiaryAccount.fromJson(b as Map<String, dynamic>))
                .toList();
        return accounts;
      }

      throw Exception(_extractErrorMessage(response));
    } catch (e) {
      rethrow;
    }
  }

  // Transactions
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.historyEndpoint}'),
        headers: _jsonHeaders(withAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Transaction> transactions = (data['transactions'] as List)
            .map((transaction) => Transaction.fromJson(transaction))
            .toList();
        return transactions;
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Transaction>> getAccountTransactions(int accountId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.accountsEndpoint}/$accountId/transactions'),
        headers: _jsonHeaders(withAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tx = data['transactions'];
        final List<dynamic> items = (tx is Map<String, dynamic>) ? (tx['data'] as List<dynamic>) : (tx as List<dynamic>);
        return items.map((t) => Transaction.fromJson(t as Map<String, dynamic>)).toList();
      }

      throw Exception(_extractErrorMessage(response));
    } catch (e) {
      rethrow;
    }
  }

  // Virement
  Future<Map<String, dynamic>> transfer(
    int fromAccountId,
    int toAccountId,
    double amount,
    String description,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transactionEndpoint}'),
        headers: _jsonHeaders(withAuth: true),
        body: jsonEncode({
          'from_account_id': fromAccountId,
          'to_account_id': toAccountId,
          'amount': amount,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      rethrow;
    }
  }

  String? getToken() => _token;
  
  bool isLoggedIn() => _token != null;
}
