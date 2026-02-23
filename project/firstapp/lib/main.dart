import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'screens/login_screen.dart';
import 'screens/wallet_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Stripe avec la clé publique (pk_test_...)
  // Remplacer par votre clé depuis dashboard.stripe.com
  Stripe.publishableKey = 'pk_test_IccVZ7bheyeCyav1XoHsC9lI009hbcLEsU';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const _AuthGate(),
    );
  }
}

/// Vérifie si un token est stocké pour décider de l'écran de démarrage
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          return const WalletScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
