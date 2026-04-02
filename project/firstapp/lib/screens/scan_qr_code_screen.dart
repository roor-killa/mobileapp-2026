import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScanQRCodeScreen extends StatefulWidget {
  final Function(int)? onScanned; // optionnel

  const ScanQRCodeScreen({super.key, this.onScanned});

  @override
  _ScanQRCodeScreenState createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends State<ScanQRCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner un QR Code')),
      body: Column(
        children: [
          Expanded(
            child: QRView(
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
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: () async {
                await controller?.flipCamera();
              },
              child: const Text('Changer de caméra'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      final code = scanData.code;

      if (code != null) {
        try {
          final data = jsonDecode(code);
          final userId = data['user_id'];

          if (userId != null && userId is int) {

            // 🔹 1. callback si utilisé
            if (widget.onScanned != null) {
              widget.onScanned!(userId);
            }

            // 🔹 2. retour Navigator (plus propre)
            Navigator.pop(context, userId);
          }
        } catch (e) {
          print('QR invalide : $e');
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