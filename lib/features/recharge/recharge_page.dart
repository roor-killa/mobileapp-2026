import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/custom_button.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final _amountCtrl = TextEditingController();
  final _api        = ApiService.instance;
  int?   _selectedPreset;
  bool   _isLoading = false;

  static const _presets = [10.0, 20.0, 50.0, 100.0, 200.0, 500.0];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _selectPreset(int index) {
    setState(() {
      _selectedPreset = index;
      _amountCtrl.text = _presets[index].toStringAsFixed(0);
    });
  }

  // ─── Flux de paiement Stripe ─────────────────────────────────────────────
  Future<void> _recharge() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Entrez un montant valide (minimum 1€)'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Créer un PaymentIntent côté backend
      final intentRes = await _api.post(ApiConstants.rechargeIntent, {'amount': amount});
      final clientSecret    = intentRes['client_secret'] as String;
      final paymentIntentId = intentRes['payment_intent'] as String;
      final publishableKey  = intentRes['publishable_key'] as String?;

      // Mettre à jour la clé publique si le backend la renvoie
      if (publishableKey != null && publishableKey.isNotEmpty && !publishableKey.contains('REMPLACEZ')) {
        Stripe.publishableKey = publishableKey;
      }

      // 2. Initialiser le Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'TransfertApp',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: AppColors.primary,
            ),
          ),
        ),
      );

      // 3. Afficher le Payment Sheet Stripe
      await Stripe.instance.presentPaymentSheet();

      // 4. Confirmer auprès du backend et créditer le solde
      if (!mounted) return;
      final confirmRes = await _api.post(
        ApiConstants.rechargeConfirm,
        {'payment_intent_id': paymentIntentId},
      );

      if (!mounted) return;
      final newBalance = (confirmRes['new_balance'] as num).toDouble();
      context.read<AuthProvider>().updateBalance(newBalance);
      // Rafraîchir le dashboard et l'historique
      context.read<DashboardProvider>().loadDashboard();
      context.read<TransactionProvider>().loadTransactions(refresh: true);

      setState(() => _isLoading = false);
      _showSuccess(amount, newBalance);

    } on StripeException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // L'utilisateur a annulé — pas une erreur à afficher
      if (e.error.code == FailureCode.Canceled) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.error.localizedMessage ?? 'Paiement annulé.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));

    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Vérifier si l'erreur vient de clés Stripe non configurées
      final msg = e.toString().contains('REMPLACEZ') || e.toString().contains('pk_test_')
          ? 'Clés Stripe non configurées. Voir les instructions.'
          : 'Erreur : ${e.toString()}';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _showSuccess(double amount, double newBalance) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 20),
            const Text('Recharge réussie !',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text(
              '${amount.toStringAsFixed(2)}€ ajoutés à votre compte.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Nouveau solde : ${newBalance.toStringAsFixed(2)}€',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Parfait !',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<AuthProvider>().user?.balance ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recharger mon compte',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Solde actuel ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.successGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white70, size: 18),
                      SizedBox(width: 6),
                      Text('Solde actuel',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${balance.toStringAsFixed(2)} €',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Montants prédéfinis ────────────────────────────────────────
            const Text('Choisir un montant',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: _presets.length,
              itemBuilder: (_, i) {
                final selected = _selectedPreset == i;
                return GestureDetector(
                  onTap: () => _selectPreset(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 8)
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        '${_presets[i].toStringAsFixed(0)} €',
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),

            // ── Montant libre ──────────────────────────────────────────────
            const Text('Ou entrer un montant personnalisé',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}'))
              ],
              onChanged: (_) => setState(() => _selectedPreset = null),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Ex: 75',
                prefixIcon:
                    const Icon(Icons.euro_rounded, color: AppColors.primary),
                suffixText: '€',
                suffixStyle: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 16),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 24),

            // ── Méthode de paiement ────────────────────────────────────────
            const Text('Moyen de paiement',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.credit_card_rounded,
                      color: AppColors.primary, size: 28),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Carte bancaire (Stripe)',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text('Visa, Mastercard, Amex',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 22),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Info sécurité
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security_rounded,
                      color: AppColors.secondary, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Paiement sécurisé par Stripe. Vos données bancaires ne sont jamais stockées.',
                      style:
                          TextStyle(color: AppColors.secondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Bouton ─────────────────────────────────────────────────────
            CustomButton(
              label: 'Recharger maintenant',
              isLoading: _isLoading,
              icon: Icons.add_card_rounded,
              onPressed: _recharge,
            ),

            // Carte de test en mode développement
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.amber, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mode test : utilisez la carte 4242 4242 4242 4242, n\'importe quelle date future et n\'importe quel CVV.',
                      style: TextStyle(
                          color: Colors.amber, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
