import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiService {
  // URL dynamique selon la plateforme
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Pour l'émulateur Android
    } else if (Platform.isIOS) {
      return 'http://localhost:8000'; // Pour l'émulateur iOS
    } else {
      return 'http://127.0.0.1:8000'; // Pour les autres plateformes
    }
  }
  
  static String? currentUserId;
  static String? currentUserPseudo;
  static String? currentUserEmail;
  static String? currentUserName;
  static String? currentUserFirstName;

  static void _log(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('📱 API: $message');
    }
  }

  // ================ AUTHENTIFICATION SIMPLE ================

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      _log('Tentative de connexion: $email');
      
      // 🔓 Envoi du mot de passe en clair (simple)
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password, // Mot de passe en clair
        }),
      ).timeout(const Duration(seconds: 15));
      
      _log('Réponse: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final user = data['user'];
          _log('✅ Connexion réussie pour: ${user['pseudo']}');
          
          await saveSession(
            user['id'],
            user['pseudo'],
            user['email'],
            userName: user['nom'],
            userFirstName: user['prenom'],
          );
          return {'success': true, 'user': user};
        }
      }
      
      return {
        'success': false,
        'error': 'Email ou mot de passe incorrect'
      };
    } catch (e) {
      _log('❌ Erreur login: $e');
      return {'success': false, 'error': 'Erreur de connexion au serveur'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String nom,
    required String prenom,
    required String pseudo,
    required String phone,
    required String password,
  }) async {
    try {
      _log('Tentative d\'inscription: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'pseudo': pseudo,
          'phone': phone,
          'password': password, // Mot de passe en clair
        }),
      ).timeout(const Duration(seconds: 15));
      
      final data = json.decode(response.body);
      _log('Register réponse: ${response.statusCode}');
      
      if (response.statusCode == 200 && data['success'] == true) {
        _log('✅ Inscription réussie');
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Erreur d\'inscription'
        };
      }
    } catch (e) {
      _log('Erreur register: $e');
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  // ================ SESSION ================

  static Future<void> saveSession(
    String userId,
    String pseudo,
    String email, {
    String? userName,
    String? userFirstName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = userId;
    currentUserPseudo = pseudo;
    currentUserEmail = email;
    currentUserName = userName;
    currentUserFirstName = userFirstName;
    
    await prefs.setString('userId', userId);
    await prefs.setString('userPseudo', pseudo);
    await prefs.setString('userEmail', email);
    if (userName != null) await prefs.setString('userName', userName);
    if (userFirstName != null) await prefs.setString('userFirstName', userFirstName);
    
    _log('Session sauvegardée: $pseudo');
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId');
    currentUserPseudo = prefs.getString('userPseudo');
    currentUserEmail = prefs.getString('userEmail');
    currentUserName = prefs.getString('userName');
    currentUserFirstName = prefs.getString('userFirstName');
    _log('Session chargée: $currentUserPseudo');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentUserId = null;
    currentUserPseudo = null;
    currentUserEmail = null;
    currentUserName = null;
    currentUserFirstName = null;
    _log('Session effacée');
  }

  // ================ UTILISATEURS ================

  static Future<List<dynamic>> getContacts() async {
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
      _log('Erreur getContacts: $e');
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

  // ================ TRANSACTIONS ================

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
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Erreur de connexion au serveur: $e'},
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
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Erreur de connexion au serveur: $e'},
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
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Erreur de connexion au serveur: $e'},
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

  // Test de connexion
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}