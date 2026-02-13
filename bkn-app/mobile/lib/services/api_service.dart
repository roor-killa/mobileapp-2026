import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL de base pour l'émulateur Android (pointe vers localhost:8001 du PC)
  static const String baseUrl = "http://10.0.2.2:8001/api";
  
  // Variable statique pour stocker le Token en mémoire après le login
  static String? token;

  // Getter pour les en-têtes HTTP
  // Ajoute automatiquement le Token "Bearer" s'il est disponible
  static Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

  // --- AUTHENTIFICATION ---

  // Connexion
  static Future<http.Response> login(String email, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/login'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  // Inscription
  static Future<http.Response> register(String name, String username, String email, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/register'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      }),
    );
  }

  // --- DONNÉES PROTÉGÉES (Nécessitent le Token) ---

  // Récupérer mon profil et mon solde
  static Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(Uri.parse('$baseUrl/me'), headers: headers);
    return jsonDecode(response.body);
  }

  // Récupérer la liste des autres utilisateurs (pour envoyer de l'argent)
  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'), headers: headers);
    return jsonDecode(response.body);
  }

  // Effectuer un virement
  static Future<http.Response> transfer(int receiverId, int amount) async {
    return await http.post(
      Uri.parse('$baseUrl/transfer'),
      headers: headers,
      body: jsonEncode({'receiver_id': receiverId, 'amount': amount}),
    );
  }

  // Récupérer l'historique des transactions
  static Future<List<dynamic>> getTransactions() async {
    final response = await http.get(Uri.parse('$baseUrl/transactions'), headers: headers);
    return jsonDecode(response.body);
  }

  // Recharger le compte
  static Future<http.Response> deposit(int amount) async {
    return await http.post(
      Uri.parse('$baseUrl/deposit'),
      headers: headers,
      body: jsonEncode({'amount': amount}),
    );
  }

}
