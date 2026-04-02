import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQRCodeScreen extends StatelessWidget {
  final int userId;

  MyQRCodeScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mon QR Code')),
      body: Center(
        child: QrImage(
          data: userId.toString(), // ID de l'utilisateur
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}