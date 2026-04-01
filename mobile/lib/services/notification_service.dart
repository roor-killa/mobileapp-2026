import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _storageKey = 'uapay_notifications_v2';
  static const _seenTxKey = 'uapay_seen_tx_ids_v1';
  static const _maxItems = 100;

  final ValueNotifier<List<AppNotification>> items = ValueNotifier<List<AppNotification>>(const []);
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      items.value = AppNotification.decodeList(raw);
    }
    _syncUnread();
  }

  Future<void> add({
    required String title,
    required String message,
    String type = 'info',
    Map<String, dynamic> meta = const {},
  }) async {
    await init();
    final list = List<AppNotification>.from(items.value);
    list.insert(
      0,
      AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
        meta: meta,
      ),
    );
    if (list.length > _maxItems) {
      list.removeRange(_maxItems, list.length);
    }
    await _persist(list);
  }

  Future<void> markAllRead() async {
    await init();
    await _persist(items.value.map((e) => e.copyWith(isRead: true)).toList(growable: false));
  }

  Future<void> markRead(String id) async {
    await init();
    await _persist(items.value.map((e) => e.id == id ? e.copyWith(isRead: true) : e).toList(growable: false));
  }

  Future<void> remove(String id) async {
    await init();
    await _persist(items.value.where((e) => e.id != id).toList(growable: false));
  }

  Future<void> clear() async {
    await _persist(const []);
  }

  Future<void> seedWelcomeIfEmpty() async {
    await init();
    if (items.value.isNotEmpty) return;
    await add(
      title: 'Bienvenue sur UApay',
      message: 'Achats, transferts et réceptions apparaîtront ici en temps réel.',
      type: 'system',
    );
  }

  Future<Set<String>> getSeenTxIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_seenTxKey) ?? const <String>[]).toSet();
  }

  Future<void> setSeenTxIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenTxKey, ids.toList(growable: false));
  }

  Future<void> _persist(List<AppNotification> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, AppNotification.encodeList(list));
    items.value = list;
    _syncUnread();
  }

  void _syncUnread() {
    unreadCount.value = items.value.where((e) => !e.isRead).length;
  }
}
