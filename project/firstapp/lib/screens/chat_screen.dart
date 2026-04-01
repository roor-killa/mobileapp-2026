import 'package:flutter/material.dart';
// import '../services/api_service.dart'; // On l'activera à la prochaine étape

// --- COULEURS DU THEME ---
const Color bgDark = Color(0xFF09090B);
const Color cardDark = Color(0xFF18181B);
const Color zinc700 = Color(0xFF27272A);
const Color emerald500 = Color(0xFF10B981);
const Color textGray = Color(0xFF71717A);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // final ApiService _apiService = ApiService(); // Pour la connexion Laravel
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isTyping = false; // Permet d'afficher l'animation "L'IA écrit..."

  // Notre liste de messages (On commence avec un message de bienvenue)
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': "Bonjour Boss ! Je suis BKN-Bot, votre assistant IA personnel. Je suis connecté à votre portefeuille. Comment puis-je vous aider aujourd'hui ?"
    }
  ];

  // Fonction pour envoyer un message
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 1. On ajoute le message de l'utilisateur à la liste
    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _messageController.clear();
      _isTyping = true; // L'IA commence à "réfléchir"
    });
    
    _scrollToBottom();

    // TODO: 2. APPEL À TON API LARAVEL ICI (On le fera à la prochaine étape)
    // Pour l'instant, on simule un temps d'attente de 2 secondes
    await Future.delayed(const Duration(seconds: 2));

    // 3. Réponse (fictive pour l'instant) de l'IA
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'isUser': false,
          'text': "C'est noté ! Dès que nous aurons configuré la route API Laravel, je pourrai vous donner la réponse exacte générée par Gemini concernant cette demande."
        });
      });
      _scrollToBottom();
    }
  }

  // Petite fonction utilitaire pour toujours scroller tout en bas quand un message arrive
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- EN-TÊTE ---
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: zinc700)),
                child: const Icon(Icons.auto_awesome, color: emerald500),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Assistant IA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Propulsé par Gemini', style: TextStyle(color: emerald500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                ],
              ),
            ],
          ),
        ),

        // --- ZONE DES MESSAGES ---
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['isUser'] == true;

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75, // Ne prend pas toute la largeur
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? emerald500 : cardDark,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 5),
                      bottomRight: Radius.circular(isUser ? 5 : 20),
                    ),
                    border: isUser ? null : Border.all(color: zinc700),
                  ),
                  child: Text(
                    msg['text'],
                    style: TextStyle(
                      color: isUser ? Colors.black : Colors.white,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // --- INDICATEUR DE FRAPPE (L'IA réfléchit) ---
        if (_isTyping)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const SizedBox(
                    width: 15, height: 15,
                    child: CircularProgressIndicator(color: emerald500, strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text("BKN-Bot réfléchit...", style: TextStyle(color: textGray.withOpacity(0.7), fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),

        // --- CHAMP DE SAISIE ---
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: bgDark,
            border: Border(top: BorderSide(color: cardDark, width: 1.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: zinc700),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: null, // Permet au texte de passer à la ligne s'il est long
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: "Posez une question sur vos finances...",
                      hintStyle: TextStyle(color: textGray, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: emerald500,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}