import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'screens/splash_screen.dart';
import 'services/deep_link_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // In release, you might forward to Crashlytics/Sentry.
  };

  ErrorWidget.builder = (details) {
    return Material(
      color: const Color(0xFF0B1220),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Oups… Une erreur est survenue',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Optional: if you rely on --dart-define and the values are missing,
  // show a friendly screen instead of crashing/hanging.
  final bool missingConfig =
      AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty;

  if (missingConfig) {
    runApp(const _ConfigMissingApp());
    return;
  }

  await NotificationService.instance.init();
  await NotificationService.instance.seedWelcomeIfEmpty();

  // Supabase init (keep awaited; it's fast and required for auth/state).
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // ✅ IMPORTANT: run the UI FIRST so you never get a black screen
  // if deep link init hangs on some devices/emulators.
  runApp(const App());

  // Start deep link handling AFTER UI is up (do not block startup).
  Future.microtask(() async {
    try {
      await DeepLinkService.instance.start(navigatorKey: App.navigatorKey);
    } catch (e, st) {
      debugPrint('DeepLinkService start failed: $e');
      debugPrint('$st');
    }
  });
}

/// Global RouteObserver used by AppShell to detect push/pop events.
final RouteObserver<ModalRoute<void>> homeRouteObserver = RouteObserver<ModalRoute<void>>();

class App extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'UApay',
      // Premium dark banking UI (inspired by modern fintech apps).
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6CDF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B1220),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF111C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF1C2B45)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111C2E),
          hintStyle: const TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1C2B45)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1C2B45)),
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
      navigatorObservers: [homeRouteObserver],
      home: const SplashScreen(),
    );
  }
}

class _ConfigMissingApp extends StatelessWidget {
  const _ConfigMissingApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: App.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/branding/uapay_logo.png', height: 80),
                const SizedBox(height: 14),
                const Text(
                  'Configuration Supabase manquante',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const Text(
                  '''Lance l'app avec --dart-define, ou configure lib/config.dart.

Exemple:
flutter run ^
  --dart-define=SUPABASE_URL=https://XXXX.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=YYYY
''',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
