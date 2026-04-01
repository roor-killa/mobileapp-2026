import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transfer_response.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // ⚠️ IMPORTANT : Mets ici la vraie adresse IPv4 de ton PC (ipconfig)
  // C'est indispensable pour que ton iPhone ou un vrai téléphone Android trouve ton PC.
  static const String ipWifiPC = '172.20.10.2'; 

  static String get baseUrl {
    if (kIsWeb) {
      // Si tu lances sur le navigateur Web de ton PC
      return 'http://127.0.0.1/api'; 
    } 
    
    if (Platform.isAndroid) {
      // Si tu es sur l'émulateur Android (le faux téléphone dans ton PC)
      return 'http://10.0.2.2/api'; 
    } else if (Platform.isIOS) {
      // Si tu es sur ton vrai iPhone branché en Wi-Fi
      return 'http://$ipWifiPC/api'; 
    } else {
      // Si tu lances comme un vrai logiciel Windows (Windows Desktop)
      return 'http://127.0.0.1/api'; 
    }
  }
  Future<Map<String, dynamic>> register(String name, String prenom, String email, String telephone, String password) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'prenom': prenom, 'email': email, 'telephone': telephone, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Erreur serveur'};
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
      return {'status': 'error', 'message': 'Erreur serveur'};
    }
  }

  Future<Map<String, dynamic>> topUp(double montant) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return {'success': false, 'message': 'Erreur: Non connecté'};

    final url = Uri.parse('$baseUrl/topup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'montant': montant}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau'};
    }
  }

  Future<TransferResponse> transfererMontant(String emailDestinataire, double montant) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return TransferResponse(success: false, montantTotal: 0, montantTransfere: 0, nouveauSolde: 0, message: 'Non connecté');
    }

    final url = Uri.parse('$baseUrl/transfer');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'email_destinataire': emailDestinataire, 'montant': montant}),
      );
      return TransferResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return TransferResponse(success: false, montantTotal: 0, montantTransfere: 0, nouveauSolde: 0, message: 'Erreur réseau');
    }
  }
  // =====================================================================
  // SYNCHRONISATION EN DIRECT (Façon Revolut)
  // =====================================================================
  Future<double?> getLiveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    final url = Uri.parse('$baseUrl/user'); // Laravel nous donne les infos de l'utilisateur connecté
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return double.tryParse(data['solde'].toString()); // On extrait le vrai solde
      }
    } catch (e) {
      print("Erreur Live Balance: $e");
    }
    return null; // En cas de problème de réseau, on renvoie null
  }
  // =====================================================================
  // HISTORIQUE DES TRANSACTIONS
  // =====================================================================
  Future<List<dynamic>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return [];

    final url = Uri.parse('$baseUrl/transactions');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['transactions']; // On renvoie la liste des reçus
        }
      }
    } catch (e) {
      print("Erreur API Transactions: $e");
    }
    return []; // Si erreur, on renvoie une liste vide
  }
  // =====================================================================
  // MARCHÉ CRYPTO BKN
  // =====================================================================
  
  Future<Map<String, dynamic>> getMarketData({int limit = 100}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return {'success': false};

    final url = Uri.parse('$baseUrl/bkn/market?limit=$limit');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau'};
    }
  }

  Future<Map<String, dynamic>> buyBkn(double quantite) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/bkn/buy');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'quantite': quantite}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau'};
    }
  }

  Future<Map<String, dynamic>> sellBkn(double quantite) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/bkn/sell');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'quantite': quantite}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau'};
    }
  }
  // =====================================================================
  // GESTION DES POCKETS (SOUS-COMPTES)
  // =====================================================================
  
  // 1. Récupérer la liste des pockets
  Future<Map<String, dynamic>> getPockets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return {'success': false, 'message': 'Non connecté'};

    final url = Uri.parse('$baseUrl/pockets');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau'};
    }
  }

  // 2. Créer un nouveau pocket
  Future<Map<String, dynamic>> createPocket(String nom) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return {'success': false, 'message': 'Non connecté'};

    final url = Uri.parse('$baseUrl/pockets');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'nom': nom}), // On envoie juste le nom, Laravel gère la couleur/icône par défaut
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau'};
    }
  }

  // 3. Transférer de l'argent (Principal <-> Pocket)
  Future<Map<String, dynamic>> transferPocket(int pocketId, double montant, String direction) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return {'success': false, 'message': 'Non connecté'};

    final url = Uri.parse('$baseUrl/pockets/transfer');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'pocket_id': pocketId,
          'montant': montant,
          'direction': direction // Doit être 'to_pocket' ou 'to_main'
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau'};
    }
  }
  // --- CHAT IA ---
  Future<Map<String, dynamic>> askAgentIA(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // On vérifie que l'utilisateur est bien connecté
    if (token == null) return {'success': false, 'message': 'Non connecté'};

    final url = Uri.parse('$baseUrl/chat');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // On ajoute le token de sécurité ici
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Erreur serveur (${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur.'};
    }
  }
}