import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppLoader());
}

/// Gère le chargement de la session avant d'afficher l'app.
/// StatefulWidget = le Future est créé une seule fois (évite les rebuilds).
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
    _sessionFuture = AuthService().restaurerSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        // Erreur inattendue → page de connexion par sécurité
        if (snapshot.hasError) {
          return MyApp(sessionRestored: false);
        }

        // Pendant le chargement : écran de démarrage
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
              useMaterial3: true,
            ),
            home: const Scaffold(
              backgroundColor: AppColors.primaryLight,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet,
                        size: 64, color: AppColors.primary),
                    SizedBox(height: 24),
                    CircularProgressIndicator(color: AppColors.primary),
                  ],
                ),
              ),
            ),
          );
        }

        return MyApp(sessionRestored: snapshot.data ?? false);
      },
    );
  }
}

class MyApp extends StatelessWidget {
  final bool sessionRestored;

  const MyApp({super.key, required this.sessionRestored});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VLT Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: sessionRestored ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
