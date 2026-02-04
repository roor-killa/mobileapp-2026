import 'dart:convert';
import 'dart:async';
import '../models/transfer_response.dart';

class ApiService {
  // URL de base de l'API (à modifier pour la vraie API)
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Simulation d'un solde en base de données
  static double _soldeBDD = 1500.50; // Montant initial dans wallet
  
  /// SIMULATION : Simule l'appel API avec délai
  /// Cette fonction sera remplacée par un vrai appel HTTP
  Future<TransferResponse> transfererMontant(double montant) async {
    print('📤 ÉTAPE 2 : Envoi de la requête API...');
    print('💰 Montant à transférer : $montant €');
    
    // Simuler le délai réseau (1-2 secondes)
    await Future.delayed(const Duration(seconds: 2));
    
    print('⚙️  ÉTAPE 3 : Traitement côté serveur...');
    
    // SIMULATION du traitement serveur
    // En réalité, cela se passe dans Laravel + PostgreSQL
    final montantTotal = _soldeBDD;
    final nouveauSolde = montantTotal - montant;
    
    // Vérification de solde suffisant
    if (nouveauSolde < 0) {
      return TransferResponse(
        success: false,
        montantTotal: montantTotal,
        montantTransfere: 0,
        nouveauSolde: montantTotal,
        message: 'Solde insuffisant',
      );
    }
    
    // Mise à jour du solde simulé
    _soldeBDD = nouveauSolde;
    
    // ÉTAPE 4 : Construction du JSON de réponse (simulé)
    final jsonResponse = {
      'success': true,
      'montant_total': montantTotal,
      'montant_transfere': montant,
      'nouveau_solde': nouveauSolde,
      'message': 'Transfert effectué avec succès',
    };
    
    print('📥 ÉTAPE 4 : Réception du JSON :');
    print(json.encode(jsonResponse));
    
    // ÉTAPE 5 : Conversion JSON -> Objet Dart
    print('🔄 ÉTAPE 5 : Parsing du JSON...');
    return TransferResponse.fromJson(jsonResponse);
  }
  
  /// Récupérer le solde actuel (pour affichage)
  Future<double> getSoldeActuel() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _soldeBDD;
  }
}