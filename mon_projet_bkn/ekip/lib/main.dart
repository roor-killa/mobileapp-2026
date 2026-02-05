import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Importez le login

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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(), // <--- On commence ici maintenant !
    );
  }
}
