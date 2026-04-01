import 'dart:convert';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.meta = const {},
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic> meta;

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? meta,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      meta: meta ?? this.meta,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'meta': meta,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        type: json['type']?.toString() ?? 'info',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        isRead: json['isRead'] == true,
        meta: Map<String, dynamic>.from(json['meta'] as Map? ?? const {}),
      );

  static List<AppNotification> decodeList(String raw) {
    final data = jsonDecode(raw);
    if (data is! List) return const [];
    return data
        .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  static String encodeList(List<AppNotification> items) {
    return jsonEncode(items.map((e) => e.toJson()).toList(growable: false));
  }
}
