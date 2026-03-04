import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/design_system.dart';
import '../services/bank_service.dart';
import 'payment_request_response_screen.dart';

/// Écran des notifications. Fusion des demandes d'argent (API) et des notifications locales.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const String _storageKey = 'app_notifications';
  List<_NotificationItem> _items = [];
  bool _loading = true;
  final BankService _bankService = BankService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      List<_NotificationItem> local = [];
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>?;
        if (list != null) {
          local = list
              .map((e) => _NotificationItem(
                    id: e['id'] as String? ?? '',
                    title: e['title'] as String? ?? '',
                    body: e['body'] as String? ?? '',
                    date: e['date'] as String? ?? '',
                    read: e['read'] as bool? ?? false,
                  ))
              .toList();
        }
      }
      if (local.isEmpty) {
        final defaultItems = _getDefaultNotifications();
        await _saveLocal(prefs, defaultItems);
        local = defaultItems;
      }

      final paymentRequests = await _bankService.getPaymentRequests();
      final requestItems = paymentRequests.map((pr) {
        final fromName = pr['from_user_name'] as String? ?? 'Un utilisateur';
        final amount = (pr['amount'] as num?)?.toDouble() ?? 0.0;
        final msg = pr['message'] as String?;
        final createdAt = pr['created_at'] as String? ?? '';
        String dateStr = createdAt;
        try {
          final dt = DateTime.parse(createdAt);
          dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } catch (_) {}
        return _NotificationItem(
          id: 'pr_${pr['id']}',
          title: 'Demande d\'argent',
          body: '$fromName vous demande ${amount.toStringAsFixed(2)} €${msg != null && msg.isNotEmpty ? '\n$msg' : ''}',
          date: dateStr,
          read: false,
          isPaymentRequest: true,
          paymentRequestData: pr,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _items = [...requestItems, ...local];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<_NotificationItem> _getDefaultNotifications() {
    final now = DateTime.now();
    final formatter = _dateFormat(now);
    return [
      _NotificationItem(id: '1', title: 'Bienvenue', body: 'Votre compte est actif. Vous pouvez effectuer des virements et consulter vos comptes.', date: formatter, read: false, isPaymentRequest: false),
      _NotificationItem(id: '2', title: 'Sécurité', body: 'Activez la connexion biométrique dans Profil > Préférences pour plus de sécurité.', date: formatter, read: false, isPaymentRequest: false),
    ];
  }

  Future<void> _saveLocal(SharedPreferences prefs, List<_NotificationItem> localItems) async {
    final list = localItems.map((e) => {'id': e.id, 'title': e.title, 'body': e.body, 'date': e.date, 'read': e.read}).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  String _dateFormat(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _save(SharedPreferences prefs) async {
    final localOnly = _items.where((e) => e.isPaymentRequest != true).toList();
    final list = localOnly.map((e) => {'id': e.id, 'title': e.title, 'body': e.body, 'date': e.date, 'read': e.read}).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  Future<void> _markRead(_NotificationItem item) async {
    if (item.isPaymentRequest == true) return;
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      setState(() {
        _items = _items.map((e) => e.id == item.id ? _NotificationItem(id: e.id, title: e.title, body: e.body, date: e.date, read: true, isPaymentRequest: e.isPaymentRequest) : e).toList();
      });
      final prefs = await SharedPreferences.getInstance();
      await _save(prefs);
    }
  }

  Future<void> _markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _items = _items.map((e) => _NotificationItem(id: e.id, title: e.title, body: e.body, date: e.date, read: true, isPaymentRequest: e.isPaymentRequest)).toList();
    });
    await _save(prefs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.gray100,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: DesignSystem.gray100,
        foregroundColor: DesignSystem.gray900,
        elevation: 0,
        actions: [
          if (_items.any((e) => !e.read))
            TextButton(
              onPressed: _loading ? null : _markAllRead,
              child: const Text('Tout marquer lu'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 64, color: DesignSystem.gray400),
                      const SizedBox(height: 16),
                      Text('Aucune notification', style: TextStyle(fontSize: 16, color: DesignSystem.gray600)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space24, vertical: DesignSystem.space16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: item.read ? DesignSystem.gray50 : DesignSystem.white,
                        borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                        child: InkWell(
                          onTap: () {
                            if (item.isPaymentRequest == true && item.paymentRequestData != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PaymentRequestResponseScreen(paymentRequest: item.paymentRequestData!),
                                ),
                              ).then((_) => _load());
                            } else {
                              _markRead(item);
                            }
                          },
                          borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                          child: Padding(
                            padding: const EdgeInsets.all(DesignSystem.space16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: DesignSystem.indigo50,
                                    borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                                  ),
                                  child: Icon(item.read ? Icons.notifications_rounded : Icons.notifications_active_rounded, color: DesignSystem.indigo600, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DesignSystem.gray900)),
                                      const SizedBox(height: 4),
                                      Text(item.body, style: TextStyle(fontSize: 13, color: DesignSystem.gray600)),
                                      const SizedBox(height: 4),
                                      Text(item.date, style: TextStyle(fontSize: 11, color: DesignSystem.gray400)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _NotificationItem {
  final String id;
  final String title;
  final String body;
  final String date;
  final bool read;
  final bool isPaymentRequest;
  final Map<String, dynamic>? paymentRequestData;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.read,
    this.isPaymentRequest = false,
    this.paymentRequestData,
  });
}
