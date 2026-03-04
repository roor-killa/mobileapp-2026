import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await ThemeModeHolder.load(prefs);
  final token = prefs.getString('auth_token');

  runApp(MyBankApp(isLoggedIn: token != null));
}

class MyBankApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyBankApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeModeHolder.notifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'MyBank',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
        );
      },
    );
  }
}