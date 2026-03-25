/// Configuration Stripe pour les paiements.
/// Récupérez la clé publique (pk_test_...) dans Stripe Dashboard → Developers → API keys.
class StripeConfig {
  /// Clé publique Stripe (pk_test_... en dev, pk_live_... en prod).
  /// Sans cette clé, les paiements Stripe sont désactivés.
  static const String publishableKey = '';

  /// URL de l'API paiements. Par défaut : NestJS (port 3000).
  /// Les paiements Stripe sont gérés par le backend NestJS.
  static const String paymentsBaseUrl = 'http://localhost:3000';
}
