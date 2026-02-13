import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ ATTENTION : Si vous êtes sur émulateur Android, utilisez 10.0.2.2
  // Si vous testez sur Chrome/Web, utilisez localhost
  static const String baseUrl = 'http://10.0.2.2:8001/api';

  // --- Authentification ---

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Erreur connexion');
  }

  static Future<Map<String, dynamic>> register(String username, String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(res.body);
  }

  // --- Données ---

  static Future<Map<String, dynamic>> getMe(String token) async {
    final res = await http.get(Uri.parse('$baseUrl/me'), headers: _authHeader(token));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getUsers(String token) async {
    final res = await http.get(Uri.parse('$baseUrl/users'), headers: _authHeader(token));
    return jsonDecode(res.body);
  }

  // --- Actions ---

  static Future<void> transfer(String token, String receiverUsername, int amount) async {
    final res = await http.post(
      Uri.parse('$baseUrl/transfer'),
      headers: _authHeader(token),
      body: jsonEncode({'receiver_username': receiverUsername, 'amount': amount}),
    );
    if (res.statusCode != 200) throw Exception('Erreur transfert');
  }

  static Future<List<dynamic>> getTransactions(String token) async {
    final res = await http.get(Uri.parse('$baseUrl/transactions'), headers: _authHeader(token));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Impossible de charger l\'historique');
    }
  }

  // --- Helper (En-tête Authorization) ---

  static Map<String, String> _authHeader(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }
}
