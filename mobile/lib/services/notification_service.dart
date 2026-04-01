import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Initialise le service de notifications
  Future<void> initialiser() async {
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: android);

    await _plugin.initialize(settings);
  }

  // Affiche une notification
  Future<void> afficherNotification({
    required String titre,
    required String corps,
    int id = 0,
  }) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'scolarapp_channel',
      'ScolarApp',
      channelDescription: 'Notifications ScolarApp',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: android);

    await _plugin.show(id, titre, corps, details);
  }

  // Notifie l'étudiant d'un nouveau devoir
  Future<void> notifierNouveauDevoir(String matiere, String titre) async {
    await afficherNotification(
      titre: '📚 Nouveau devoir en $matiere',
      corps: titre,
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }
}