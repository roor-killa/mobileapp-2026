import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/pin_screen.dart';
import 'services/auth_service.dart';
import 'services/preferences_service.dart';
import 'theme/app_colors.dart';

/// Notifier global pour le thème (clair/sombre).
/// Accessible depuis n'importe quel widget via `themeNotifier`.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Charger la préférence de thème avant de lancer l'app
  // try-catch : si SharedPreferences échoue, on lance quand même l'app
  try {
    final isDark = await PreferencesService.instance.getDarkMode();
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  } catch (_) {
    themeNotifier.value = ThemeMode.light;
  }
  runApp(const AppLoader());
}

/// Gère le chargement de la session avant d'afficher l'app.
class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  late final Future<bool> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = AuthService().restaurerSession().catchError((_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return FutureBuilder<bool>(
          future: _sessionFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildApp(themeMode, sessionRestored: false);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildApp(themeMode, loading: true);
            }
            return _buildApp(themeMode, sessionRestored: snapshot.data ?? false);
          },
        );
      },
    );
  }

  Widget _buildApp(ThemeMode themeMode, {bool loading = false, bool sessionRestored = false}) {
    return MaterialApp(
      title: 'VLT Bank',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: loading
          ? const _SplashScreen()
          : sessionRestored
              ? const _PinGate()
              : const LoginScreen(),
    );
  }
}

/// Écran de démarrage animé.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet, size: 72, color: Colors.white),
            SizedBox(height: 12),
            Text(
              'VLT Bank',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Votre banque de confiance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white60,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// Vérifie si un code PIN est activé et l'affiche le cas échéant.
class _PinGate extends StatefulWidget {
  const _PinGate();

  @override
  State<_PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<_PinGate> {
  bool? _pinEnabled;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final enabled = await PreferencesService.instance.isPinEnabled();
    if (!mounted) return;
    setState(() => _pinEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    if (_pinEnabled == null) return const _SplashScreen();
    if (_pinEnabled!) {
      return PinScreen(
        mode: PinMode.verify,
        onSuccess: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        },
      );
    }
    return const DashboardScreen();
  }
}
