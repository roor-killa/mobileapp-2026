import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/transfer_response.dart';
import '../models/transaction.dart';

class ApiService {
  // Instance unique (Singleton) pour partager les données entre les écrans
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Données de session stockées après le login
  String? token; 
  dynamic currentUserId; // Stocke l'ID (souvent int ou String selon Laravel)

  /// Récupérer l'ID de l'utilisateur stocké
  Future<dynamic> getCurrentUserId() async {
    return currentUserId;
  }

  /// RÉEL : Envoi du virement au serveur Laravel
  Future<TransferResponse> transfererMontant({
    required String email, 
    required double montant
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
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 400) {
        return TransferResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur API : $e');
      rethrow;
    }
  }
  
  /// RÉEL : Récupérer l'historique des transactions
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
        print('Erreur historique: ${response.statusCode} ${response.body}');
        throw Exception('Impossible de charger l\'historique');
      }
    } catch (e) {
      print('❌ Erreur Historique : $e');
      return []; 
    }
  }

  /// RÉEL : Récupérer le solde actuel et les infos utilisateur
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
        
        // On profite de cet appel pour mettre à jour l'ID utilisateur si besoin
        if (currentUserId == null) {
          currentUserId = data['id'];
        }

        return double.parse(data['balance'].toString());
      }
      return 0.0;
    } catch (e) {
      print('❌ Erreur Solde : $e');
      return 0.0;
    }
  }
}