import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app_bkn/theme/app_theme.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final Map<String, String> _responses = {
    'bonjour': 'Bonjour ! Comment puis-je vous aider aujourd\'hui ? 😊',
    'salut': 'Salut ! Ravi de vous voir !',
    'hello': 'Hello ! How can I help you today?',
    'acheter': 'Pour acheter des BKN :\n\n1️⃣ Allez dans Accueil > Acheter\n2️⃣ Choisissez le montant (50-1000 BKN)\n3️⃣ Sélectionnez votre mode de paiement\n4️⃣ Validez l\'achat\n\n💰 Taux : 1 BKN = 1 €',
    'buy': 'To buy BKN:\n\n1️⃣ Go to Home > Buy\n2️⃣ Choose amount (50-1000 BKN)\n3️⃣ Select payment method\n4️⃣ Confirm purchase\n\n💰 Rate: 1 BKN = 1 €',
    'vendre': 'Pour vendre des BKN :\n\n1️⃣ Allez dans Accueil > Vendre\n2️⃣ Choisissez le montant à vendre\n3️⃣ Validez la transaction\n\n💶 Le montant sera converti en euros sur votre compte',
    'sell': 'To sell BKN:\n\n1️⃣ Go to Home > Sell\n2️⃣ Choose amount\n3️⃣ Confirm transaction',
    'transfert': 'Pour transférer des BKN :\n\n1️⃣ Allez dans Accueil > Transférer\n2️⃣ Entrez le pseudo du destinataire\n3️⃣ Indiquez le montant\n4️⃣ Validez\n\n⚡ Transfert instantané !',
    'transfer': 'To transfer BKN:\n\n1️⃣ Go to Home > Transfer\n2️⃣ Enter recipient\'s username\n3️⃣ Enter amount\n4️⃣ Confirm\n\n⚡ Instant transfer!',
    'qr code': 'Pour utiliser le QR code :\n\n📱 Recevoir : Menu > Recevoir\n📸 Scanner : Menu > Scan QR\n\nC\'est simple et sécurisé !',
    'qr': 'For QR code:\n\n📱 Receive: Menu > Receive QR\n📸 Scan: Menu > Scan QR\n\nSimple and secure!',
    'solde': '💰 Votre solde est actualisé en temps réel dans la Balance Card.\n\nVous pouvez aussi voir l\'historique détaillé de vos transactions.',
    'balance': '💰 Your balance is updated in real-time in the Balance Card.\n\nYou can also view detailed transaction history.',
    'commission': '✅ Frais : 0% pour tous les transferts entre utilisateurs BKN !\n\n🎁 Bonus de bienvenue : 100 BKN offerts !',
    'fees': '✅ Fees: 0% for all transfers between BKN users!\n\n🎁 Welcome bonus: 100 BKN free!',
    'securite': '🔒 Notre sécurité :\n• Authentification sécurisée\n• Transactions cryptées\n• Double validation\n• Support 24/7',
    'security': '🔒 Our security:\n• Secure authentication\n• Encrypted transactions\n• Double validation\n• 24/7 support',
    'support': '📞 Support disponible :\n• Email: support@bkn.fr\n• Tél: 01 23 45 67 89\n• Chat: 24/7',
    'historique': '📊 Historique des transactions :\n• Toutes vos opérations\n• Filtres par date/type\n• Export PDF disponible',
    'history': '📊 Transaction history:\n• All operations\n• Date/type filters\n• PDF export available',
    'bonus': '🎉 Bonus de bienvenue : 100 BKN offerts !\n\n💰 Parrainage : +50 BKN par ami invité',
    'bonus welcome': '🎉 Welcome bonus: 100 BKN free!\n\n💰 Referral: +50 BKN per friend',
    'limite': '📋 Limites journalières :\n• Achat max: 1000 BKN\n• Transfert max: 5000 BKN\n• Retrait max: 1000 BKN',
    'limits': '📋 Daily limits:\n• Purchase max: 1000 BKN\n• Transfer max: 5000 BKN\n• Withdrawal max: 1000 BKN',
    'mobile': '📱 Application disponible sur :\n• iOS (App Store)\n• Android (Google Play)',
    'app': '📱 App available on:\n• iOS (App Store)\n• Android (Google Play)',
    'merci': 'Avec plaisir ! N\'hésitez pas si vous avez d\'autres questions 😊',
    'thanks': 'You\'re welcome! Feel free to ask if you have more questions 😊',
    'au revoir': 'Au revoir ! Passez une excellente journée ✨',
    'bye': 'Goodbye! Have a great day ✨',
  };

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: _messageController.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        final botResponse = _generateResponse(userMessage.text);
        final botMessage = ChatMessage(
          text: botResponse,
          isUser: false,
          timestamp: DateTime.now(),
        );

        setState(() {
          _messages.add(botMessage);
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
  }

  String _generateResponse(String userInput) {
    final input = userInput.toLowerCase().trim();
    
    for (var entry in _responses.entries) {
      if (input.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return _getDefaultResponse(input);
  }

  String _getDefaultResponse(String input) {
    if (input.contains('?')) {
      return "Je n'ai pas compris votre question. Voici ce que je peux faire :\n\n"
          "💳 **Acheter/Vendre** - Comment acheter/vendre des BKN\n"
          "↔️ **Transférer** - Comment transférer de l'argent\n"
          "📱 **QR Code** - Comment scanner/recevoir\n"
          "💰 **Solde** - Consulter mon solde\n"
          "🔒 **Sécurité** - Questions sur la sécurité\n\n"
          "Posez-moi une question sur ces sujets !";
    }
    
    final suggestions = [
      "Je ne connais pas encore la réponse. Voici ce que je peux vous aider :\n\n"
      "• Comment acheter des BKN ?\n"
      "• Comment transférer de l'argent ?\n"
      "• Quels sont les frais ?\n"
      "• Comment contacter le support ?",
      
      "Désolé, je n'ai pas compris. Essayez plutôt :\n\n"
      "💰 Achat / Vente\n"
      "↔️ Transfert\n"
      "📱 QR Code\n"
      "🔒 Sécurité",
    ];
    
    return suggestions[_messages.length % suggestions.length];
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.chatGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Félicité',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Assistante virtuelle',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeScreen()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.chatGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(),
            
            const SizedBox(height: 30),
            
            const Text(
              'Bonjour !',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 10),
            
            const Text(
              'Je suis Félicité, votre assistante virtuelle. Comment puis-je vous aider aujourd\'hui ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 40),
            
            _buildQuickActions()
                .animate()
                .fadeIn(duration: 400.ms, delay: 600.ms),
            
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Questions fréquentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildFaqItems(),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFaqItems() {
    final faqs = [
      {'q': 'Comment acheter des BKN ?', 'a': 'Allez dans Accueil > Acheter'},
      {'q': 'Comment transférer ?', 'a': 'Accueil > Transférer, entrez le pseudo et le montant'},
      {'q': 'Quels sont les frais ?', 'a': '0% pour tous les transferts'},
      {'q': 'Comment scanner un QR ?', 'a': 'Utilisez l\'option Scan QR dans le menu'},
    ];

    return faqs.map((faq) {
      return Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.help, color: AppTheme.primaryPink, size: 16),
            ),
            title: Text(
              faq['q']!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
            onTap: () {
              _messageController.text = faq['q']!;
              _sendMessage();
            },
          ),
          if (faq != faqs.last) const Divider(),
        ],
      );
    }).toList();
  }

  Widget _buildQuickActions() {
    final suggestions = [
      {'icon': Icons.shopping_cart, 'text': 'Acheter', 'color': AppTheme.primaryBlue},
      {'icon': Icons.send, 'text': 'Transférer', 'color': AppTheme.accentPurple},
      {'icon': Icons.qr_code, 'text': 'QR Code', 'color': AppTheme.secondaryGreen},
      {'icon': Icons.help, 'text': 'Support', 'color': AppTheme.warningOrange},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: suggestions.map((s) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              String question = '';
              switch (s['text']) {
                case 'Acheter':
                  question = 'Comment acheter des BKN ?';
                  break;
                case 'Transférer':
                  question = 'Comment transférer des BKN ?';
                  break;
                case 'QR Code':
                  question = 'Comment utiliser le QR code ?';
                  break;
                case 'Support':
                  question = 'Comment contacter le support ?';
                  break;
              }
              _messageController.text = question;
              _sendMessage();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: (s['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: (s['color'] as Color).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(s['icon'] as IconData, color: s['color'] as Color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    s['text'] as String,
                    style: TextStyle(
                      color: s['color'] as Color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.chatGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.chat, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryBlue, AppTheme.primaryPink],
                      )
                    : null,
                color: message.isUser ? null : Colors.white,
                borderRadius: BorderRadius.circular(25).copyWith(
                  bottomLeft: message.isUser ? const Radius.circular(25) : Radius.zero,
                  bottomRight: message.isUser ? Radius.zero : const Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : AppTheme.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.person, color: AppTheme.primaryPink, size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.chatGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.chat, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25).copyWith(
                bottomLeft: Radius.zero,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(200),
                const SizedBox(width: 4),
                _buildDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppTheme.primaryPink,
        shape: BoxShape.circle,
      ),
    ).animate().shake(
      duration: 600.ms,
      delay: delay.ms,
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Écrivez votre message...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.chatGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}