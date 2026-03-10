import 'package:flutter/material.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final TextEditingController amountController = TextEditingController();
  String errorMessage = '';

  void validateDeposit() {
    final double? amount = double.tryParse(
      amountController.text.replaceAll(',', '.'),
    );

    if (amount == null || amount <= 0) {
      setState(() {
        errorMessage = 'Veuillez entrer un montant valide.';
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
        title: const Text('Déposer'),
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
                    Icons.add_circle_outline,
                    size: 60,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Entrer le montant à déposer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
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
                      onPressed: validateDeposit,
                      child: const Text('Valider le dépôt'),
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