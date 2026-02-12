import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:8001/api';
  static String? _authToken;
  
  static String? get authToken => _authToken;
  static bool get isAuthenticated => _authToken != null;
  
  /// Login avec username et password
  Future<Map<String, dynamic>> login(String username, String password) async {
    print('🔐 Tentative de connexion pour $username...');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        _authToken = data['token'];
        print('✅ Authentification réussie! Token: $_authToken');
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        print('❌ Erreur d\'authentification');
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur d\'authentification',
        };
      }
    } catch (e) {
      print('❌ Erreur de connexion : $e');
      return {
        'success': false,
        'message': 'Erreur de connexion : $e',
      };
    }
  }
  
  /// Logout
  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );
      _authToken = null;
      print('✅ Déconnecte');
    } catch (e) {
      print('❌ Erreur lors de la déconnexion : $e');
    }
  }
  
  /// Vérifier si le token est valide
  Future<bool> verifyToken() async {
    if (_authToken == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
