import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeService {
  static const String backendUrl = 'https://unobviously-multilamellar-keiko.ngrok-free.dev/api';

  static Future<void> rechargerCompte({
    required double montant,
    required int userId,
    required String token,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/stripe/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'montant': montant}),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final url = data['url'];
        if (url != null && await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur Stripe: $e')),
      );
    }
  }
}