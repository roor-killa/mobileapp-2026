import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  static const String backendUrl = 'https://unobviously-multilamellar-keiko.ngrok-free.dev/api';

  static Future<void> rechargerCompte({
    required double montant,
    required int userId,
    required BuildContext context,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'amount': montant,
          'user_id': userId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur backend: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Transfert App',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recharge réussie')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur Stripe: $e')),
      );
    }
  }
}