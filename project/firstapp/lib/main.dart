import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/transfer_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _authToken;
  
  void _handleLoginSuccess(String token) {
    setState(() {
      _authToken = token;
    });
  }
  
  void _handleLogout() {
    setState(() {
      _authToken = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BankApp - Transfert d\'argent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: _authToken == null
          ? LoginScreen(onLoginSuccess: _handleLoginSuccess)
          : TransferScreen(onLogout: _handleLogout),
    );
  }
}