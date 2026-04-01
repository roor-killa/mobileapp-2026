import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur de connexion');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return data;
    } else {
      if (data is Map && data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          }
        }
      }
      throw Exception(data['message'] ?? 'Erreur lors de la création du compte');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> logout() async {
    final token = await getToken();

    if (token != null && token.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors du chargement du profil');
    }
  }

  static Future<Map<String, dynamic>> deposit({
    required double amount,
    String? description,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/deposit'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amount,
        'description': description,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors du dépôt');
    }
  }

  static Future<Map<String, dynamic>> withdraw({
    required double amount,
    String? description,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/withdraw'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amount,
        'description': description,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors du retrait');
    }
  }

  static Future<List<dynamic>> getHistory() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Erreur lors du chargement de l’historique',
      );
    }
  }

  static Future<String> sendChatMessage(String message) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'message': message,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['reply'] ?? 'Aucune réponse';
    } else {
      throw Exception(data['message'] ?? 'Erreur lors de l’envoi du message');
    }
  }

  static Future<Map<String, dynamic>> transfer({
    required String email,
    required double amount,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/transfer'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': email,
        'amount': amount,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors du virement');
    }
  }

  static Future<List<dynamic>> getCryptoAssets() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/crypto'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors du chargement du portefeuille crypto');
    }
  }

  static Future<Map<String, dynamic>> buyCrypto({
    required String symbol,
    required double amount,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/crypto/buy'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'symbol': symbol,
        'amount': amount,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors de l’achat crypto');
    }
  }

  static Future<Map<String, dynamic>> sellCrypto({
    required String symbol,
    required double quantity,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/crypto/sell'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'symbol': symbol,
        'quantity': quantity,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors de la vente crypto');
    }
  }
}