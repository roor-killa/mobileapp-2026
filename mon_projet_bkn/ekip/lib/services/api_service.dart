import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transfer_response.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // On demande le solde d'un utilisateur PRÉCIS
  Future<double> getSoldeActuel(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/balance/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['balance'] ?? 0).toDouble();
      }
    } catch (e) {
      print('Erreur: $e');
    }
    return 0.0;
  }

    // Récupérer l'historique complet
  Future<List<dynamic>> getTransactions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/history'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Erreur history: $e');
    }
    return [];
  }


  // On dit QUI (senderId) transfère l'argent
  Future<TransferResponse> transfererMontant(int senderId, double montant) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': montant,
          'sender_id': senderId, // On envoie l'ID au serveur
        }),
      );

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return TransferResponse.fromJson(jsonResponse);
      } else {
        return TransferResponse(
            success: false,
            montantTotal: 0,
            montantTransfere: 0,
            nouveauSolde: 0,
            message: jsonResponse['message'] ?? 'Erreur');
      }
    } catch (e) {
      return TransferResponse(
          success: false, montantTotal: 0, montantTransfere: 0, nouveauSolde: 0, message: 'Erreur réseau');
    }
  }
}
