import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import 'result_screen.dart';
import 'checkout_webview_screen.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final api = SupabaseService();
  final amountCtrl = TextEditingController(text: '300');
  bool loading = false;

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _startStripeCheckout() async {
    final amount = double.tryParse(amountCtrl.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    setState(() => loading = true);
    try {
      await NotificationService.instance.add(
        title: 'Paiement en cours',
        message: 'Votre achat de ${amount.toStringAsFixed(2)} BKN a été initié. Finalisez le paiement pour créditer votre wallet.',
        type: 'warning',
        meta: {'kind': 'buy_started', 'amount': amount},
      );

      final session = await api.createCheckoutSession(amountBkn: amount);
      final url = session['url']!;
      final sessionId = session['session_id']!;

      if (!mounted) return;

      final checkoutResult = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => CheckoutWebViewScreen(checkoutUrl: url),
        ),
      );

      if (!mounted) return;

      bool paid = false;
      double? creditedAmount;
      Object? lastError;
      final attempts = (checkoutResult == false) ? 1 : 8;
      for (var i = 0; i < attempts; i++) {
        try {
          creditedAmount = await api.isCheckoutPaid(sessionId: sessionId);
          if (creditedAmount != null) {
            paid = true;
            break;
          }
        } catch (e) {
          lastError = e;
        }
        if (i < attempts - 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (!paid && lastError != null) {
        throw lastError;
      }

      // Use the amount confirmed by the backend; fall back to what user entered.
      // Also fall back if backend returned 0 (shouldn't happen but guard it).
      final confirmedAmount = (creditedAmount != null && creditedAmount > 0) ? creditedAmount : amount;

      if (paid) {
        await NotificationService.instance.add(
          title: 'Achat confirmé',
          message: '${confirmedAmount.toStringAsFixed(2)} BKN ont été ajoutés à votre portefeuille.',
          type: 'success',
          meta: {'kind': 'buy_success', 'amount': confirmedAmount, 'sessionId': sessionId},
        );
      } else {
        await NotificationService.instance.add(
          title: 'Paiement en attente',
          message: 'Le paiement Stripe est encore en cours de confirmation pour ${amount.toStringAsFixed(2)} BKN.',
          type: 'warning',
          meta: {'kind': 'buy_pending', 'amount': amount, 'sessionId': sessionId},
        );
      }

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            ok: paid,
            title: paid ? 'Paiement OK ✅' : 'Paiement en attente ⏳',
            message: paid
                ? 'Paiement confirmé. ${confirmedAmount.toStringAsFixed(2)} BKN crédités sur ton solde.'
                : "Le paiement n'est pas encore confirmé. Termine le paiement puis réessaie dans quelques secondes.",
          ),
        ),
      );

      if (paid && mounted) Navigator.of(context).pop();
    } catch (e) {
      await NotificationService.instance.add(
        title: 'Échec du paiement',
        message: "Impossible de finaliser l'achat BKN. ${e.toString()}",
        type: 'error',
        meta: {'kind': 'buy_error'},
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(ok: false, title: 'Erreur Stripe', message: e.toString()),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acheter des BKN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Achat (BKN)',
                hintText: 'Ex: 300',
              ),
            ),
            const SizedBox(height: 10),
            const Text('Tarif: 1 BKN = 1€', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            const Text(
              "Le paiement Stripe se fait dans l'app, puis votre wallet est crédité automatiquement après confirmation.",
              style: TextStyle(color: Colors.white60, fontSize: 12.5),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: loading ? null : _startStripeCheckout,
                child: loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Payer via Stripe'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
