import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stripe — clé publique de test (remplacer par votre clé réelle)
  // Obtenez vos clés sur https://dashboard.stripe.com/test/apikeys
  Stripe.publishableKey = 'pk_test_51THta4FZTElG1hjOcXvuCs9BbVEpPHvdTlvv8naLk0mgiBJYlQKjNOOdrEwgsQ1xU9AnsKxLLkPweASX5R4OQ0Lt00ePthIO24';

  // Portrait uniquement
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Style de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const TransfertApp(),
    ),
  );
}
