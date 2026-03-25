import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class StripeService {
  static Future<bool> fairePaiement(String montant) async {
    try {
      // 1. Récupérer le token de session (on vérifie partout pour être sûr)
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token') ?? ApiService().token;

      if (token == null) {
        print("❌ Erreur : Aucun token trouvé. Connectez-vous d'abord.");
        return false;
      }

      // 2. Demander le Secret à ton Laravel
      final response = await http.post(
        // Uri.parse('http://192.168.1.12/api/create-payment-intent'),
        Uri.parse('http://172.26.131.224/api/create-payment-intent'), 
        body: {'amount': montant},
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print("❌ Erreur Laravel : ${response.body}");
        return false;
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      // 3. Initialiser le formulaire Stripe (Payment Sheet)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'FirstApp Bank',
          // Optionnel : tu peux changer le style (Light/Dark) ici
          style: ThemeMode.system,
        ),
      );

      // 4. Afficher le formulaire à l'utilisateur
      await Stripe.instance.presentPaymentSheet();

      print("✅ Paiement Stripe validé par l'utilisateur !");
      return true; // On retourne true pour que l'interface puisse afficher un succès
      
    } catch (e) {
      // Si l'utilisateur annule le paiement, Stripe jette une exception
      if (e is StripeException) {
        print("⚠️ Paiement annulé ou échoué : ${e.error.localizedMessage}");
      } else {
        print("❌ Erreur inattendue : $e");
      }
      return false;
    }
  }
}