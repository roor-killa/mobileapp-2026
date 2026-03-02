import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  
  runApp(MyBankApp(isLoggedIn: token != null));
}

class MyBankApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyBankApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyBank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}