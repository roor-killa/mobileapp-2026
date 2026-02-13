import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/user_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/buy_screen.dart';
import 'screens/sell_screen.dart';
import 'screens/transfer_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/qr_receive_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/analytics_screen.dart';

void main() {
  runApp(const BKNApp());
}

class BKNApp extends StatelessWidget {
  const BKNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'BKN · Paiement étudiant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/buy': (context) => const BuyScreen(),
          '/sell': (context) => const SellScreen(),
          '/transfer': (context) => const TransferScreen(),
          '/scan': (context) => const ScanScreen(),
          '/qr_receive': (context) => const QrReceiveScreen(),
          '/history': (context) => const HistoryScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/chatbot': (context) => const ChatbotScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
        },
      ),
    );
  }
}