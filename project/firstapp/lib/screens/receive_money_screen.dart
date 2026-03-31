import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class ReceiveMoneyScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const ReceiveMoneyScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Données encodées dans le QR : ton ID et ton Nom
    final String qrData = jsonEncode({
      "id": user['id'],
      "name": user['name'],
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Recevoir un paiement")),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Présentez ce code pour recevoir de l'argent",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 250.0,
                  gapless: false,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              user['name'] ?? "Utilisateur",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const Text("Identifiant unique sécurisé"),
          ],
        ),
      ),
    );
  }
}