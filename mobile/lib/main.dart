import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // On démarre sur le login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Étudiants',
      debugShowCheckedModeBanner: false, // Cache le bandeau "debug"
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Premier écran = connexion
    );
  }
}