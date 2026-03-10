import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // <-- Oubli réparé pour le coffre-fort !
import '../models/transfer_response.dart';
import '../models/transaction.dart'; // <-- Import manquant pour la classe Transaction

class ApiService {
  // L'URL de ton serveur Laravel
  static const String baseUrl = 'http://10.0.2.2:8000/api';  

  // =====================================================================
  // AUTHENTIFICATION ET UTILISATEUR
  // =====================================================================
  
  Future<Map<String, dynamic>> register(String name, String prenom, String email, String telephone, String password) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name, 'prenom': prenom, 'email': email, 'telephone': telephone, 'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Erreur de connexion au serveur'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Erreur de connexion au serveur'};
    }
  }

  Future<Map<String, dynamic>> getUser(String token) async {
    final url = Uri.parse('$baseUrl/user');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Erreur serveur: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Erreur de connexion'};
    }
  }
// Dans la classe ApiService de lib/services/api_service.dart

Future<List<Transaction>> getHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception('Token non trouvé. Veuillez vous reconnecter.');
  }

  final response = await http.get(
    Uri.parse('$baseUrl/history'), // Assurez-vous que $baseUrl est correct
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);
    List<Transaction> transactions = body
        .map((dynamic item) => Transaction.fromJson(item))
        .toList();
    return transactions;
  } else {
    throw Exception('Échec du chargement de l\'historique.');
  }
}

  // =====================================================================
  // LE VRAI TRANSFERT (Connecté à PostgreSQL)
  // =====================================================================
  
  // Attention à bien ajouter "String emailDestinataire" dans les parenthèses !
  Future<TransferResponse> transfererMontant(String emailDestinataire, double montant) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return TransferResponse(success: false, montantTotal: 0, montantTransfere: 0, nouveauSolde: 0, message: 'Erreur: Non connecté');
    }

    final url = Uri.parse('$baseUrl/transfer');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email_destinataire': emailDestinataire, // <-- L'EMAIL EST ENVOYÉ ICI
          'montant': montant,
        }),
      );

      final jsonResponse = jsonDecode(response.body);
      return TransferResponse.fromJson(jsonResponse);
      
    } catch (e) {
      print("Erreur API Transfert: $e");
      return TransferResponse(success: false, montantTotal: 0, montantTransfere: 0, nouveauSolde: 0, message: 'Erreur réseau');
    }
  }
  // =====================================================================
  // RECHARGEMENT DU COMPTE
  // =====================================================================
  
  Future<Map<String, dynamic>> topUp(double montant) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'success': false, 'message': 'Erreur: Non connecté'};
    }

    final url = Uri.parse('$baseUrl/topup');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'montant': montant,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print("Erreur API Rechargement: $e");
      return {'success': false, 'message': 'Erreur réseau'};
    }
  }
}