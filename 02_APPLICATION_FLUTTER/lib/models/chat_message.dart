import 'package:uuid/uuid.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    String? id,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  static List<ChatMessage> mockMessages = [
    ChatMessage(
      content: 'Bonjour! Comment puis-je vous aider aujourd\'hui?',
      isUser: false,
    ),
    ChatMessage(content: 'Je veux investir dans Bitcoin', isUser: true),
    ChatMessage(
      content:
          'Bitcoin est une bonne option! Actuellement à €42,500. Voulez-vous en acheter?',
      isUser: false,
    ),
  ];
}
