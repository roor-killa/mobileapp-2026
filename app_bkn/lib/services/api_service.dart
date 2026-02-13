import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  static String? currentUserId;
  static String? currentUserPseudo;
  static String? currentUserEmail;

  // ✅ DÉSACTIVÉ EN PRODUCTION
  static const bool _debugMode = false;

  static void _log(String message) {
    // ignore: avoid_print
    if (_debugMode) print('📱 API: $message');
  }

  static Future<void> saveSession(String userId, String pseudo, String email) async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = userId;
    currentUserPseudo = pseudo;
    currentUserEmail = email;
    await prefs.setString('userId', userId);
    await prefs.setString('userPseudo', pseudo);
    await prefs.setString('userEmail', email);
    _log('Session sauvegardée: $pseudo');
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId');
    currentUserPseudo = prefs.getString('userPseudo');
    currentUserEmail = prefs.getString('userEmail');
    _log('Session chargée: $currentUserPseudo');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentUserId = null;
    currentUserPseudo = null;
    currentUserEmail = null;
    _log('Session effacée');
  }

  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['users'] ?? [];
      }
      return [];
    } catch (e) {
      _log('Erreur getUsers: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getUser(String identifier) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$identifier'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      _log('Erreur getUser: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> createUser({
    required String email,
    required String nom,
    required String prenom,
    required String pseudo,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'pseudo': pseudo,
          'phone': phone,
        }),
      );
      
      final data = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      _log('Erreur createUser: $e');
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Erreur de connexion'},
      };
    }
  }

  static Future<double> getSolde(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/balance/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['solde'] ?? 0).toDouble();
      }
      return 0.0;
    } catch (e) {
      _log('Erreur getSolde: $e');
      return 0.0;
    }
  }

  static Future<Map<String, dynamic>> transferer({
    required String expediteurId,
    required String destinataire,
    required double montant,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'expediteur_id': expediteurId,
          'destinataire': destinataire,
          'montant': montant,
        }),
      );
      
      final data = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      _log('Erreur transferer: $e');
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Erreur de connexion au serveur'},
      };
    }
  }

  static Future<Map<String, dynamic>> acheter({
    required String userId,
    required double montant,
    required String methode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/buy'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'montant': montant,
          'methode': methode,
        }),
      );
      
      final data = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      _log('Erreur acheter: $e');
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Erreur de connexion'},
      };
    }
  }

  static Future<Map<String, dynamic>> vendre({
    required String userId,
    required double montant,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sell'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'montant': montant,
        }),
      );
      
      final data = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      _log('Erreur vendre: $e');
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Erreur de connexion'},
      };
    }
  }

  static Future<List<dynamic>> getHistorique(String userId, {int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/$userId?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['transactions'] ?? [];
      }
      return [];
    } catch (e) {
      _log('Erreur getHistorique: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      _log('Erreur getStats: $e');
      return {};
    }
  }
}