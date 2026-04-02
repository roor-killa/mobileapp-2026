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
    // ─── Salutations ───────────────────────────────────────────────
    'bonjour': 'Bonjour ! Je suis Félicité, votre assistante BKN.\nComment puis-je vous aider aujourd\'hui ?',
    'salut': 'Salut ! Ravi de vous voir ! Posez-moi n\'importe quelle question sur l\'application.',
    'hello': 'Hello! I\'m Félicité, your BKN assistant. How can I help you today?',
    'bonsoir': 'Bonsoir ! Je suis disponible 24h/24. Comment puis-je vous aider ?',
    'aide': 'Bien sûr ! Voici ce que je peux vous expliquer :\n\n'
        '• Acheter / Vendre des BKN\n'
        '• Transférer de l\'argent\n'
        '• Cryptomonnaies (Bitcoin, Ethereum...)\n'
        '• QR Code (payer ou recevoir)\n'
        '• Sécurité et sessions\n'
        '• Profil et avatar\n'
        '• Historique des transactions\n\n'
        'Tapez votre question !',

    // ─── BKN — Achat ───────────────────────────────────────────────
    'acheter': 'Pour acheter des BKN :\n\n'
        '1. Allez dans Accueil > Acheter\n'
        '2. Entrez le montant souhaité (minimum 50 BKN)\n'
        '3. Choisissez votre méthode de paiement (carte bancaire)\n'
        '4. Validez l\'achat\n\n'
        'Taux : 1 BKN = 1 €\n'
        'Les BKN sont crédités instantanément sur votre compte.',
    'buy bkn': 'To buy BKN:\n\n'
        '1. Go to Home > Buy\n'
        '2. Enter the amount (minimum 50 BKN)\n'
        '3. Select payment method (credit card)\n'
        '4. Confirm purchase\n\n'
        'Rate: 1 BKN = 1 €\nBKN are credited instantly.',

    // ─── BKN — Vente ───────────────────────────────────────────────
    'vendre': 'Pour vendre des BKN :\n\n'
        '1. Allez dans Accueil > Vendre\n'
        '2. Entrez le montant à vendre\n'
        '3. Confirmez la transaction\n\n'
        'Le montant sera déduit de votre solde BKN.\n'
        'Conversion : 1 BKN = 1 €\n'
        'Vous ne pouvez pas vendre plus que votre solde disponible.',
    'sell': 'To sell BKN:\n\n'
        '1. Go to Home > Sell\n'
        '2. Enter the amount to sell\n'
        '3. Confirm the transaction\n\n'
        '1 BKN = 1 €\nYou cannot sell more than your available balance.',

    // ─── Transfert ─────────────────────────────────────────────────
    'transfert': 'Pour transférer des BKN :\n\n'
        '1. Allez dans Accueil > Transférer\n'
        '2. Entrez le pseudo (@user), l\'email ou l\'ID du destinataire\n'
        '3. Indiquez le montant\n'
        '4. Validez la transaction\n\n'
        'Le transfert est instantané !\n'
        'Frais : 0% — aucun frais entre utilisateurs BKN.',
    'transfer': 'To transfer BKN:\n\n'
        '1. Go to Home > Transfer\n'
        '2. Enter recipient\'s username (@user), email or ID\n'
        '3. Enter the amount\n'
        '4. Confirm\n\n'
        'Instant transfer! Fees: 0%.',

    // ─── QR Code ───────────────────────────────────────────────────
    'qr code': 'Utiliser les QR codes :\n\n'
        'Recevoir un paiement :\n'
        '• Allez dans Menu > Recevoir QR\n'
        '• Montrez votre QR code à l\'expéditeur\n\n'
        'Payer quelqu\'un :\n'
        '• Allez dans Menu > Scanner QR\n'
        '• Scannez le QR code du destinataire\n'
        '• Le transfert se fait automatiquement\n\n'
        'Chaque QR code est unique et lié à votre compte.',
    'qr': 'QR Code usage:\n\n'
        'Receive payment:\n'
        '• Go to Menu > Receive QR\n'
        '• Show your QR code to the sender\n\n'
        'Pay someone:\n'
        '• Go to Menu > Scan QR\n'
        '• Scan their QR code\n'
        '• Transfer is done automatically.',
    'scanner': 'Pour scanner un QR code :\n\n'
        '1. Allez dans Menu > Scanner QR\n'
        '2. Autorisez l\'accès à la caméra si demandé\n'
        '3. Pointez la caméra vers le QR code\n'
        '4. Le paiement s\'effectue automatiquement\n\n'
        'La caméra utilise mobile_scanner pour une détection rapide.',
    'recevoir': 'Pour recevoir un paiement :\n\n'
        '1. Allez dans Menu > Recevoir QR\n'
        '2. Votre QR code personnel s\'affiche\n'
        '3. Montrez-le à la personne qui vous paie\n'
        '4. Le montant est crédité instantanément',

    // ─── Solde ─────────────────────────────────────────────────────
    'solde': 'Votre solde BKN :\n\n'
        '• Affiché en temps réel sur la carte principale (Balance Card)\n'
        '• Mis à jour après chaque transaction\n'
        '• 1 BKN = 1 €\n'
        '• Solde de départ : 1 500 BKN pour les anciens comptes\n'
        '• Solde d\'inscription : 100 BKN de bonus offerts\n\n'
        'Consultez l\'Historique pour voir toutes vos opérations.',
    'balance': 'Your BKN balance:\n\n'
        '• Displayed in real-time on the Balance Card\n'
        '• Updated after every transaction\n'
        '• 1 BKN = 1 €\n'
        '• Welcome bonus: 100 BKN when you register',

    // ─── Cryptomonnaies ────────────────────────────────────────────
    'crypto': 'Cryptomonnaies disponibles sur BKN :\n\n'
        '• Bitcoin   (BTC) — environ 45 000 €\n'
        '• Ethereum  (ETH) — environ 2 800 €\n'
        '• Solana    (SOL) — environ 98 €\n'
        '• Cardano   (ADA) — environ 0,45 €\n'
        '• Polkadot  (DOT) — environ 6,50 €\n'
        '• Avalanche (AVAX) — environ 35 €\n\n'
        'Les prix sont simulés et fixés au moment de la transaction.',
    'bitcoin': 'Bitcoin (BTC) :\n\n'
        '• Prix actuel simulé : 45 000 €\n'
        '• Achetez avec vos BKN depuis l\'onglet Crypto\n'
        '• Le prix est fixé au moment de la transaction\n\n'
        'Allez dans Accueil > Crypto > Bitcoin pour acheter.',
    'ethereum': 'Ethereum (ETH) :\n\n'
        '• Prix actuel simulé : 2 800 €\n'
        '• Achetez avec vos BKN depuis l\'onglet Crypto\n'
        '• Consultez votre portefeuille crypto dans l\'app',
    'solana': 'Solana (SOL) :\n\n'
        '• Prix actuel simulé : 98 €\n'
        '• Achetez avec vos BKN depuis l\'onglet Crypto',
    'acheter crypto': 'Pour acheter des cryptomonnaies :\n\n'
        '1. Allez dans l\'onglet Crypto\n'
        '2. Choisissez la crypto (BTC, ETH, SOL...)\n'
        '3. Entrez le montant en BKN à dépenser\n'
        '4. Validez — la crypto est ajoutée à votre portefeuille\n\n'
        'Le prix au moment de l\'achat est enregistré.',
    'vendre crypto': 'Pour vendre des cryptomonnaies :\n\n'
        '1. Allez dans l\'onglet Crypto\n'
        '2. Sélectionnez la crypto à vendre\n'
        '3. Entrez le montant de crypto à vendre\n'
        '4. Les BKN sont crédités sur votre compte\n\n'
        'Le montant BKN reçu dépend du prix actuel de la crypto.',
    'portefeuille crypto': 'Votre portefeuille crypto :\n\n'
        '• Consultez vos holdings dans l\'onglet Crypto\n'
        '• Historique de tous vos achats et ventes\n'
        '• Prix d\'achat enregistré pour chaque transaction\n'
        '• Wallet address affiché pour chaque crypto',

    // ─── Profil ────────────────────────────────────────────────────
    'profil': 'Gérer votre profil :\n\n'
        '• Voir vos informations : Menu > Profil\n'
        '• Modifier nom, prénom, pseudo, email, téléphone\n'
        '• Changer votre photo de profil (avatar)\n'
        '• Modifier votre mot de passe\n'
        '• Voir votre niveau de vérification (Niveau 1 / Niveau 2)',
    'avatar': 'Changer votre photo de profil :\n\n'
        '1. Allez dans Profil > Modifier le profil\n'
        '2. Appuyez sur votre photo actuelle\n'
        '3. Choisissez une photo depuis votre galerie\n'
        '4. La photo est uploadée sur le serveur\n\n'
        'Votre avatar est visible par les autres utilisateurs lors des transferts.',
    'pseudo': 'Votre pseudo BKN :\n\n'
        '• Format : @nomutilisateur (ex: @john)\n'
        '• Utilisé pour recevoir des transferts\n'
        '• Modifiable dans Profil > Modifier le profil\n'
        '• Doit être unique sur toute la plateforme',
    'modifier profil': 'Pour modifier votre profil :\n\n'
        '1. Allez dans Profil (icône en bas)\n'
        '2. Appuyez sur "Modifier"\n'
        '3. Changez les champs souhaités\n'
        '4. Appuyez sur "Enregistrer"\n\n'
        'Les modifications sont appliquées immédiatement.',

    // ─── Sécurité ──────────────────────────────────────────────────
    'securite': 'Sécurité de votre compte BKN :\n\n'
        '• Mot de passe haché avec bcrypt (algorithme sécurisé)\n'
        '• Session persistante chiffrée sur votre appareil\n'
        '• Biométrie disponible dans les paramètres\n'
        '• Double authentification (2FA) activable\n'
        '• Notifications de connexion activables\n'
        '• Gestion des sessions actives',
    'security': 'BKN account security:\n\n'
        '• Password hashed with bcrypt\n'
        '• Encrypted session on your device\n'
        '• Biometric authentication available\n'
        '• 2FA (two-factor authentication) available\n'
        '• Active sessions management',
    'session': 'Gestion des sessions :\n\n'
        '• Voir tous vos appareils connectés dans Profil > Sécurité\n'
        '• Déconnecter un appareil précis à distance\n'
        '• Déconnecter toutes les sessions en un clic\n'
        '• Chaque session affiche : appareil, type, IP, dernière activité\n\n'
        'Si vous suspectez un accès non autorisé, déconnectez toutes les sessions.',
    'biometrie': 'Authentification biométrique :\n\n'
        '• Activez-la dans Profil > Sécurité > Biométrie\n'
        '• Utilise la reconnaissance d\'empreinte ou Face ID\n'
        '• Désactivable à tout moment depuis les paramètres',
    '2fa': 'Double authentification (2FA) :\n\n'
        '• Activez-la dans Profil > Sécurité > 2FA\n'
        '• Ajoute une couche de sécurité supplémentaire\n'
        '• Protection contre les accès non autorisés',
    'mot de passe': 'Changer votre mot de passe :\n\n'
        '1. Allez dans Profil > Sécurité\n'
        '2. Appuyez sur "Changer le mot de passe"\n'
        '3. Entrez votre ancien mot de passe\n'
        '4. Entrez et confirmez le nouveau\n\n'
        'Votre mot de passe est toujours stocké de façon chiffrée (bcrypt).',

    // ─── Historique ────────────────────────────────────────────────
    'historique': 'Votre historique de transactions :\n\n'
        '• Accessible depuis Accueil > Historique\n'
        '• Toutes les opérations : achat, vente, transfert, réception\n'
        '• Transactions crypto incluses\n'
        '• Filtrable par type et par date\n'
        '• Chaque transaction affiche : montant, date, expéditeur/destinataire',
    'history': 'Your transaction history:\n\n'
        '• Access from Home > History\n'
        '• All operations: buy, sell, transfer, receive\n'
        '• Crypto transactions included\n'
        '• Filterable by type and date',
    'transactions': 'Types de transactions BKN :\n\n'
        '• Achat — vous achetez des BKN avec euros\n'
        '• Vente — vous convertissez vos BKN en euros\n'
        '• Transfert — vous envoyez des BKN à quelqu\'un\n'
        '• Réception — vous recevez des BKN d\'un autre user\n\n'
        'Toutes les transactions sont enregistrées en base de données.',

    // ─── Inscription / Compte ──────────────────────────────────────
    'inscription': 'Créer un compte BKN :\n\n'
        '1. Sur l\'écran de connexion, appuyez sur "S\'inscrire"\n'
        '2. Remplissez : nom, prénom, pseudo (@user), email, téléphone, mot de passe\n'
        '3. Validez l\'inscription\n\n'
        'Bonus de bienvenue : 100 BKN offerts automatiquement !',
    'register': 'Create a BKN account:\n\n'
        '1. On the login screen, tap "Register"\n'
        '2. Fill in: first name, last name, username (@user), email, phone, password\n'
        '3. Confirm registration\n\n'
        'Welcome bonus: 100 BKN credited automatically!',
    'bonus': 'Bonus de bienvenue :\n\n'
        '• 100 BKN offerts dès l\'inscription\n'
        '• Crédités automatiquement à la création du compte\n'
        '• Apparaissent dans votre historique comme "Bonus de bienvenue"\n'
        '• Utilisables immédiatement pour transférer ou acheter des cryptos',

    // ─── Frais et taux ─────────────────────────────────────────────
    'commission': 'Frais et commissions BKN :\n\n'
        '• Transferts entre utilisateurs : 0% de frais\n'
        '• Achat de BKN : taux fixe 1 BKN = 1 €\n'
        '• Vente de BKN : taux fixe 1 BKN = 1 €\n'
        '• Transactions crypto : prix fixé au moment de l\'achat\n\n'
        'Aucune commission cachée !',
    'fees': 'BKN fees:\n\n'
        '• Transfers between users: 0% fees\n'
        '• Buy BKN: fixed rate 1 BKN = 1 €\n'
        '• Sell BKN: fixed rate 1 BKN = 1 €\n'
        '• Crypto: price fixed at moment of purchase',
    'taux': 'Taux de change BKN :\n\n'
        '• 1 BKN = 1 € (taux fixe)\n'
        '• Le taux ne fluctue pas\n'
        '• Les cryptomonnaies ont des prix simulés variables\n'
        '• BTC : ~45 000 € | ETH : ~2 800 € | SOL : ~98 €',

    // ─── Support ───────────────────────────────────────────────────
    'support': 'Contacter le support BKN :\n\n'
        '• Email : support@bkn.fr\n'
        '• Chat : disponible 24h/24 via Félicité\n'
        '• GitHub : github.com/roor-killa/mobileapp-2026\n\n'
        'Je suis Félicité et je suis toujours disponible ici !',

    // ─── Notifications ─────────────────────────────────────────────
    'notifications': 'Gestion des notifications :\n\n'
        '• Activez/désactivez dans Profil > Sécurité > Notifications\n'
        '• Notifications pour chaque transaction reçue\n'
        '• Alertes de connexion depuis un nouvel appareil\n'
        '• Modifiable à tout moment',

    // ─── Limites ───────────────────────────────────────────────────
    'limite': 'Limites de transactions :\n\n'
        '• Achat minimum : 50 BKN\n'
        '• Achat maximum : 1 000 BKN par transaction\n'
        '• Transfert limité par votre solde disponible\n'
        '• Vente limitée par votre solde disponible',
    'limits': 'Transaction limits:\n\n'
        '• Minimum purchase: 50 BKN\n'
        '• Maximum purchase: 1,000 BKN per transaction\n'
        '• Transfer limited by your available balance',

    // ─── Application ───────────────────────────────────────────────
    'application': 'L\'application BKN :\n\n'
        '• Développée en Flutter (Android)\n'
        '• Backend FastAPI + PostgreSQL\n'
        '• Testée sur Samsung Galaxy S10\n'
        '• Projet universitaire L3 Informatique 2026\n'
        '• Auteur : Patrice Beausoleil',
    'bkn': 'BKN est votre application de paiement étudiant.\n\n'
        '• 1 BKN = 1 €\n'
        '• Inscription : 100 BKN offerts\n'
        '• Transferts instantanés et gratuits\n'
        '• Cryptomonnaies intégrées\n'
        '• Paiement par QR code\n'
        '• Chatbot Félicité disponible 24h/24',

    // ─── Congés ────────────────────────────────────────────────────
    'merci': 'Avec plaisir ! N\'hésitez pas si vous avez d\'autres questions.',
    'thanks': 'You\'re welcome! Feel free to ask if you have more questions.',
    'au revoir': 'Au revoir ! Passez une excellente journée. Je reste disponible si besoin.',
    'bye': 'Goodbye! Have a great day. I\'m here if you need anything.',
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
      return 'Je n\'ai pas trouvé de réponse précise à votre question.\n\n'
          'Voici les sujets que je maîtrise :\n\n'
          '• Acheter / Vendre des BKN\n'
          '• Transférer de l\'argent\n'
          '• Cryptomonnaies (Bitcoin, Ethereum, Solana...)\n'
          '• QR Code (scanner ou recevoir)\n'
          '• Sécurité (sessions, 2FA, biométrie)\n'
          '• Profil et avatar\n'
          '• Historique des transactions\n'
          '• Bonus d\'inscription\n\n'
          'Reformulez votre question ou appuyez sur un raccourci ci-dessous.';
    }
    
    final suggestions = [
      'Je ne connais pas encore cette commande. Essayez :\n\n'
      '• "acheter" — acheter des BKN\n'
      '• "transférer" — envoyer des BKN\n'
      '• "crypto" — cryptomonnaies disponibles\n'
      '• "solde" — consulter mon solde\n'
      '• "qr code" — payer ou recevoir\n'
      '• "securite" — protéger mon compte\n'
      '• "historique" — voir mes transactions',
      
      'Désolé, je n\'ai pas compris. Essayez plutôt :\n\n'
      '• "profil" — modifier mon compte\n'
      '• "mot de passe" — changer le mot de passe\n'
      '• "session" — appareils connectés\n'
      '• "bonus" — bonus de bienvenue\n'
      '• "taux" — taux de change BKN\n'
      '• "support" — contacter l\'aide',
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
      {'q': 'Comment acheter des BKN ?',       'icon': Icons.shopping_cart,   'color': AppTheme.primaryBlue},
      {'q': 'Comment transférer des BKN ?',     'icon': Icons.send,            'color': AppTheme.accentPurple},
      {'q': 'Quels sont les frais ?',           'icon': Icons.percent,         'color': AppTheme.secondaryGreen},
      {'q': 'Comment scanner un QR code ?',     'icon': Icons.qr_code_scanner, 'color': AppTheme.primaryPink},
      {'q': 'Quelles cryptos sont disponibles ?','icon': Icons.currency_bitcoin,'color': AppTheme.warningOrange},
      {'q': 'Comment changer mon avatar ?',     'icon': Icons.person,          'color': AppTheme.accentPurple},
      {'q': 'Comment voir mes sessions ?',      'icon': Icons.devices,         'color': AppTheme.primaryBlue},
      {'q': 'Quel est mon bonus inscription ?', 'icon': Icons.card_giftcard,   'color': AppTheme.secondaryGreen},
    ];

    return faqs.map((faq) {
      final color = faq['color'] as Color;
      return Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(faq['icon'] as IconData, color: color, size: 16),
            ),
            title: Text(
              faq['q']! as String,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
            onTap: () {
              _messageController.text = faq['q']! as String;
              _sendMessage();
            },
          ),
          if (faq != faqs.last) const Divider(height: 1),
        ],
      );
    }).toList();
  }

  Widget _buildQuickActions() {
    // Chaque item : text = mot-clé envoyé au chatbot
    final suggestions = [
      {'icon': Icons.shopping_cart,    'text': 'acheter',     'label': 'Acheter',    'color': AppTheme.primaryBlue},
      {'icon': Icons.send,             'text': 'transfert',   'label': 'Transférer', 'color': AppTheme.accentPurple},
      {'icon': Icons.qr_code,          'text': 'qr code',    'label': 'QR Code',    'color': AppTheme.secondaryGreen},
      {'icon': Icons.currency_bitcoin, 'text': 'crypto',      'label': 'Crypto',     'color': AppTheme.warningOrange},
      {'icon': Icons.account_balance_wallet, 'text': 'solde', 'label': 'Solde',     'color': AppTheme.primaryPink},
      {'icon': Icons.lock_outline,     'text': 'securite',    'label': 'Sécurité',   'color': AppTheme.accentPurple},
      {'icon': Icons.history,          'text': 'historique',  'label': 'Historique', 'color': AppTheme.primaryBlue},
      {'icon': Icons.help_outline,     'text': 'support',     'label': 'Support',    'color': AppTheme.secondaryGreen},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((s) {
        final color = s['color'] as Color;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _messageController.text = s['text'] as String;
              _sendMessage();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(s['icon'] as IconData, color: color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    s['label'] as String,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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