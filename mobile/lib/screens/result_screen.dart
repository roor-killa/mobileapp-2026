import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool ok;
  final String title;
  final String message;

  const ResultScreen({super.key, required this.ok, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ok ? 'Transaction OK' : 'Transaction NOK')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ok ? Icons.check_circle : Icons.error, size: 72),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(ok ? 'Accueil' : 'Ré-essayer'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
