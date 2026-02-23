import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/api_service.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _amountController = TextEditingController();
  final _apiService       = ApiService();
  bool _isLoading         = false;

  Future<void> _startTopUp() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Montant minimum : 1 €'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Étape 1 : Obtenir le client_secret depuis le backend Laravel
      final clientSecret = await _apiService.createPaymentIntent(amount);

      // Étape 2 : Initialiser le PaymentSheet Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'WalletApp',
          style: ThemeMode.light,
        ),
      );

      // Étape 3 : Afficher la feuille de paiement Stripe (formulaire carte)
      await Stripe.instance.presentPaymentSheet();

      // Étape 4 : Extraire le payment_intent_id depuis le client_secret
      final paymentIntentId = clientSecret.split('_secret_')[0];

      // Étape 5 : Confirmer auprès du backend pour créditer le wallet
      final result = await _apiService.confirmTopUp(paymentIntentId, amount);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rechargement réussi ! Nouveau solde : ${result['nouveau_solde']} €',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on StripeException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paiement annulé : ${e.error.message}'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharger mon portefeuille'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Montant à ajouter (€)',
                hintText: 'Ex: 20.00',
                prefixIcon: Icon(Icons.euro),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _startTopUp,
                icon: const Icon(Icons.credit_card),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Payer par carte', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Paiement sécurisé par Stripe\nCarte de test : 4242 4242 4242 4242',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
