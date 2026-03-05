import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transfer_response.dart';

class ApiService {
  // ⚠️ IMPORTANT: Modifier cette URL selon votre configuration
  // - Émulateur Android: 'http://10.0.2.2:8000/api/v1'
  // - iOS Simulator: 'http://localhost:8000/api/v1'
  // - Appareil physique: 'http://VOTRE_IP:8000/api/v1'
  // - Production: 'https://votre-domaine.com/api/v1'
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  
  // ID de l'utilisateur (en dur pour le moment, à remplacer par authentification)
  static const int userId = 1; // User créé par le seeder
  
  /// Récupérer le solde actuel depuis l'API
  Future<double> getSoldeActuel() async {
    try {
      print('📡 Récupération du solde pour user $userId...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/solde/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: Le serveur ne répond pas');
        },
      );
      
      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['solde'] ?? 0).toDouble();
        } else {
          throw Exception(data['message'] ?? 'Erreur inconnue');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Erreur getSoldeActuel: $e');
      rethrow;
    }
  }
  
  /// Effectuer un transfert via l'API
  Future<TransferResponse> transfererMontant(double montant) async {
    try {
      print('📤 ÉTAPE 2 : Envoi de la requête API...');
      print('💰 Montant à transférer : $montant €');
      
      final response = await http.post(
        Uri.parse('$baseUrl/transfer'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'montant': montant,
          'description': 'Transfert depuis Flutter App',
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timeout: Le serveur met trop de temps à répondre');
        },
      );
      
      print('⚙️  ÉTAPE 3 : Réception de la réponse...');
      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 422) {
        // ÉTAPE 4 : Décodage du JSON
        print('🔄 ÉTAPE 4 : Parsing du JSON...');
        final jsonResponse = json.decode(response.body);
        
        // ÉTAPE 5 : Conversion en objet Dart
        print('✅ ÉTAPE 5 : Création de l\'objet TransferResponse');
        return TransferResponse.fromJson(jsonResponse);
        
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Erreur transfererMontant: $e');
      rethrow;
    }
  }
  
  /// Récupérer l'historique des transactions
  Future<List<Map<String, dynamic>>> getTransactions({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$userId?limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['transactions']);
        }
      }
      
      throw Exception('Erreur lors de la récupération des transactions');
      
    } catch (e) {
      print('❌ Erreur getTransactions: $e');
      rethrow;
    }
  }
  
  /// Tester la connexion à l'API
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl.replaceAll('/v1', '')}/ping'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
      
    } catch (e) {
      print('❌ Erreur connexion API: $e');
      return false;
    }
  }
}
