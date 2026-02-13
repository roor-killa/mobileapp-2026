import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- AJOUTE CET IMPORT
import 'screens/exchange_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation du formattage de date (CORRECTION DE L'ERREUR)
  await initializeDateFormatting(); 

  // Initialisation Supabase
  await Supabase.initialize(
    url: 'https://gyufqluiokjqkoperhrp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5dWZxbHVpb2tqcWtvcGVyaHJwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2MDM0ODUsImV4cCI6MjA4NjE3OTQ4NX0.Vo2UEUiLxJ-iQAB6Znci9uQdX2nKkFt6iDabkraCSmM',
  );

  runApp(const MoneyExchangeApp());
}

class MoneyExchangeApp extends StatelessWidget {
  const MoneyExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Transfer',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: session != null ? const ExchangeScreen() : const LoginScreen(),
    );
  }
}
