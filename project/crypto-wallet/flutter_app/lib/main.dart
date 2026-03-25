import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'config/api_config.dart';
import 'config/groq_config.dart';
import 'services/stripe_service.dart';
import 'providers/auth_provider.dart';
import 'providers/security_provider.dart';
import 'providers/wallet_provider.dart';
import 'services/appwrite_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // Permet /verify-email pour le callback de vérification email
  await ApiConfig.loadFromDisk();
  await GroqDirectConfig.loadFromDisk();
  await StripeService.init();
  // Appwrite : client initialisé via appwrite_service
  try {
    appwriteClient;
  } catch (e, st) {
    debugPrint('Erreur Appwrite: $e');
    debugPrint('Stack: $st');
    rethrow;
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()..initAuthListener()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: App(),
    ),
  );
}
