import 'package:flutter/material.dart';
import 'screens/transfer_screen.dart';
import 'login_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configuration Stripe (N'oublie pas ta clé PK test)
  Stripe.publishableKey = "pk_test_51TE8XCHtK23rlHRyItvWCUHoP1INpWXjUvm3eHAEgzO7whgGGSlhoUYBryezfk2ZqF4CcVYJicWgnATzOlhzx5Pl00jb4eiIWp";
  await Stripe.instance.applySettings();
  
  // 3. Récupération du token sauvegardé
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  // 4. Injection dans le service (Singleton)
  if (token != null) {
    ApiService().token = token;
  }

  // 5. Lancement de l'app avec l'information de connexion
  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transfert App L3',
      debugShowCheckedModeBanner: false,    

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // --- LA CORRECTION EST ICI ---
      // Si isLoggedIn est vrai, on va direct sur TransferScreen
      // Sinon, on affiche le LoginScreen
      home: isLoggedIn ? const TransferScreen() : const LoginScreen(), 
    );
  }
}