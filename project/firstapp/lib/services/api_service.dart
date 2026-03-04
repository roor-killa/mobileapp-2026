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
  
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Le token sera stocké ici une fois le login réussi
  String? token; 

  /// RÉEL : Envoi du virement au serveur Laravel
  Future<TransferResponse> transfererMontant({
    required String email, 
    required double montant
  }) async {
    // Vérifie bien que c'est /send-money dans ton routes/api.php
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

  /// RÉEL : Récupérer le solde actuel
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
        // On récupère le champ 'balance' (assure-toi qu'il existe dans ta table users)
        return double.parse(data['balance'].toString());
      }
      return 0.0;
    } catch (e) {
      print('❌ Erreur Solde : $e');
      return 0.0;
    }
  }
}