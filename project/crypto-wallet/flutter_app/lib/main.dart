import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url.trim(),
      anonKey: SupabaseConfig.anonKey.trim(),
    );
  } catch (e, st) {
    // "Invalid API key" = mauvaise clé ou clé anon désactivée dans le dashboard.
    debugPrint('Erreur Supabase: $e');
    debugPrint('Stack: $st');
    rethrow;
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF16132B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: const App(),
    ),
  );
}
