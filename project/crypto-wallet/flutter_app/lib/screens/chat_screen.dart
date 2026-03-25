import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _chat = ChatService();
  final List<_Message> _messages = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _localFactsForAssistant(BuildContext context) {
    final wp = context.read<WalletProvider>();
    final auth = context.read<AuthProvider>();
    final name = auth.user?.name?.trim();
    final email = auth.user?.email ?? '';
    final who = (name != null && name.isNotEmpty) ? name : email;
    final iban = wp.myIban ?? '—';
    final pseudo = wp.myPseudonym ?? '—';
    final solde = wp.eurBalance.toStringAsFixed(2);
    return 'Identité affichée : $who\n'
        'Solde EUR affiché dans l’app : $solde €\n'
        'IBAN affiché : $iban\n'
        'Pseudonyme affiché : $pseudo';
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    final facts = _localFactsForAssistant(context);

    _controller.clear();
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _loading = true;
    });
    _scrollToBottom();

    final reply = await _chat.sendMessage(text, localAccountFacts: facts);

    if (mounted) {
      setState(() {
        _messages.add(_Message(text: reply, isUser: false));
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_rounded, color: AppTheme.primary, size: 24),
            SizedBox(width: 8),
            Text('Assistant NodEX', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && !_loading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppTheme.primary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Posez une question sur NodEX',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Virements, achats crypto, carte...',
                            style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.8), fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _messages.length) {
                        return _buildBubble('...', false, loading: true);
                      }
                      final m = _messages[i];
                      return _buildBubble(m.text, m.isUser);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardElevated,
              border: Border(top: BorderSide(color: AppTheme.border.withValues(alpha: 0.5))),
              boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Votre message...',
                        hintStyle: const TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      style: const TextStyle(color: AppTheme.textPrimary),
                      maxLines: 3,
                      minLines: 1,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _loading ? null : _send,
                    icon: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF042028)),
                          )
                        : const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: const Color(0xFF042028)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isUser, {bool loading = false}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: Border.all(color: isUser ? Colors.transparent : AppTheme.border.withValues(alpha: 0.45)),
          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: isUser ? 0.12 : 0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: loading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
            : Text(
                text,
                style: TextStyle(color: isUser ? const Color(0xFF042028) : AppTheme.textPrimary, fontSize: 15, height: 1.4),
              ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  _Message({required this.text, required this.isUser});
}
