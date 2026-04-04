import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'features/auth/login_page.dart';
import 'navigation/main_navigation.dart';

class TransfertApp extends StatelessWidget {
  const TransfertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TransfertApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: AppColors.textPrimary,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
      ),
      home: const SplashRouter(),
    );
  }
}

// ─── Splash + Routage Auth ───────────────────────────────────────────────────
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final isAuth = await context.read<AuthProvider>().checkAuth();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => isAuth ? const MainNavigation() : const LoginPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: FadeTransition(
          opacity: _fade,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_rounded,
                    size: 90, color: Colors.white),
                SizedBox(height: 24),
                Text('TransfertApp',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                SizedBox(height: 8),
                Text('Transferts simples & sécurisés',
                    style: TextStyle(color: Colors.white70, fontSize: 15)),
                SizedBox(height: 56),
                CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
