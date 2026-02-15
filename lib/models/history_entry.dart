class HistoryEntry {
  final String id;
  final String style; // cartoon/anime/threeD
  final String imagePath;
  final int resolution;
  final String extra;
  final int createdAtMs;
  bool favorite;

  HistoryEntry({
    required this.id,
    required this.style,
    required this.imagePath,
    required this.resolution,
    required this.extra,
    required this.createdAtMs,
    required this.favorite,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'style': style,
        'imagePath': imagePath,
        'resolution': resolution,
        'extra': extra,
        'createdAtMs': createdAtMs,
        'favorite': favorite,
      };

  static HistoryEntry fromJson(Map<String, dynamic> j) => HistoryEntry(
        id: j['id'] as String,
        style: j['style'] as String,
        imagePath: j['imagePath'] as String,
        resolution: j['resolution'] as int,
        extra: (j['extra'] as String?) ?? '',
        createdAtMs: j['createdAtMs'] as int,
        favorite: (j['favorite'] as bool?) ?? false,
      );
}
