import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/supabase_service.dart';

class ReceiveQrScreen extends StatelessWidget {
  const ReceiveQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = SupabaseService();
    final uid = api.currentUserId ?? '';
    final payload = 'bkn://user/$uid';

    return Scaffold(
      appBar: AppBar(title: const Text('Recevoir (QR Code)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Fais scanner ce QR pour te transférer des BKN', textAlign: TextAlign.center),
              const SizedBox(height: 14),
              QrImageView(data: payload, size: 240),
              const SizedBox(height: 12),
              SelectableText(payload, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
