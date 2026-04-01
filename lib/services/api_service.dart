import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8001/api/';

  // ================= REGISTER =================
  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}register'),
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return response.statusCode == 200;
  }

  // ================= LOGIN =================
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login'),
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  // ================= TRANSFER =================
  Future<Map<String, dynamic>> transfererMontant(
    double montant,
    String destinataire,
    int userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}transfer'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'montant': montant.toString(),
          'destinataire_email': destinataire,
          'sender_id': userId.toString(),
        },
      );

      print("STATUS TRANSFER: ${response.statusCode}");
      print("BODY TRANSFER: ${response.body}");

      // ⚠️ Si Laravel renvoie une erreur HTML
      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Erreur serveur (${response.statusCode})',
        };
      }

      final data = json.decode(response.body);

      // ⚠️ sécurité si la réponse n'est pas un JSON attendu
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        return {
          'success': false,
          'message': 'Réponse invalide du serveur',
        };
      }
    } catch (e) {
      print("❌ Exception transfererMontant: $e");
      return {
        'success': false,
        'message': 'Exception: $e',
      };
    }
  }

  // ================= BALANCE =================
  Future<double> getBalance(int userId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}user/$userId'),
    );

    print("BODY BALANCE: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Cas 1: { balance: "100.00" }
      if (data['balance'] != null) {
        return double.parse(data['balance'].toString());
      }

      // Cas 2: { user: { balance: ... } }
      if (data['user'] != null && data['user']['balance'] != null) {
        return double.parse(data['user']['balance'].toString());
      }
    }

    return 0;
  }

  // ================= TRANSACTIONS =================
  Future<List<dynamic>> getTransactions(int userId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}transactions/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  // ================= USERS (ADMIN) =================
  Future<List<dynamic>> getUsers(bool isAdmin) async {
    final response = await http.get(
      Uri.parse('${baseUrl}users?is_admin=$isAdmin'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  // ================= ADD MONEY =================
  Future<bool> addMoney(int userId, double amount) async {
    final response = await http.post(
      Uri.parse('${baseUrl}admin/add-money'),
      body: {
        'user_id': userId.toString(),
        'amount': amount.toString(),
        'is_admin': 'true',
      },
    );

    return response.statusCode == 200;
  }
}