import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  // Web (Chrome)      : localhost
  // Android emulator  : 10.0.2.2 → localhost de la machine hôte
  // iOS simulator     : localhost
  static String get _baseUrl =>
      kIsWeb ? 'http://localhost:8001/api' : 'http://10.0.2.2:8001/api';
  static const String _tokenKey = 'auth_token';

  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // POST /api/register
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await saveToken(data['token']);
      return {'success': true, 'user': User.fromJson(data['user'])};
    }
    final message = data['message'] ?? data['errors']?.toString() ?? 'Erreur inscription';
    return {'success': false, 'message': message};
  }

  // POST /api/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await saveToken(data['token']);
      return {'success': true, 'user': User.fromJson(data['user'])};
    }
    final message = data['message'] ?? 'Identifiants incorrects';
    return {'success': false, 'message': message};
  }

  // POST /api/logout
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    }
    await deleteToken();
  }
}
