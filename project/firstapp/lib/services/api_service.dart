import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/transfer_response.dart';

class ApiService {
  static const String baseUrl = 'https://unobviously-multilamellar-keiko.ngrok-free.dev/api';

  final String? token;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiService({this.token});

  // -------------------------------
  // LOGIN: récupère le token JWT (corrigé)
  // -------------------------------
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    try {
      return jsonDecode(response.body); // Parse JSON côté API
    } catch (_) {
      return {
        "success": false,
        "message": "Erreur login : réponse API non JSON",
      };
    }
  }

  // -------------------------------
  // REGISTER: créer un utilisateur (CORRIGÉ)
  // -------------------------------
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": "Erreur inscription",
      };
    }
  }

  // -------------------------------
  // Récupérer l'ID de l'utilisateur connecté
  // -------------------------------
  Future<int> getCurrentUserId() async {
    try {
      String? jwtToken = token ?? await storage.read(key: 'jwt');
      if (jwtToken == null) return 0;

      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {'Authorization': 'Bearer $jwtToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'] ?? {};
        return (user['id'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      print('Erreur getCurrentUserId: $e');
      return 0;
    }
  }

  // -------------------------------
  // Récupérer le solde actuel
  // -------------------------------
  Future<double> getSolde() async {
    try {
      String? jwtToken = token ?? await storage.read(key: 'jwt');

      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {'Authorization': 'Bearer ${jwtToken ?? ''}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['solde'] ?? 0).toDouble();
      }
      return 0;
    } catch (e) {
      print('Erreur getSolde : $e');
      return 0;
    }
  }

  // -------------------------------
  // Transfert d'argent
  // -------------------------------
  Future<TransferResponse> transfererVersUtilisateur(double montant, int recepteurId) async {
    try {
      String? jwtToken = token ?? await storage.read(key: 'jwt');

      final response = await http.post(
        Uri.parse('$baseUrl/transfert'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${jwtToken ?? ''}',
        },
        body: jsonEncode({
          'receiver_id': recepteurId,
          'amount': montant,
        }),
      
      );
      print('Réponse brute transfert: ${response.body}');

      final data = jsonDecode(response.body);
      double nouveauSolde = (data['sender_balance'] ?? 0).toDouble();

      return TransferResponse(
        success: data['success'] ?? false,
        montantTotal: 0,
        montantTransfere: montant,
        nouveauSolde: nouveauSolde,
        message: data['message'] ?? '',
      );
    } catch (e) {
      return TransferResponse(
        success: false,
        montantTotal: 0,
        montantTransfere: 0,
        nouveauSolde: 0,
        message: 'Erreur de connexion : $e',
      );
    }
  }

  // -------------------------------
  // Alias pour TransferScreen
  // -------------------------------
  Future<double> getSoldeActuel() => getSolde();

  // -------------------------------
  // Stripe: créer une session de paiement pour recharger le wallet
  // -------------------------------
  Future<String?> createStripeSession(double montant) async {
    try {
      String? jwtToken = token ?? await storage.read(key: 'jwt');

      final response = await http.post(
        Uri.parse('$baseUrl/stripe/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${jwtToken ?? ''}',
        },
        body: jsonEncode({'montant': montant}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      }
      return null;
    } catch (e) {
      print('Erreur createStripeSession : $e');
      return null;
    }
  }
}