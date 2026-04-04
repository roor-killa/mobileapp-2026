import 'package:flutter/material.dart';
import '../services/stripe_service.dart';

class RechargerScreen extends StatefulWidget {
  final int userId;
  final String token;

  const RechargerScreen({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  State<RechargerScreen> createState() => _RechargerScreenState();
}

class _RechargerScreenState extends State<RechargerScreen> {
  final TextEditingController montantController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recharger")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: montantController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Montant (€)"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _rechargerCompte,
                    child: const Text("Recharger"),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _rechargerCompte() async {
    double montant = double.tryParse(montantController.text) ?? 0;
    if (montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Montant invalide ❌")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await StripeService.rechargerCompte(
        montant: montant,
        userId: widget.userId,
        token: widget.token,
        context: context,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paiement réussi ✅")),
      );

      montantController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur paiement ❌: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    montantController.dispose();
    super.dispose();
  }
}