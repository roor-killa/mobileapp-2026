import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http; // <-- On ajoute le vrai outil réseau
import '../models/transfer_response.dart';

class ApiService {
  // L'URL de ton serveur Laravel
  // Mets 'http://10.0.2.2:8000/api' si tu utilises un émulateur Android !
static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // =====================================================================
  // VRAIE API (Connectée à Laravel)
  // =====================================================================
  
  Future<Map<String, dynamic>> register(String name, String prenom, String email, String telephone, String password) async {
    final url = Uri.parse('$baseUrl/register');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'prenom': prenom,
          'email': email,
          'telephone': telephone,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print("Erreur API: $e");
      return {'status': 'error', 'message': 'Erreur de connexion au serveur'};
    }
  }

  // =====================================================================
  // SIMULATION DU PROFESSEUR (On la garde intacte)
  // =====================================================================
  
  static double _soldeBDD = 1500.50; 
  
  Future<TransferResponse> transfererMontant(double montant) async {
    print('📤 ÉTAPE 2 : Envoi de la requête API...');
    await Future.delayed(const Duration(seconds: 2)); // Le faux chargement !
    
    final montantTotal = _soldeBDD;
    final nouveauSolde = montantTotal - montant;
    
    if (nouveauSolde < 0) {
      return TransferResponse(
        success: false,
        montantTotal: montantTotal,
        montantTransfere: 0,
        nouveauSolde: montantTotal,
        message: 'Solde insuffisant',
      );
    }
    
    _soldeBDD = nouveauSolde;
    
    final jsonResponse = {
      'success': true,
      'montant_total': montantTotal,
      'montant_transfere': montant,
      'nouveau_solde': nouveauSolde,
      'message': 'Transfert effectué avec succès',
    };
    
    return TransferResponse.fromJson(jsonResponse);
  }
  
  Future<double> getSoldeActuel() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _soldeBDD;
  }
}