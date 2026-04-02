import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    Stripe.publishableKey = 'pk_test_51TGZ3rKkCoMf7VnvkK0kasL7na7R5w5RECIXrhHTv1YAP3rJtiwf3q3usABK5wQJC5I38JlYa99CT9nXWPA9rIIp00xOtzOBg0';
    await Stripe.instance.applySettings();
  } catch (e) {
    print('Erreur Stripe initialization: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transfert App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}