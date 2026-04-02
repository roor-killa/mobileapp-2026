import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_text.dart';
import '../../models/chat_message.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final messageController = TextEditingController();
  late List<ChatMessage> messages;

  @override
  void initState() {
    super.initState();
    messages = List.from(ChatMessage.mockMessages);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (messageController.text.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(content: messageController.text, isUser: true));
      messageController.clear();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            messages.add(
              ChatMessage(content: _generateBotResponse(), isUser: false),
            );
          });
        }
      });
    });
  }

  String _generateBotResponse() {
    final responses = [
      'C\'est intéressant! Voulez-vous en savoir plus?',
      'Je recommande de diversifier votre portefeuille.',
      'Le marché est actuellement haussier. À votre avis?',
      'Vous pourriez économiser €50 par mois sur les frais.',
      'Avez-vous pensé à augmenter votre fonds d\'urgence?',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: GradientText(
                'Financial Advisor',
                style: NEGsStyles.heading2,
              ),
            ),
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  return _buildMessage(message);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: TextField(
                        controller: messageController,
                        style: const TextStyle(color: NEGsColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle: TextStyle(color: NEGsColors.textSecondary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GlassIconButton(icon: Icons.send, onPressed: _sendMessage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: NEGsGradients.mainGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 20)),
              ),
            ),
          const SizedBox(width: 12),
          Flexible(
            child: GlassContainer(
              padding: const EdgeInsets.all(12),
              backgroundColor: message.isUser
                  ? NEGsColors.primaryViolet.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              child: Text(
                message.content,
                style: const TextStyle(
                  color: NEGsColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 12),
          if (message.isUser)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: NEGsGradients.mainGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('👤', style: TextStyle(fontSize: 20)),
              ),
            ),
        ],
      ),
    );
  }
}
