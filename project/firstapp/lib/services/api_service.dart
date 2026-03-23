import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/transfer_response.dart';
import '../models/transaction.dart';

class ApiService {
  // Instance unique (Singleton)
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  // static const String baseUrl = 'http://172.26.131.224/api';
  static const String baseUrl = 'http://192.168.1.12/api';
  
  // Données de session conservées en mémoire
  String? token; 
  String? userName;
  dynamic currentUserId; 

  /// INSCRIPTION : Crée un compte et connecte l'utilisateur
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String pin,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'pin': pin,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Stockage automatique des infos pour session immédiate
        token = data['access_token'];
        currentUserId = data['user']['id'];
        userName = data['user']['name'];
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Erreur d'inscription (422)");
      }
    } catch (e) {
      print('❌ Erreur API Register : $e');
      rethrow;
    }
  }

  /// CONNEXION : Authentifie l'utilisateur et récupère le Token
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['access_token'];
        currentUserId = data['user']['id'];
        userName = data['user']['name'];
        return true;
      } else {
        throw Exception('Identifiants incorrects');
      }
    } catch (e) {
      print('❌ Erreur API Login : $e');
      rethrow;
    }
  }

  /// TRANSFERT : Envoi du virement sécurisé par PIN
  Future<TransferResponse> transfererMontant({
    required String email, 
    required double montant,
    String? pin, 
  }) async {
    final url = Uri.parse('$baseUrl/send-money');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode({
          'receiver_email': email,
          'amount': montant,
          'pin': pin,
        }),
      );

      // Gestion des codes retours métier
      if (response.statusCode == 200 || response.statusCode == 400 || response.statusCode == 403 || response.statusCode == 422) {
        return TransferResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur API Transfert : $e');
      rethrow;
    }
  }
  
  /// HISTORIQUE : Récupérer la liste des transactions
  Future<List<Transaction>> getTransactions() async {
    final url = Uri.parse('$baseUrl/transactions');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Transaction.fromJson(item)).toList();
      } else {
        throw Exception('Impossible de charger l\'historique');
      }
    } catch (e) {
      print('❌ Erreur Historique : $e');
      return []; 
    }
  }

  /// SOLDE : Récupérer le solde en temps réel
  Future<double> getSoldeActuel() async {
    final url = Uri.parse('$baseUrl/user'); 
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Synchronisation des données de profil au passage
        currentUserId ??= data['id'];
        userName ??= data['name'];

        return double.parse(data['balance'].toString());
      }
      return 0.0;
    } catch (e) {
      print('❌ Erreur Solde : $e');
      return 0.0;
    }
  }
}