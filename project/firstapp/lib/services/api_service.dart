import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transfer_response.dart';
import '../models/user.dart';
import '../models/transfer.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8001/api';
  static const int currentUserId = 1; // ID de l'utilisateur courant (à adapter selon l'auth)

  /// Récupère la liste des utilisateurs (destinataires possibles)
  Future<List<User>> getAvailableUsers() async {
    print('📤 Récupération de la liste des utilisateurs...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transfers/users?current_user_id=$currentUserId'),
      );

      if (response.statusCode != 200) {
        print('❌ Erreur API : status ${response.statusCode}');
        return [];
      }

      print('📥 Réponse reçue : ${response.body}');
      final data = json.decode(response.body);

      if (data['success'] && data['data'] != null) {
        final List<User> users = (data['data'] as List<dynamic>)
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();
        return users;
      }
      return [];
    } catch (e) {
      print('❌ Erreur lors de la récupération des utilisateurs : $e');
      return [];
    }
  }

  /// Récupère le solde actuel de l'utilisateur
  Future<double> getSoldeActuel() async {
    print('📤 Récupération du solde...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transfers/balance?user_id=$currentUserId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['balance'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      print('❌ Erreur getSoldeActuel : $e');
    }
    return 0;
  }

  /// Effectue un transfert d'argent
  Future<TransferResponse> transfererMontant(
    double montant, 
    int toUserId,
    String? description,
  ) async {
    print('📤 ÉTAPE 2 : Envoi de la requête API...');
    print('💰 Montant à transférer : $montant € vers l\'utilisateur $toUserId');

    try {
      print('⚙️  ÉTAPE 3 : Appel POST $baseUrl/transfers/send...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/transfers/send'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'from_user_id': currentUserId,
          'to_user_id': toUserId,
          'amount': montant,
          'description': description,
        }),
      );

      print('📥 ÉTAPE 4 : Réception du JSON :');
      print(response.body);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        print('🔄 ÉTAPE 5 : Transfert réussi');

        // Récupérer les nouvelles valeurs
        final fromUserBalance = (data['from_user']['new_balance'] ?? 0).toDouble();
        final toUserName = data['to_user']['name'] ?? 'Utilisateur';

        return TransferResponse(
          success: true,
          montantTotal: fromUserBalance + montant, // Solde avant transfert
          montantTransfere: montant,
          nouveauSolde: fromUserBalance,
          message: 'Transfert de $montant € vers $toUserName réussi',
        );
      } else {
        final errorMessage = data['message'] ?? 'Erreur lors du transfert';
        print('❌ Erreur : $errorMessage');
        return TransferResponse(
          success: false,
          montantTotal: 0,
          montantTransfere: 0,
          nouveauSolde: 0,
          message: errorMessage,
        );
      }
    } catch (e) {
      print('❌ Erreur lors de l\'appel API : $e');
      return TransferResponse(
        success: false,
        montantTotal: 0,
        montantTransfere: 0,
        nouveauSolde: 0,
        message: 'Erreur de connexion : $e',
      );
    }
  }

  /// Récupère l'historique des transferts
  Future<List<Transfer>> getTransferHistory() async {
    print('📤 Récupération de l\'historique des transferts...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transfers/history?user_id=$currentUserId'),
      );

      if (response.statusCode != 200) {
        return [];
      }

      final data = json.decode(response.body);

      if (data['success'] && data['data'] != null) {
        final List<Transfer> transfers = (data['data'] as List<dynamic>)
            .map((json) => Transfer.fromJson(json as Map<String, dynamic>))
            .toList();
        return transfers;
      }
      return [];
    } catch (e) {
      print('❌ Erreur historique : $e');
      return [];
    }
  }
}
