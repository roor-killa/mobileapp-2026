import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/buy_screen.dart';
import 'screens/sell_screen.dart';
import 'screens/transfer_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/qr_receive_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chatbot_screen.dart';

void main() {
  runApp(const BKNApp());
}

class BKNApp extends StatelessWidget {
  const BKNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BKN - Paiement étudiant',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/login',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/buy': (context) => const BuyScreen(),
        '/sell': (context) => const SellScreen(),
        '/transfer': (context) => const TransferScreen(),
        '/scan': (context) => const ScanScreen(),
        '/qr_receive': (context) => const QrReceiveScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/news': (context) => const NewsScreen(),
        '/events': (context) => const EventsScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0A2472),
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFF0A2472),
        secondary: const Color(0xFF00C9A7),
        surface: Colors.white,
        background: const Color(0xFFF8F9FA),
        error: const Color(0xFFFF6B6B),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0A2472),
        elevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF0A2472),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Color(0xFF0A2472)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF0A2472),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A2472),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}