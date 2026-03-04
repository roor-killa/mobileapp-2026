import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/models.dart';

class BankService {
  BankService._();
  static final BankService _instance = BankService._();
  factory BankService() => _instance;

  String? _token;
  Future<void>? _initFuture;

  Future<void> init() async {
    _initFuture ??= _initInternal();
    return _initFuture!;
  }

  Future<void> _initInternal() async {
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

  Future<void> _handleUnauthorized() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
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

  static const String _serverHint = "Démarrez le backend : dans infrastructure/back-laravel, exécutez « php artisan serve --host=127.0.0.1 --port=8000 ».";

  Exception _networkException(Object e) {
    if (e is TimeoutException) {
      return Exception("Délai dépassé. $_serverHint");
    }
    final msg = e.toString().toLowerCase();
    if (msg.contains('failed to fetch') || msg.contains('connection refused') || msg.contains('socketexception') || msg.contains('clientexception')) {
      return Exception("Impossible de contacter le serveur. $_serverHint");
    }
    return Exception('Erreur réseau. Vérifie ta connexion et que l’API est accessible.');
  }

  // Authentification
  Future<Map<String, dynamic>> login(String email, String password) async {
    await init();
    try {
      final response = await http
          .post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: _jsonHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 20));

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
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
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
    await init();
    try {
      final response = await http
          .post(
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
      )
          .timeout(const Duration(seconds: 20));

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
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  Future<void> logout() async {
    try {
      await init();
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutEndpoint}'),
            headers: _jsonHeaders(withAuth: true),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return;
      }
    } finally {
      await _handleUnauthorized();
    }
  }

  /// Changer le mot de passe (utilisateur connecté).
  /// Lance une Exception si le mot de passe actuel est incorrect ou si la requête échoue.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await init();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.changePasswordEndpoint}'),
            headers: _jsonHeaders(withAuth: true),
            body: jsonEncode({
              'current_password': currentPassword,
              'password': newPassword,
              'password_confirmation': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return;
      }
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      }
      throw Exception(_extractErrorMessage(response));
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  // Comptes
  Future<List<Account>> getAccounts() async {
    await init();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.accountsEndpoint}'),
            headers: _jsonHeaders(withAuth: true),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Account> accounts = (data['accounts'] as List)
            .map((account) => Account.fromJson(account))
            .toList();
        return accounts;
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  /// Créer un nouveau compte (ex. Compte d'épargne).
  Future<Account> createAccount(String accountType) async {
    await init();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.accountsEndpoint}'),
            headers: _jsonHeaders(withAuth: true),
            body: jsonEncode({'account_type': accountType}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Account.fromJson(data['account'] as Map<String, dynamic>);
      }
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      }
      throw Exception(_extractErrorMessage(response));
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  /// Supprimer un compte (uniquement si solde = 0). Sinon lance une Exception.
  Future<void> deleteAccount(int accountId) async {
    await init();
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.accountsEndpoint}/$accountId'),
            headers: _jsonHeaders(withAuth: true),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      }
      throw Exception(_extractErrorMessage(response));
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  Future<List<BeneficiaryAccount>> getBeneficiaries() async {
    await init();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.beneficiariesEndpoint}'),
            headers: _jsonHeaders(withAuth: true),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<BeneficiaryAccount> accounts =
            (data['beneficiaries'] as List<dynamic>)
                .map((b) => BeneficiaryAccount.fromJson(b as Map<String, dynamic>))
                .toList();
        return accounts;
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      }

      throw Exception(_extractErrorMessage(response));
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  // Transactions
  Future<List<Transaction>> getTransactions() async {
    await init();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.historyEndpoint}'),
            headers: _jsonHeaders(withAuth: true),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Transaction> transactions = (data['transactions'] as List)
            .map((transaction) => Transaction.fromJson(transaction))
            .toList();
        return transactions;
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  Future<List<Transaction>> getAccountTransactions(int accountId) async {
    await init();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.accountsEndpoint}/$accountId/transactions'),
            headers: _jsonHeaders(withAuth: true),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tx = data['transactions'];
        final List<dynamic> items = (tx is Map<String, dynamic>) ? (tx['data'] as List<dynamic>) : (tx as List<dynamic>);
        return items.map((t) => Transaction.fromJson(t as Map<String, dynamic>)).toList();
      }
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      }

      throw Exception(_extractErrorMessage(response));
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  // Virement
  Future<Map<String, dynamic>> transfer(
    int fromAccountId,
    int toAccountId,
    double amount,
    String description,
  ) async {
    await init();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transactionEndpoint}'),
            headers: _jsonHeaders(withAuth: true),
            body: jsonEncode({
              'from_account_id': fromAccountId,
              'to_account_id': toAccountId,
              'amount': amount,
              'description': description,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  /// Envoyer une demande d'argent à un utilisateur (il recevra une notification).
  Future<Map<String, dynamic>> createPaymentRequest({
    required int toUserId,
    required double amount,
    String? message,
  }) async {
    await init();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentRequestsEndpoint}'),
            headers: _jsonHeaders(withAuth: true),
            body: jsonEncode({
              'to_user_id': toUserId,
              'amount': amount,
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      }
      throw Exception(_extractErrorMessage(response));
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  /// Liste des demandes d'argent reçues (pour les afficher dans les notifications).
  Future<List<Map<String, dynamic>>> getPaymentRequests() async {
    await init();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentRequestsEndpoint}'),
            headers: _jsonHeaders(withAuth: true),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['payment_requests'] as List<dynamic>? ?? [];
        return list.cast<Map<String, dynamic>>();
      }
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      }
      return [];
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      return [];
    }
  }

  /// Accepter une demande d'argent (effectue le virement depuis le compte choisi).
  Future<void> acceptPaymentRequest(int paymentRequestId, int fromAccountId) async {
    await init();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentRequestsEndpoint}/$paymentRequestId/accept'),
            headers: _jsonHeaders(withAuth: true),
            body: jsonEncode({'from_account_id': fromAccountId}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) return;
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      }
      throw Exception(_extractErrorMessage(response));
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  /// Refuser une demande d'argent.
  Future<void> declinePaymentRequest(int paymentRequestId) async {
    await init();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentRequestsEndpoint}/$paymentRequestId/decline'),
            headers: _jsonHeaders(withAuth: true),
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) return;
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expirée. Merci de vous reconnecter.');
      }
      throw Exception(_extractErrorMessage(response));
    } on TimeoutException catch (e) {
      throw _networkException(e);
    } on http.ClientException catch (e) {
      throw _networkException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw _networkException(e);
    }
  }

  String? getToken() => _token;
  
  bool isLoggedIn() => _token != null;
}
