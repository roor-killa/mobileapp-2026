import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/auth_provider.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final _amountCtrl = TextEditingController();
  bool _loading = false;

  final List<int> _quickAmounts = [1000, 2000, 5000, 10000, 20000, 50000];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _recharge() async {
    final text = _amountCtrl.text.trim().replaceAll(',', '.');
    final euros = double.tryParse(text);
    if (euros == null || euros < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Montant invalide (min 1,00 €)'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final cents = (euros * 100).round();
      final api = ApiService();

      // 1. Créer le PaymentIntent côté serveur
      final intentData = await api.createPaymentIntent(cents);
      final clientSecret = intentData['client_secret'] as String;

      // 2. Initialiser la Payment Sheet Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'MoneyTransferApp',
          style: ThemeMode.light,
          // Désactive la collecte du code postal
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
            address: AddressCollectionMode.never,
          ),
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: AppColors.primary,
            ),
          ),
        ),
      );

      // 3. Afficher la Payment Sheet native Stripe
      await Stripe.instance.presentPaymentSheet();

      // 4. Attendre que le webhook Stripe crédite le compte (~2s)
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      await authProvider.refreshUser();

      if (mounted) {
        _amountCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Recharge de ${euros.toStringAsFixed(2)} € effectuée ! '
                'Votre solde sera mis à jour dans quelques instants.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on StripeException catch (e) {
      // Annulation par l'utilisateur ou erreur Stripe
      if (e.error.code != FailureCode.Canceled && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur Stripe : ${e.error.localizedMessage}'),
              backgroundColor: AppColors.error),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Recharger mon compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Solde actuel ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Solde actuel',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    user?.balanceFormatted ?? '—',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ─── Carte de test Stripe ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mode test — Carte : 4242 4242 4242 4242\n'
                      'Date : n\'importe quelle date future · CVC : n\'importe lequel',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Montants rapides ─────────────────────────────────────────
            Text('Montants rapides',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _quickAmounts.map((cents) {
                final label = '${(cents / 100).toStringAsFixed(0)} €';
                return GestureDetector(
                  onTap: () =>
                      _amountCtrl.text = (cents / 100).toStringAsFixed(2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(label,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ─── Montant personnalisé ─────────────────────────────────────
            Text('Ou saisir un montant',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Montant (€)',
                prefixIcon: Icon(Icons.euro_outlined),
                hintText: '50.00',
              ),
            ),
            const SizedBox(height: 28),

            // ─── Bouton Recharge ──────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _loading ? null : _recharge,
              icon: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.credit_card),
              label: const Text('Payer avec Stripe'),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.lock_outline,
                    size: 16, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text('Paiement sécurisé par Stripe',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
