class MessageModel {
  final String id;
  final String expediteurId;
  final String contenu;
  final DateTime timestamp;
  final bool lu;

  MessageModel({
    required this.id,
    required this.expediteurId,
    required this.contenu,
    required this.timestamp,
    this.lu = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      expediteurId: json['expediteur_id'] as String? ?? '',
      contenu: json['contenu'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      lu: json['lu'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'expediteur_id': expediteurId,
        'contenu': contenu,
        'lu': lu,
      };
}
