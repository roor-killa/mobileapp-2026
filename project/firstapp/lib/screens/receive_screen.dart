import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final _amountController = TextEditingController();
  final _authService      = AuthService();
  final _apiService       = ApiService();

  String? _qrData;
  String? _userEmail;
  double? _montant;
  bool    _loadingEmail = true;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    // 1. Essayer le storage local
    String? email = await _authService.getEmail();

    // 2. Fallback : récupérer depuis l'API et sauvegarder
    if (email == null) {
      email = await _apiService.getCurrentUserEmail();
      await _authService.saveEmail(email);
    }

    setState(() {
      _userEmail    = email;
      _loadingEmail = false;
    });
  }

  void _genererQr() {
    final montant = double.tryParse(_amountController.text.trim());
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un montant valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_userEmail == null) return;

    setState(() {
      _montant = montant;
      _qrData  = jsonEncode({'email': _userEmail, 'amount': montant});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recevoir un paiement'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Champ montant
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Montant à recevoir (€)',
                hintText: 'Ex: 25.00',
                prefixIcon: const Icon(Icons.euro),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),

            // Bouton générer
            ElevatedButton.icon(
              onPressed: (_loadingEmail || _userEmail == null) ? null : _genererQr,
              icon: const Icon(Icons.qr_code),
              label: _loadingEmail
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Générer le QR Code', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            // QR Code
            if (_qrData != null) ...[
              const SizedBox(height: 32),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '${_montant!.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail!,
                        style: const TextStyle(fontSize: 13, color: Colors.black45),
                      ),
                      const SizedBox(height: 20),
                      QrImageView(
                        data: _qrData!,
                        version: QrVersions.auto,
                        size: 220,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Faites scanner ce QR code\npour recevoir le paiement',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
