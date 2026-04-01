import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/transfer_screen.dart';
import 'screens/profile_screen.dart'; // Assure-toi que ce fichier existe
import 'login_screen.dart';
import 'services/api_service.dart';

void main() async {
  // 1. Initialisation des services Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configuration Stripe (Ta clé PK test)
  Stripe.publishableKey = "pk_test_51TE8XCHtK23rlHRyItvWCUHoP1INpWXjUvm3eHAEgzO7whgGGSlhoUYBryezfk2ZqF4CcVYJicWgnATzOlhzx5Pl00jb4eiIWp";
  await Stripe.instance.applySettings();
  
  // 3. Récupération du token sauvegardé pour l'auto-connexion
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  // 4. Injection du token dans le singleton ApiService
  if (token != null) {
    ApiService().token = token;
  }

  // 5. Lancement de l'application
  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transfert App L3',
      debugShowCheckedModeBanner: false,    
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Si connecté -> MainNavigation (avec la barre du bas), sinon -> Login
      home: isLoggedIn ? const MainNavigation() : const LoginScreen(), 
    );
  }
}

// --- NOUVELLE CLASSE POUR LA NAVIGATION PAR ONGLETS ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Liste des écrans accessibles via la barre de navigation
  final List<Widget> _pages = [
    const TransferScreen(), // Ton écran actuel (Solde + QR)
    const ProfileScreen(),  // Le nouvel écran d'infos compte
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack permet de changer d'onglet sans recharger les pages
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Portefeuille',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mon Compte',
          ),
        ],
      ),
    );
  }
}