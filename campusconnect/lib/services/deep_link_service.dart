import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement_model.dart';
import '../models/event_model.dart';
import '../screens/announcements/announcement_detail_screen.dart';
import '../screens/events/event_detail_screen.dart';

class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();

  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    // Deep link au démarrage (app fermée)
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        await _handleLink(initialLink, navigatorKey);
      }
    } catch (_) {}

    // Deep links pendant l'exécution (app en arrière-plan)
    _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri, navigatorKey);
    });
  }

  static Future<void> _handleLink(
    Uri uri,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    if (uri.scheme != 'campusconnect') return;

    final segments = uri.pathSegments;
    if (segments.length < 2) return;

    final type = segments[0];
    final id = segments[1];
    final client = Supabase.instance.client;

    // Attendre que le navigateur soit prêt
    await Future.delayed(const Duration(milliseconds: 500));
    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (type) {
      case 'announcement':
        final data = await client
            .from('announcements_full')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (data != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnnouncementDetailScreen(
                announcement: AnnouncementModel.fromJson(data),
              ),
            ),
          );
        }

      case 'event':
        final data = await client
            .from('events_full')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (data != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(
                event: EventModel.fromJson(data),
              ),
            ),
          );
        }

      case 'user':
        final data = await client
            .from('users')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (data != null && context.mounted) {
          _showUserCard(context, data);
        }
    }
  }

  static void _showUserCard(
      BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundImage: data['photo_url'] != null
                  ? NetworkImage(data['photo_url'] as String)
                  : null,
              child: data['photo_url'] == null
                  ? Text(
                      (data['nom'] as String? ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              data['nom'] as String? ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (data['filiere'] != null) ...[
              const SizedBox(height: 4),
              Text(
                data['filiere'] as String,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            if (data['bio'] != null) ...[
              const SizedBox(height: 8),
              Text(
                data['bio'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
