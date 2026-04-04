import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transfer_response.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8001/api/products';

  /// Appel réel à l'API Laravel pour récupérer le prix du premier produit
  /// et l'utiliser comme nouveau solde du wallet
  Future<TransferResponse> transfererMontant(double montant) async {
    print('📤 ÉTAPE 2 : Envoi de la requête API...');
    print('💰 Montant à transférer : $montant €');

    try {
      print('⚙️  ÉTAPE 3 : Appel GET $baseUrl...');
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode != 200) {
        return TransferResponse(
          success: false,
          montantTotal: 0,
          montantTransfere: 0,
          nouveauSolde: 0,
          message: 'Erreur API : status ${response.statusCode}',
        );
      }

      print('📥 ÉTAPE 4 : Réception du JSON :');
      print(response.body);

      final data = json.decode(response.body);

      // Récupérer la liste de produits (gère les deux formats possibles)
      final List<dynamic> products = data is List ? data : (data['data'] ?? data['products'] ?? []);

      if (products.isEmpty) {
        return TransferResponse(
          success: false,
          montantTotal: 0,
          montantTransfere: 0,
          nouveauSolde: 0,
          message: 'Aucun produit trouvé',
        );
      }

      // Récupérer le product_price du premier produit
      final premierProduit = products[0];
      final double productPrice = double.parse(premierProduit['product_price'].toString());

      print('🔄 ÉTAPE 5 : product_price du premier produit = $productPrice');

      return TransferResponse(
        success: true,
        montantTotal: productPrice,
        montantTransfere: montant,
        nouveauSolde: productPrice,
        message: 'Solde mis à jour depuis l\'API (prix du 1er produit)',
      );
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

  /// Récupérer le solde actuel depuis l'API (prix du premier produit)
  Future<double> getSoldeActuel() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> products = data is List ? data : (data['data'] ?? data['products'] ?? []);
        if (products.isNotEmpty) {
          return double.parse(products[0]['product_price'].toString());
        }
      }
    } catch (e) {
      print('❌ Erreur getSoldeActuel : $e');
    }
    return 0;
  }
}
