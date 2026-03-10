import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // <-- Importe le Login au lieu du Register
import 'package:intl/date_symbol_data_local.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important
  await initializeDateFormatting('fr_FR', null); // Pour les dates en français
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
