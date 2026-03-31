import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../services/api_service.dart'; // Vérifie bien le chemin vers ton ApiService

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ApiService _apiService = ApiService();
  bool _hasScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return; // Évite de scanner 10 fois par seconde

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() => _hasScanned = true);
      
      try {
        final data = jsonDecode(barcodes.first.rawValue!);
        _showPaymentDialog(data['id'], data['name']);
      } catch (e) {
        _showError("QR Code invalide");
        Future.delayed(const Duration(seconds: 2), () => setState(() => _hasScanned = false));
      }
    }
  }

  void _showPaymentDialog(int receiverId, String receiverName) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Payer à $receiverName"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Montant en €", suffixText: "€"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              final double? amt = double.tryParse(amountController.text);
              if (amt != null && amt > 0) {
                Navigator.pop(context);
                _processPayment(receiverId, amt);
              }
            },
            child: const Text("Confirmer"),
          ),
        ],
      ),
    ).then((_) => setState(() => _hasScanned = false));
  }

  Future<void> _processPayment(int id, double amount) async {
    // Afficher un chargement
    showDialog(context: context, builder: (c) => const Center(child: CircularProgressIndicator()));

    try {
      // Appelle ta route Laravel /api/qr-payment
      // Tu devras ajouter cette méthode 'payViaQr' dans ton ApiService
      final success = await _apiService.payViaQr(id, amount);

      Navigator.pop(context); // Fermer le chargement

      if (success) {
        _showSuccess("Paiement de $amount € envoyé !");
        Navigator.pop(context); // Retour au menu principal
      } else {
        _showError("Échec du paiement (Solde insuffisant ?)");
      }
    } catch (e) {
      Navigator.pop(context);
      _showError("Erreur réseau : $e");
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner un QR Code")),
      body: MobileScanner(
        onDetect: _onDetect,
      ),
    );
  }
}