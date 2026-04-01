import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService.instance.markAllRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Tout marquer comme lu',
            onPressed: () async => NotificationService.instance.markAllRead(),
            icon: const Icon(Icons.done_all),
          ),
          IconButton(
            tooltip: 'Tout effacer',
            onPressed: () async => NotificationService.instance.clear(),
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<AppNotification>>(
        valueListenable: NotificationService.instance.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Aucune notification pour le moment.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final n = items[index];
              return Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => NotificationService.instance.remove(n.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.delete_outline),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async => NotificationService.instance.markRead(n.id),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111C2E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: n.isRead ? const Color(0xFF1C2B45) : const Color(0xFF2D6CDF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: _color(n.type).withOpacity(0.16),
                          child: Icon(_icon(n.type), color: _color(n.type)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                  ),
                                  if (!n.isRead)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(color: Color(0xFF2D6CDF), shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(n.message, style: const TextStyle(color: Colors.white70, height: 1.35)),
                              const SizedBox(height: 8),
                              Text(_ago(n.createdAt), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static IconData _icon(String type) {
    switch (type) {
      case 'success': return Icons.check_circle_outline;
      case 'incoming': return Icons.call_received_rounded;
      case 'outgoing': return Icons.north_east_rounded;
      case 'warning': return Icons.schedule_outlined;
      case 'error': return Icons.error_outline;
      default: return Icons.notifications_none;
    }
  }

  static Color _color(String type) {
    switch (type) {
      case 'success': return Colors.greenAccent.shade200;
      case 'incoming': return Colors.cyanAccent.shade200;
      case 'outgoing': return Colors.orangeAccent.shade200;
      case 'warning': return Colors.amberAccent.shade200;
      case 'error': return Colors.redAccent.shade100;
      default: return Colors.blueAccent.shade100;
    }
  }

  static String _ago(DateTime at) {
    final d = DateTime.now().difference(at);
    if (d.inSeconds < 60) return "À l'instant";
    if (d.inMinutes < 60) return 'Il y a ${d.inMinutes} min';
    if (d.inHours < 24) return 'Il y a ${d.inHours} h';
    return 'Il y a ${d.inDays} j';
  }
}
