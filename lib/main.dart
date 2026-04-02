import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/etudiant_screen.dart';
import 'screens/page_de_connexion.dart';
import 'screens/motdepasseoublie.dart';
import 'screens/mot_de_passe.dart';
import 'screens/settings.dart';

// Handler pour les notifs reçues quand l'app est en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("📩 Notif arrière-plan : ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enregistrer le handler arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Récupérer et afficher le token FCM dans les logs
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Demander la permission de recevoir des notifs
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Afficher le token dans les logs (tu en auras besoin pour le test)
  String? token = await messaging.getToken();
  print("🔑 FCM Token : $token");

  // Écouter les notifs quand l'app est en premier plan
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("🔔 Notif reçue : ${message.notification?.title} - ${message.notification?.body}");
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeWidget(),
      routes: {
        '/page-de-connexion': (context) => const PageDeConnexionWidget(),
        '/mot-de-passe-oublie': (context) => const MotdepasseoublieWidget(),
        '/mot-de-passe': (context) => const MotDePasseWidget(),
        '/settings': (context) => const SettingsWidget(),
      },
    );
  }
}