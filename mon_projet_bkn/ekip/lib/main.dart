import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // On utilise l'ancien écran de login (User 1 / User 2)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BKN App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(), // <-- Point d'entrée : Sélection simple User 1 / User 2
    );
  }
}
