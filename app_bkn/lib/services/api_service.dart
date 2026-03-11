import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_helper.dart';

class ApiService {
  static String? currentUserId;
  static String? currentUserPseudo;
  static String? currentUserEmail;
  static String? currentUserName;
  static String? currentUserFirstName;

  static void _log(String message) => ApiHelper.log(message);

  // ==================== AUTHENTIFICATION ====================
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
        _log('Inscription réussie');
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['detail'] ?? 'Erreur d\'inscription'};
      }
    } catch (e) {
      _log('Erreur register: $e');
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

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

  // ==================== UTILISATEURS ET CONTACTS ====================
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

  // ==================== TRANSACTIONS ====================
  static Future<Map<String, dynamic>> transferer({
    required String expediteurId,
    required String destinataire,
    required double montant,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'expediteur_id': expediteurId, 
          'destinataire': destinataire, 
          'montant': montant
        }),
      );
      final data = json.decode(response.body);
      return {'success': response.statusCode == 200, 'statusCode': response.statusCode, 'data': data};
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': {'error': 'Erreur de connexion au serveur: $e'}};
    }
  }

  static Future<Map<String, dynamic>> acheter({
    required String userId, 
    required double montant, 
    required String methode
  }) async {
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

  static Future<Map<String, dynamic>> vendre({
    required String userId, 
    required double montant
  }) async {
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

  // ==================== STATS ET ANALYTICS ====================
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

  // ==================== PROFIL ET PARAMÈTRES ====================
  static Future<bool> updateProfile({
    required String userId,
    required String nom,
    required String prenom,
    required String email,
    required String phone,
    required String pseudo,
  }) async {
    try {
      _log('Mise à jour du profil pour $userId');
      final response = await http.put(
        Uri.parse('${ApiHelper.baseUrl}/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'phone': phone,
          'pseudo': pseudo,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await saveSession(
            userId,
            pseudo,
            email,
            userName: nom,
            userFirstName: prenom,
          );
          _log('Profil mis à jour avec succès');
          return true;
        }
      }
      return false;
    } catch (e) {
      _log('Erreur updateProfile: $e');
      return false;
    }
  }

  static Future<bool> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _log('Changement de mot de passe pour $userId');
      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/user/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      _log('Erreur changePassword: $e');
      return false;
    }
  }

  // ==================== PARAMÈTRES UTILISATEUR ====================
  static Future<Map<String, dynamic>> getUserSettings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiHelper.baseUrl}/user/$userId/settings'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      _log('Erreur getUserSettings: $e');
      return {};
    }
  }

  static Future<bool> updateUserSettings({
    required String userId,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    bool? twoFactorEnabled,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiHelper.baseUrl}/user/$userId/settings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          if (biometricEnabled != null) 'biometric_enabled': biometricEnabled,
          if (notificationsEnabled != null) 'notifications_enabled': notificationsEnabled,
          if (twoFactorEnabled != null) 'two_factor_enabled': twoFactorEnabled,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      _log('Erreur updateUserSettings: $e');
      return false;
    }
  }

  // ==================== SESSIONS ====================
  static Future<List<dynamic>> getUserSessions(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiHelper.baseUrl}/user/$userId/sessions'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['sessions'] ?? [];
      }
      return [];
    } catch (e) {
      _log('Erreur getUserSessions: $e');
      return [];
    }
  }

  static Future<bool> terminateSession(String sessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiHelper.baseUrl}/user/session/$sessionId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      _log('Erreur terminateSession: $e');
      return false;
    }
  }

  static Future<bool> terminateAllSessions(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiHelper.baseUrl}/user/$userId/sessions'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      _log('Erreur terminateAllSessions: $e');
      return false;
    }
  }

  // ==================== CRYPTO ====================
  static Future<Map<String, dynamic>> getCryptoPrices() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiHelper.baseUrl}/crypto/prices'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'prices': {}};
    } catch (e) {
      _log('Erreur getCryptoPrices: $e');
      return {'prices': {}};
    }
  }

  static Future<Map<String, dynamic>> estimateCrypto({
    required String crypto,
    String fiat = 'eur',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/crypto/estimate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'crypto': crypto,
          'fiat': fiat,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      _log('Erreur estimateCrypto: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> buyCrypto({
    required String userId,
    required String crypto,
    required double amountBKN,
    String? walletAddress,
  }) async {
    try {
      _log('Achat crypto: $amountBKN BKN de $crypto');
      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/crypto/buy'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'crypto': crypto,
          'amount_bkn': amountBKN,
          'wallet_address': walletAddress,
        }),
      ).timeout(const Duration(seconds: 15));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      _log('Erreur buyCrypto: $e');
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  static Future<Map<String, dynamic>> sellCrypto({
    required String userId,
    required String crypto,
    required double amountCrypto,
    String? walletAddress,
  }) async {
    try {
      _log('Vente crypto: $amountCrypto $crypto');
      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/crypto/sell'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'crypto': crypto,
          'amount_crypto': amountCrypto,
          'wallet_address': walletAddress,
        }),
      ).timeout(const Duration(seconds: 15));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      _log('Erreur sellCrypto: $e');
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCryptoBalance(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiHelper.baseUrl}/crypto/balance/$userId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'balances': {}};
    } catch (e) {
      _log('Erreur getCryptoBalance: $e');
      return {'balances': {}};
    }
  }

  static Future<Map<String, dynamic>> getCryptoHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiHelper.baseUrl}/crypto/history/$userId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'transactions': []};
    } catch (e) {
      _log('Erreur getCryptoHistory: $e');
      return {'transactions': []};
    }
  }

  static Future<Map<String, dynamic>> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      _log('Upload avatar pour $userId');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiHelper.baseUrl}/user/$userId/avatar'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      ); 
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var data = json.decode(responseData);
      
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      _log('Erreur upload avatar: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('${ApiHelper.baseUrl}/health')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== MOT DE PASSE OUBLIÉ ====================

  /// Demande de réinitialisation de mot de passe
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      _log('Demande de réinitialisation pour: $email');
      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      _log('Réponse forgot-password: ${response.statusCode}');
      
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      _log('Erreur forgotPassword: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion au serveur'
      };
    }
  }

  /// Réinitialiser le mot de passe avec un token
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      _log('Tentative de réinitialisation avec token');
      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      _log('Réponse reset-password: ${response.statusCode}');
      
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      _log('Erreur resetPassword: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion au serveur'
      };
    }
  }

  /// Valider un token de réinitialisation
  static Future<bool> validateResetToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiHelper.baseUrl}/validate-reset-token/$token'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['valid'] == true;
      }
      return false;
    } catch (e) {
      _log('Erreur validateResetToken: $e');
      return false;
    }
  }
}