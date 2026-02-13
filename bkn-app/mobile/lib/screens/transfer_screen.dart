import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TransferScreen extends StatefulWidget {
  final Map<String, dynamic> receiver;
  const TransferScreen({super.key, required this.receiver});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMoney() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);
    final response = await ApiService.transfer(widget.receiver['id'], amount);
    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transfert réussi !"), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        final msg = jsonDecode(response.body)['message'] ?? "Erreur";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Envoyer à ${widget.receiver['name']}")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Combien voulez-vous envoyer ?", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(suffixText: "BKN", border: UnderlineInputBorder()),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: _isLoading ? const CircularProgressIndicator() : const Text("Confirmer l'envoi"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                onPressed: _isLoading ? null : _sendMoney,
              ),
            )
          ],
        ),
      ),
    );
  }
}
