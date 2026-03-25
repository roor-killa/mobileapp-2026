import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'auth_service_appwrite.dart';

const _tokenKey = 'jwt_token';

class ApiClient {
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  ApiClient._();
  final AuthServiceAppwrite _auth = AuthServiceAppwrite();

  String get _base => ApiConfig.baseUrl;

  /// Utilise le JWT Appwrite (créé à la demande via createJWT), sinon SharedPreferences.
  Future<String?> _getToken() async {
    final jwt = await _auth.getAccessToken();
    if (jwt != null && jwt.isNotEmpty) return jwt;
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

  Uri _uri(String path) =>
      path.startsWith('http') ? Uri.parse(path) : Uri.parse('$_base$path');

  Future<http.Response> get(String path) async {
    final uri = _uri(path);
    final response = await http.get(uri, headers: await _headers()).timeout(
      const Duration(seconds: 15),
    );
    // Ne pas effacer le token au 401 : le backend peut refuser un JWT expiré
    // alors qu’Appwrite a encore une session — on réessaie avec syncApiToken().
    return response;
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = _uri(path);
    final response = await http
        .post(uri, headers: await _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return response;
  }
}
