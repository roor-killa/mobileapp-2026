// lib/screens/qr_scanner_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner QR')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) async {
  this.controller = controller;

  controller.scannedDataStream.listen((scanData) async {
    final code = scanData.code;

    if (code != null) {
      print("QR SCANNÉ: $code");

      

      try {
  // 1️⃣ Décoder le JSON
  final data = jsonDecode(code);

  // 2️⃣ Récupérer l'user_id
  final userId = (data['user_id'] ?? 0) as int;

  if (userId == 0) {
    print("QR invalide");
    return;
  }

  // 3️⃣ Pause caméra avant de fermer
  await controller.pauseCamera();
  Navigator.pop(context, userId);
} catch (e) {
  print("QR invalide : $e");
}
    }
  });
}

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}