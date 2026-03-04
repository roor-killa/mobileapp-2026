import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // <-- Importe le Login au lieu du Register

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BKN Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(), // <-- Démarre sur la page de connexion
    );
  }
}