import 'package:flutter/material.dart';
import 'screens/transfer_screen.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transfert App L3',
      debugShowCheckedModeBanner: false,    

      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // L'application démarre sur l'écran de Login
      home: LoginScreen(), 
    );
  }
}