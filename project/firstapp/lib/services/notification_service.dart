import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

/// Handler en arrière-plan (doit être une fonction top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase est déjà initialisé par main.dart
}

class NotificationService {
  static final _fcm   = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'bkn_wallet_channel',
    'Wallet BKN',
    description: 'Notifications de paiement et recharge',
    importance: Importance.high,
  );

  /// À appeler une seule fois au démarrage (dans main.dart)
  static Future<void> init() async {
    // Permissions iOS
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Canal Android
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Init flutter_local_notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit     = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Handler pour les messages en foreground
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _local.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });

    // Handler background déjà enregistré dans main.dart
  }

  /// Récupère le token FCM et l'envoie au backend
  static Future<void> registerToken() async {
    try {
      final token = await _fcm.getToken();
      print('[FCM] token: $token');
      if (token != null) {
        await ApiService().saveFcmToken(token);
        print('[FCM] token envoyé au backend');
      }

      // Rafraîchissement automatique du token
      _fcm.onTokenRefresh.listen((newToken) {
        ApiService().saveFcmToken(newToken);
      });
    } catch (e) {
      print('[FCM] erreur: $e');
    }
  }
}
