import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../config/stripe_config.dart';
import '../services/api_client.dart';

/// Service pour les paiements Stripe.
/// Configurez StripeConfig.publishableKey et STRIPE_SECRET_KEY dans le backend.
class StripeService {
  static bool get isConfigured =>
      StripeConfig.publishableKey.isNotEmpty;

  /// Initialise Stripe (à appeler au démarrage de l'app).
  static Future<void> init() async {
    if (!isConfigured) return;
    try {
      Stripe.publishableKey = StripeConfig.publishableKey;
      Stripe.merchantIdentifier = 'NodEX';
      await Stripe.instance.applySettings();
    } catch (_) {}
  }

  /// Crée un PaymentIntent via le backend et affiche le formulaire de paiement.
  /// Retourne null si succès, sinon le message d'erreur.
  static Future<String?> payWithCard({
    required double amountEur,
    required String walletId,
    required String symbol,
  }) async {
    if (!isConfigured) return 'Stripe non configuré (clé publique manquante)';
    try {
      final api = ApiClient();
      final res = await api.post(
        '${StripeConfig.paymentsBaseUrl}/payments/create-intent',
        {
          'amountEur': amountEur,
          'walletId': walletId,
          'symbol': symbol,
        },
      );
      if (res.statusCode != 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>?;
        return data?['error']?.toString() ?? 'Erreur ${res.statusCode}';
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final clientSecret = data['clientSecret'] as String?;
      final paymentIntentId = data['paymentIntentId'] as String?;
      if (clientSecret == null || paymentIntentId == null) {
        return 'Réponse serveur invalide';
      }
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'NodEX',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      final confirmRes = await api.post(
        '${StripeConfig.paymentsBaseUrl}/payments/confirm',
        {'paymentIntentId': paymentIntentId},
      );
      if (confirmRes.statusCode != 200) {
        final err = jsonDecode(confirmRes.body) as Map<String, dynamic>?;
        return err?['error']?.toString() ?? 'Erreur de confirmation';
      }
      return null;
    } catch (e) {
      if (e is StripeException) {
        if (e.error.code == FailureCode.Canceled) return 'Paiement annulé';
        return e.error.localizedMessage ?? e.error.message ?? 'Erreur Stripe';
      }
      return e.toString();
    }
  }
}
