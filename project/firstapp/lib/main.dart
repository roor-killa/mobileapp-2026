import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionRestored = await AuthService().restaurerSession();
  runApp(MyApp(sessionRestored: sessionRestored));
}

class MyApp extends StatelessWidget {
  final bool sessionRestored;

  const MyApp({super.key, required this.sessionRestored});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Compte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: sessionRestored ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
