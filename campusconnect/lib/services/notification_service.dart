import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Handler background — doit être une fonction top-level
@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  await NotificationService._display(message);
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'campusconnect_channel';
  static const _channelName = 'CampusConnect';

  static Future<void> init() async {
    // Demande de permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Canal Android
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifications CampusConnect',
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialisation flutter_local_notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(const InitializationSettings(android: androidInit));

    // Handlers
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_display);
  }

  // Affiche la notification localement (foreground + background)
  static Future<void> _display(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;

    await _local.show(
      message.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // Sauvegarde le token FCM dans Supabase et écoute les refreshs
  static Future<void> saveToken(String userId) async {
    final token = await _fcm.getToken();
    if (token == null) return;

    await Supabase.instance.client
        .from('users')
        .update({'fcm_token': token})
        .eq('id', userId);

    _fcm.onTokenRefresh.listen((newToken) {
      Supabase.instance.client
          .from('users')
          .update({'fcm_token': newToken})
          .eq('id', userId);
    });
  }
}
