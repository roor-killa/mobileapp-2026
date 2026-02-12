import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Zone de scan
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0A2472), width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 80, color: Color(0xFF0A2472)),
                    SizedBox(height: 20),
                    Text(
                      'Zone de scan',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Utilisateur / Scan (EXACTEMENT le storyboard)
              const Text(
                'Utilisateur / Scan',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              
              const SizedBox(height: 10),
              
              const Text(
                '@pool',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2472),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Bouton VALIDER (exactement comme storyboard)
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paiement @pool validé'),
                        backgroundColor: Color(0xFF00C9A7),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C9A7),
                  ),
                  child: const Text(
                    'VALIDER',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}