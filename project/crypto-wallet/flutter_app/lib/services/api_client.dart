import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

const _tokenKey = 'jwt_token';

class ApiClient {
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  ApiClient._();

  String get _base => ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> setToken(String token) async => await _setToken(token);
  Future<void> clearToken() async => await _clearToken();

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String path) async {
    final uri = Uri.parse('$_base$path');
    final response = await http.get(uri, headers: await _headers()).timeout(
      const Duration(seconds: 15),
    );
    if (response.statusCode == 401) await _clearToken();
    return response;
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_base$path');
    final response = await http
        .post(uri, headers: await _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 401) await _clearToken();
    return response;
  }
}
