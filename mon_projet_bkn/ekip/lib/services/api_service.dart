import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transfer_response.dart';

class ApiService {
  // ⚠️ Pour un émulateur Android, on utilise 10.0.2.2
  // Si tu es sur un téléphone physique, remplace par ton IP locale (ex: 192.168.1.XX)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // --- ACTIONS SIMPLES ---

  // 1. Réinitialiser la base de données (Bouton rouge "Reset Database")
  Future<bool> resetDatabase() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/reset'));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Erreur reset: $e');
    }
    return false;
  }

  // 2. Obtenir le solde actuel d'un utilisateur (1 ou 2)
  Future<double> getSoldeActuel(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/balance/$userId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['balance'] ?? 0).toDouble();
      }
    } catch (e) {
      print('Erreur solde: $e');
    }
    return 0.0;
  }

  // 3. Récupérer l'historique complet des transactions (Pour le Dashboard)
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

  // 4. Effectuer un virement (User A -> User B)
  Future<TransferResponse> transfererMontant(int senderId, double montant) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': montant,
          'sender_id': senderId, 
          // Note : Dans cette version simplifiée, si sender=1 alors receiver=2, et inversement.
          // C'est le serveur Python (server.py) qui gère cette logique automatique.
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
          message: jsonResponse['message'] ?? 'Erreur inconnue',
        );
      }
    } catch (e) {
      return TransferResponse(
        success: false,
        montantTotal: 0,
        montantTransfere: 0,
        nouveauSolde: 0,
        message: 'Erreur réseau : $e',
      );
    }
  }
}
