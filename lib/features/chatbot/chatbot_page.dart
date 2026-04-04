import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/auth_provider.dart';

class _Message {
  final String content;
  final bool isUser;
  final DateTime time;
  _Message({required this.content, required this.isUser}) : time = DateTime.now();
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _inputCtrl   = TextEditingController();
  final _scrollCtrl  = ScrollController();
  final _api         = ApiService.instance;
  final List<_Message> _messages = [];
  bool _isLoading = false;

  // Suggestions rapides
  static const _suggestions = [
    'Quel est mon solde ?',
    'Mes dernières transactions ?',
    'Comment envoyer de l\'argent ?',
    'Comment recharger mon compte ?',
  ];

  @override
  void initState() {
    super.initState();
    // Message de bienvenue
    final user = context.read<AuthProvider>().user;
    _messages.add(_Message(
      content: 'Bonjour ${user?.firstName ?? ''} ! Je suis votre assistant TransfertApp. Comment puis-je vous aider ?',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    _inputCtrl.clear();

    setState(() {
      _messages.add(_Message(content: text.trim(), isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    // Construire l'historique pour le contexte (max 6 derniers messages)
    final history = _messages
        .where((m) => m != _messages.last) // Exclure le dernier (déjà envoyé)
        .toList()
        .reversed
        .take(6)
        .toList()
        .reversed
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.content})
        .toList();

    try {
      final res = await _api.post(ApiConstants.chatbot, {
        'message': text.trim(),
        'history': history,
      });
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messages.add(_Message(
          content: res['reply'] ?? 'Désolé, je ne peux pas répondre maintenant.',
          isUser: false,
        ));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messages.add(_Message(
          content: 'Service temporairement indisponible. Réessayez plus tard.',
          isUser: false,
        ));
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assistant IA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('En ligne', style: TextStyle(fontSize: 11, color: AppColors.success)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(_Message(
                  content: 'Conversation réinitialisée. Comment puis-je vous aider ?',
                  isUser: false,
                ));
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Liste des messages ─────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) return const _TypingIndicator();
                return _MessageBubble(message: _messages[i]);
              },
            ),
          ),

          // ── Suggestions rapides ────────────────────────────────────────
          if (_messages.length <= 1)
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _suggestions.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _send(_suggestions[i]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(_suggestions[i],
                        style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ),

          // ── Zone de saisie ─────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 8, top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    onSubmitted: _send,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _send(_inputCtrl.text),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha:0.3), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bulle de message ────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final _Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.primaryGradient : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? AppColors.primary : Colors.black).withValues(alpha:0.08),
                    blurRadius: 8, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─── Indicateur de frappe ────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4), bottomRight: Radius.circular(18),
              ),
            ),
            child: FadeTransition(
              opacity: _anim,
              child: Row(
                children: List.generate(3, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 7, height: 7,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
