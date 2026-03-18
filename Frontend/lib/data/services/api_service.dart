import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  // ─── Token ───────────────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String pin,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: _jsonHeaders,
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'pin': pin,
        if (phone != null) 'phone': phone,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _handleResponse(response);
    if (data['token'] != null) await saveToken(data['token']);
    return data;
  }

  Future<void> logout() async {
    final headers = await _authHeaders();
    await http.post(Uri.parse(ApiConstants.logout), headers: headers);
    await clearToken();
  }

  Future<UserModel> getMe() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse(ApiConstants.me), headers: headers);
    final data = _handleResponse(response);
    return UserModel.fromJson(data['user']);
  }

  // ─── Transfert ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> transfer({
    required String receiverEmail,
    required int amountCents,
    required String pin,
    String? note,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.transfer),
      headers: headers,
      body: jsonEncode({
        'receiver_email': receiverEmail,
        'amount': amountCents,
        'pin': pin,
        if (note != null) 'note': note,
      }),
    );
    return _handleResponse(response);
  }

  // ─── Recharge ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createPaymentIntent(int amountCents) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.createIntent),
      headers: headers,
      body: jsonEncode({'amount': amountCents}),
    );
    return _handleResponse(response);
  }

  // ─── Historique ───────────────────────────────────────────────────────────

  Future<List<TransactionModel>> getHistory({String? type}) async {
    final headers = await _authHeaders();
    final uri = Uri.parse(ApiConstants.history).replace(
      queryParameters: {if (type != null) 'type': type},
    );
    final response = await http.get(uri, headers: headers);
    final data = _handleResponse(response);
    final List list = data['data'] ?? [];
    return list.map((e) => TransactionModel.fromJson(e)).toList();
  }

  // ─── Profil ───────────────────────────────────────────────────────────────

  Future<UserModel> updateProfile(Map<String, dynamic> fields) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse(ApiConstants.profile),
      headers: headers,
      body: jsonEncode(fields),
    );
    final data = _handleResponse(response);
    return UserModel.fromJson(data['user']);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse(ApiConstants.changePassword),
      headers: headers,
      body: jsonEncode({
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      }),
    );
    _handleResponse(response);
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse(ApiConstants.changePin),
      headers: headers,
      body: jsonEncode({
        'current_pin': currentPin,
        'new_pin': newPin,
        'new_pin_confirmation': newPin,
      }),
    );
    _handleResponse(response);
  }

  // ─── QR Code ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> generateQr(int amountCents) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.qrGenerate),
      headers: headers,
      body: jsonEncode({'amount': amountCents}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> scanQr({
    required String token,
    required String pin,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.qrScan),
      headers: headers,
      body: jsonEncode({'token': token, 'pin': pin}),
    );
    return _handleResponse(response);
  }

  // ─── Chatbot ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.chatbot),
      headers: headers,
      body: jsonEncode({'message': message}),
    );
    return _handleResponse(response);
  }

  // ─── Handler ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body['message'] ?? 'Erreur inconnue';
    throw ApiException(message, response.statusCode, body['errors']);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, this.statusCode, this.errors);

  @override
  String toString() => message;
}

