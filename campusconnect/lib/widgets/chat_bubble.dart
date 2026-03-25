import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final ChatDestination? destination;
  final VoidCallback? onGoTap;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.destination,
    this.onGoTap,
  });

  String _destinationLabel(ChatDestination dest) {
    switch (dest) {
      case ChatDestination.announcements:
        return 'Annonces';
      case ChatDestination.events:
        return 'Événements';
      case ChatDestination.messages:
        return 'Messages';
      case ChatDestination.profile:
        return 'Profil';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (!isUser && destination != null && onGoTap != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onGoTap,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text('Y aller  ·  ${_destinationLabel(destination!)}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
