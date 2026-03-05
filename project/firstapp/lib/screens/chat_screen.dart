import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import '../services/bank_service.dart';

/// Chatbot IA : dialogue en temps réel avec l'assistant MyBank.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final BankService _bankService = BankService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: 'Bonjour, je suis l\'assistant MyBank. Posez-moi une question sur vos comptes, virements, cartes ou la sécurité.',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _loading = true;
    });
    _scrollToEnd();

    try {
      final reply = await _bankService.chat(text);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
        _loading = false;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          text: 'Désolé, une erreur s\'est produite. Vérifiez votre connexion.',
          isUser: false,
        ));
        _loading = false;
      });
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.gray50,
      appBar: AppBar(
        title: const Text('Assistant MyBank'),
        backgroundColor: DesignSystem.gray50,
        foregroundColor: DesignSystem.gray900,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 48, right: 16, top: 8, bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: DesignSystem.indigo50,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.smart_toy_rounded, color: DesignSystem.indigo600, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ),
                  );
                }
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!msg.isUser)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: DesignSystem.indigo50,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.smart_toy_rounded, color: DesignSystem.indigo600, size: 20),
                        ),
                      if (!msg.isUser) const SizedBox(width: 12),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isUser ? DesignSystem.indigo600 : DesignSystem.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                              bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              fontSize: 15,
                              color: msg.isUser ? Colors.white : DesignSystem.gray800,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                      if (msg.isUser) const SizedBox(width: 12),
                      if (msg.isUser)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: DesignSystem.gray200,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.person_rounded, color: DesignSystem.gray600, size: 20),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: DesignSystem.gray50,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      enabled: !_loading,
                      decoration: InputDecoration(
                        hintText: 'Votre question...',
                        filled: true,
                        fillColor: DesignSystem.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: DesignSystem.indigo600,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: _loading ? null : _send,
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
