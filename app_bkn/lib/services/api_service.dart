import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_helper.dart';

class ApiService {
  static String? currentUserId;
  static String? currentUserPseudo;
  static String? currentUserEmail;
  static String? currentUserName;
  static String? currentUserFirstName;

  static void _log(String message) => ApiHelper.log(message);

  // ================= AUTHENTIFICATION =================

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      _log('Tentative de connexion: $email');
      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      _log('Réponse login: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final user = data['user'];
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
      return {'success': false, 'error': 'Email ou mot de passe incorrect'};
    } catch (e) {
      _log('Erreur login: $e');
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
        Uri.parse('${ApiHelper.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'pseudo': pseudo,
          'phone': phone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      _log('Register réponse: ${response.statusCode}');
      if (response.statusCode == 200 && data['success'] == true) {
        _log('✅ Inscription réussie');
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['detail'] ?? 'Erreur d\'inscription'};
      }
    } catch (e) {
      _log('Erreur register: $e');
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  // ================= SESSION =================

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

  // ================= UTILISATEURS =================

  static Future<List<dynamic>> getContacts() async {
    try {
      final response = await http.get(Uri.parse('${ApiHelper.baseUrl}/users'));
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
      final response = await http.get(Uri.parse('${ApiHelper.baseUrl}/user/$identifier'));
      if (response.statusCode == 200) return json.decode(response.body);
      return null;
    } catch (e) {
      _log('Erreur getUser: $e');
      return null;
    }
  }

  static Future<double> getSolde(String userId) async {
    try {
      final response = await http.get(Uri.parse('${ApiHelper.baseUrl}/balance/$userId'));
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

  // ================= TRANSACTIONS =================

  static Future<Map<String, dynamic>> transferer({
    required String expediteurId,
    required String destinataire,
    required double montant,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'expediteur_id': expediteurId, 'destinataire': destinataire, 'montant': montant}),
      );
      final data = json.decode(response.body);
      return {'success': response.statusCode == 200, 'statusCode': response.statusCode, 'data': data};
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': {'error': 'Erreur de connexion au serveur: $e'}};
    }
  }

  static Future<Map<String, dynamic>> acheter({required String userId, required double montant, required String methode}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/buy'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId, 'montant': montant, 'methode': methode}),
      );
      final data = json.decode(response.body);
      return {'success': response.statusCode == 200, 'statusCode': response.statusCode, 'data': data};
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': {'error': 'Erreur de connexion au serveur: $e'}};
    }
  }

  static Future<Map<String, dynamic>> vendre({required String userId, required double montant}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/sell'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId, 'montant': montant}),
      );
      final data = json.decode(response.body);
      return {'success': response.statusCode == 200, 'statusCode': response.statusCode, 'data': data};
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': {'error': 'Erreur de connexion au serveur: $e'}};
    }
  }

  static Future<List<dynamic>> getHistorique(String userId, {int limit = 20}) async {
    try {
      final response = await http.get(Uri.parse('${ApiHelper.baseUrl}/history/$userId?limit=$limit'));
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
      final response = await http.get(Uri.parse('${ApiHelper.baseUrl}/stats'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {};
    } catch (e) {
      _log('Erreur getStats: $e');
      return {};
    }
  }

  // ================= TEST DE CONNEXION =================

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('${ApiHelper.baseUrl}/health')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}