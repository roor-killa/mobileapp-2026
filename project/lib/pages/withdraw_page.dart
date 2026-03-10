import 'package:flutter/material.dart';

class WithdrawPage extends StatefulWidget {
  final double currentBalance;

  const WithdrawPage({
    super.key,
    required this.currentBalance,
  });

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController amountController = TextEditingController();
  String errorMessage = '';

  void validateWithdraw() {
    final double? amount = double.tryParse(
      amountController.text.replaceAll(',', '.'),
    );

    if (amount == null || amount <= 0) {
      setState(() {
        errorMessage = 'Veuillez entrer un montant valide.';
      });
      return;
    }

    if (amount > widget.currentBalance) {
      setState(() {
        errorMessage = 'Solde insuffisant.';
      });
      return;
    }

    Navigator.pop(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Retirer'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.remove_circle_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Entrer le montant à retirer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Solde disponible : ${widget.currentBalance.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Montant',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.euro),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: validateWithdraw,
                      child: const Text('Valider le retrait'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}