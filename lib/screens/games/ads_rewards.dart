import 'package:flutter/material.dart';

class AdsRewards extends StatefulWidget {
  const AdsRewards({super.key});
  @override
  State<AdsRewards> createState() => _AdsRewardsState();
}

class _AdsRewardsState extends State<AdsRewards> {
  double cagnotte = 0.0;

  void simulerPub() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      setState(() => cagnotte += 0.15);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bravo ! +0.15€ dans votre épargne Yann's BANK"),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gagner de l'argent")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monetization_on, size: 100, color: Colors.green),
            Text(
              "${cagnotte.toStringAsFixed(2)} €",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: simulerPub,
              icon: const Icon(Icons.play_circle),
              label: const Text("REGARDER UNE PUB (0.15€)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
