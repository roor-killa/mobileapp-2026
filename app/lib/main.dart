import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ClickerApp());
}

class ClickerApp extends StatelessWidget {
  const ClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compteur Coloré',
      home: const ClickerPage(),
    );
  }
}

class ClickerPage extends StatefulWidget {
  const ClickerPage({super.key});

  @override
  State<ClickerPage> createState() => _ClickerPageState();
}

class _ClickerPageState extends State<ClickerPage> {
  int count = 0;
  Color color = Colors.black;

  final Random random = Random();

  void increment() {
    setState(() {
      count++;
      color = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    });
  }

  void reset() {
    setState(() {
      count = 0;
      color = Colors.black;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compteur Coloré')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: increment,
              child: const Text('Cliquez-moi !'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: reset,
              child: const Text('Réinitialiser'),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
