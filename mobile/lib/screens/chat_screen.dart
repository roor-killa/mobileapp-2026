import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/chat_action_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final List<_Msg> _msgs = [];
  bool _loading = false;
  final ChatActionService _actions = ChatActionService();

  // Android Emulator -> PC localhost
  final String ollamaBaseUrl = 'http://10.0.2.2:11434';
  final String model = 'llama3.2:latest';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _msgs.add(_Msg(role: 'user', text: text));
      _loading = true;
      _ctrl.clear();
    });

    try {
      final localReply = await _actions.handleMessage(text);
      if (localReply != null) {
        setState(() {
          _msgs.add(_Msg(role: 'assistant', text: localReply));
        });
        return;
      }

      final uri = Uri.parse('$ollamaBaseUrl/api/chat');
      final body = {
        "model": model,
        "stream": false,
        "messages": _msgs.map((m) => {"role": m.role, "content": m.text}).toList(),
      };

      final res = await http
          .post(uri, headers: {"Content-Type": "application/json"}, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Ollama error ${res.statusCode}: ${res.body}');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = (data["message"]?["content"] ?? "").toString();

      setState(() {
        _msgs.add(_Msg(role: 'assistant', text: msg.isEmpty ? "(vide)" : msg));
      });
    } catch (e) {
      setState(() {
        _msgs.add(_Msg(role: 'assistant', text: "Erreur: $e"));
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatBot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final m = _msgs[i];
                final isUser = m.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF2D6CDF) : const Color(0xFF111C2E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1C2B45)),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(hintText: 'Écris un message...'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _loading ? null : _send,
                  icon: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String role; // 'user' or 'assistant'
  final String text;
  _Msg({required this.role, required this.text});
}
