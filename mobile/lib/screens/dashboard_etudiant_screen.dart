import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';
import '../models/matiere.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'login_screen.dart';

class DashboardEtudiantScreen extends StatefulWidget {
  const DashboardEtudiantScreen({super.key});

  @override
  State<DashboardEtudiantScreen> createState() =>
      _DashboardEtudiantScreenState();
}

class _DashboardEtudiantScreenState extends State<DashboardEtudiantScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final SessionService _session = SessionService();

  List<Note> notes = [];
  List<Matiere> matieres = [];
  List<Map<String, dynamic>> _moyennesClasse = [];
  bool _isLoading = false;

  late TabController _tabController;

  final List<Map<String, String>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  bool _isChatLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chargerDonnees();
    _messages.add({
      'role': 'assistant',
      'content':
          'Bonjour ${_session.etudiantConnecte?.prenom} ! 👋\nJe suis ton assistant scolaire. Tu peux me poser des questions sur tes notes ou le règlement scolaire.',
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);
    try {
      final etudiant = _session.etudiantConnecte!;
      final futures = [
        _apiService.getMatieres(),
        _apiService.getNotesEtudiant(etudiant.id!),
      ];

      // Charge les moyennes de la classe si l'étudiant a une classe
      if (etudiant.classeId != null) {
        futures.add(_apiService.getMoyennesClasse(etudiant.classeId!));
      }

      final results = await Future.wait(futures);

      setState(() {
        matieres = results[0] as List<Matiere>;
        notes = results[1] as List<Note>;
        if (etudiant.classeId != null) {
          _moyennesClasse =
              results[2] as List<Map<String, dynamic>>;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Note? _getNoteForMatiere(int matiereId) {
    try {
      return notes.firstWhere((n) => n.matiereId == matiereId);
    } catch (e) {
      return null;
    }
  }

  // Retourne la moyenne de classe pour une matière
  double? _getMoyenneClasseForMatiere(String matiereNom) {
    try {
      final m = _moyennesClasse.firstWhere(
          (m) => m['matiere'] == matiereNom);
      return (m['moyenne_classe'] as num?)?.toDouble();
    } catch (e) {
      return null;
    }
  }

  double? get _moyenneGenerale {
    final moyennes =
        notes.map((n) => n.moyenne).whereType<double>().toList();
    if (moyennes.isEmpty) return null;
    return moyennes.reduce((a, b) => a + b) / moyennes.length;
  }

  double? get _moyenneGeneraleClasse {
    if (_moyennesClasse.isEmpty) return null;
    final moyennes = _moyennesClasse
        .map((m) => (m['moyenne_classe'] as num?)?.toDouble())
        .whereType<double>()
        .toList();
    if (moyennes.isEmpty) return null;
    return moyennes.reduce((a, b) => a + b) / moyennes.length;
  }

  String _construireContexteNotes() {
    final etudiant = _session.etudiantConnecte!;
    final buffer = StringBuffer();
    buffer.writeln('Étudiant : ${etudiant.prenom} ${etudiant.nom}');
    if (etudiant.classeNom != null) {
      buffer.writeln('Classe : ${etudiant.classeNom}');
    }
    buffer.writeln('');
    buffer.writeln('Notes par matière :');

    for (final matiere in matieres) {
      final note = _getNoteForMatiere(matiere.id);
      if (note != null) {
        buffer.writeln('- ${matiere.nom} :');
        buffer.writeln(
            '  Note 1: ${note.note1 ?? "non renseignée"}, Note 2: ${note.note2 ?? "non renseignée"}, Note 3: ${note.note3 ?? "non renseignée"}');
        final moy = note.moyenne;
        if (moy != null) {
          buffer.writeln('  Moyenne: ${moy.toStringAsFixed(2)}/20');
        }
      } else {
        buffer.writeln('- ${matiere.nom} : aucune note');
      }
    }

    final mg = _moyenneGenerale;
    if (mg != null) {
      buffer.writeln('');
      buffer.writeln('Moyenne générale : ${mg.toStringAsFixed(2)}/20');
    }

    return buffer.toString();
  }

  Future<void> _envoyerMessage() async {
    final texte = _chatController.text.trim();
    if (texte.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': texte});
      _isChatLoading = true;
      _chatController.clear();
    });

    _scrollToBottom();

    try {
      final historique = _messages
          .skip(1)
          .map((m) => {'role': m['role']!, 'content': m['content']!})
          .toList();

      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
        },
        body: json.encode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 500,
          'system':
              '''Tu es un assistant scolaire pour l\'application de gestion des notes.
Tu aides l\'étudiant à comprendre ses résultats et à améliorer ses performances.
Tu peux aussi informer sur le règlement scolaire général (absences, retards, discipline).
Sois encourageant et bienveillant. Réponds en français. Sois concis (max 3-4 phrases).

Voici les données de l\'étudiant connecté :
${_construireContexteNotes()}''',
          'messages': historique,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reponse = data['content'][0]['text'];
        setState(() {
          _messages.add({'role': 'assistant', 'content': reponse});
          _isChatLoading = false;
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content':
                'Désolé, je n\'arrive pas à répondre pour le moment. 😕',
          });
          _isChatLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Erreur de connexion. Réessaie plus tard.',
        });
        _isChatLoading = false;
      });
    }

    _scrollToBottom();
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
    final etudiant = _session.etudiantConnecte!;
    final mg = _moyenneGenerale;
    final mgClasse = _moyenneGeneraleClasse;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11998E),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${etudiant.prenom} ${etudiant.nom}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            Text(
              etudiant.classeNom ?? 'Espace étudiant',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _session.deconnecterEtudiant();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.grade), text: 'Mes notes'),
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Assistant'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [

          // ── ONGLET NOTES ──────────────────────────────────────
          _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: Color(0xFF11998E)))
              : RefreshIndicator(
                  onRefresh: _chargerDonnees,
                  color: const Color(0xFF11998E),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [

                      // Carte moyenne générale + moyenne classe
                      if (mg != null) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF11998E),
                                Color(0xFF38EF7D)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF11998E)
                                    .withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.emoji_events,
                                      color: Colors.white, size: 40),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ma moyenne générale',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13),
                                      ),
                                      Text(
                                        '${mg.toStringAsFixed(2)}/20',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withOpacity(0.2),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      mg >= 16
                                          ? 'Très bien'
                                          : mg >= 14
                                              ? 'Bien'
                                              : mg >= 12
                                                  ? 'Assez bien'
                                                  : mg >= 10
                                                      ? 'Passable'
                                                      : 'Insuffisant',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Moyenne de la classe
                              if (mgClasse != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Moyenne de la classe',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13),
                                      ),
                                      Text(
                                        '${mgClasse.toStringAsFixed(2)}/20',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      const Text(
                        'Notes par matière',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E3B),
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...matieres.map((matiere) {
                        final note = _getNoteForMatiere(matiere.id);
                        final moyenne = note?.moyenne;
                        final moyenneClasse =
                            _getMoyenneClasseForMatiere(matiere.nom);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: moyenne == null
                                        ? Colors.grey.withOpacity(0.1)
                                        : moyenne >= 10
                                            ? const Color(0xFF11998E)
                                                .withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.book,
                                    color: moyenne == null
                                        ? Colors.grey
                                        : moyenne >= 10
                                            ? const Color(0xFF11998E)
                                            : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        matiere.nom,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (note != null)
                                        Text(
                                          '${note.note1 ?? '-'}  •  ${note.note2 ?? '-'}  •  ${note.note3 ?? '-'}',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 13,
                                          ),
                                        )
                                      else
                                        Text(
                                          'Aucune note',
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 13,
                                          ),
                                        ),
                                      // Moyenne de la classe pour cette matière
                                      if (moyenneClasse != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Classe : ${moyenneClasse.toStringAsFixed(1)}/20',
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                if (moyenne != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: moyenne >= 10
                                            ? [
                                                const Color(0xFF11998E),
                                                const Color(0xFF38EF7D)
                                              ]
                                            : [
                                                const Color(0xFFFF6B6B),
                                                const Color(0xFFEE0979)
                                              ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${moyenne.toStringAsFixed(1)}/20',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '-/20',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.orange),
                            const SizedBox(width: 10),
                            Text(
                              'Gestion des absences — Bientôt disponible',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

          // ── ONGLET CHATBOT ────────────────────────────────────
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      _messages.length + (_isChatLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isChatLoading && index == _messages.length) {
                      return _buildTypingIndicator();
                    }

                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isUser) ...[
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF11998E),
                                    Color(0xFF38EF7D)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.smart_toy,
                                  color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? const Color(0xFF11998E)
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft:
                                      Radius.circular(isUser ? 16 : 4),
                                  bottomRight:
                                      Radius.circular(isUser ? 4 : 16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                msg['content']!,
                                style: TextStyle(
                                  color: isUser
                                      ? Colors.white
                                      : const Color(0xFF1A2E3B),
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
                  },
                ),
              ),

              if (_messages.length <= 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildSuggestion('Quelle est ma moyenne générale ?'),
                      _buildSuggestion('Ma pire matière ?'),
                      _buildSuggestion('Règlement des absences ?'),
                      _buildSuggestion('Conseils pour progresser ?'),
                    ],
                  ),
                ),

              Container(
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: InputDecoration(
                          hintText: 'Pose ta question...',
                          hintStyle:
                              TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: const Color(0xFFF0F4FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _envoyerMessage(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isChatLoading ? null : _envoyerMessage,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF11998E),
                              Color(0xFF38EF7D)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestion(String text) {
    return GestureDetector(
      onTap: () {
        _chatController.text = text;
        _envoyerMessage();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF11998E).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF11998E).withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF11998E),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF11998E), Color(0xFF38EF7D)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DotAnimation(delay: 0),
                SizedBox(width: 4),
                _DotAnimation(delay: 200),
                SizedBox(width: 4),
                _DotAnimation(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotAnimation extends StatefulWidget {
  final int delay;
  const _DotAnimation({required this.delay});

  @override
  State<_DotAnimation> createState() => _DotAnimationState();
}

class _DotAnimationState extends State<_DotAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF11998E),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}