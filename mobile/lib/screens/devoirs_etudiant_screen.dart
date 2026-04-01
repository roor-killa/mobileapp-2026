import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../services/notification_service.dart';

class DevoirsEtudiantScreen extends StatefulWidget {
  const DevoirsEtudiantScreen({super.key});

  @override
  State<DevoirsEtudiantScreen> createState() =>
      _DevoirsEtudiantScreenState();
}

class _DevoirsEtudiantScreenState extends State<DevoirsEtudiantScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _session = SessionService();
  final NotificationService _notificationService = NotificationService();

  List<Map<String, dynamic>> _devoirs = [];
  List<Map<String, dynamic>> _anciensDevoirs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerDevoirs();
  }

  Future<void> _chargerDevoirs() async {
    final etudiant = _session.etudiantConnecte!;
    if (etudiant.classeId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final devoirs =
          await _apiService.getDevoirsClasse(etudiant.classeId!);

      // Vérifie si de nouveaux devoirs ont été ajoutés
      if (_anciensDevoirs.isNotEmpty) {
        for (final devoir in devoirs) {
          final estNouveau = !_anciensDevoirs
              .any((d) => d['id'] == devoir['id']);
          if (estNouveau) {
            await _notificationService.notifierNouveauDevoir(
              devoir['matiere']['nom'],
              devoir['titre'],
            );
          }
        }
      }

      setState(() {
        _anciensDevoirs = List.from(_devoirs);
        _devoirs = devoirs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getCouleurDelai(String dateLimite) {
    final date = DateTime.parse(dateLimite);
    final diff = date.difference(DateTime.now()).inDays;
    if (diff < 2) return Colors.red;
    if (diff < 5) return Colors.orange;
    return const Color(0xFF11998E);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF11998E)))
        : _session.etudiantConnecte?.classeId == null
            ? const Center(
                child: Text(
                  'Vous n\'êtes assigné à aucune classe.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : _devoirs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun devoir pour le moment',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _chargerDevoirs,
                    color: const Color(0xFF11998E),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _devoirs.length,
                      itemBuilder: (context, index) {
                        final devoir = _devoirs[index];
                        final matiere = devoir['matiere'];
                        final professeur = devoir['professeur'];
                        final couleur =
                            _getCouleurDelai(devoir['date_limite']);
                        final date =
                            DateTime.parse(devoir['date_limite']);
                        final diff =
                            date.difference(DateTime.now()).inDays;

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
                                    color: couleur.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.assignment,
                                      color: couleur),
                                ),
                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        devoir['titre'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.book_outlined,
                                              size: 13,
                                              color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text(
                                            matiere['nom'],
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline,
                                              size: 13,
                                              color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${professeur['prenom']} ${professeur['nom']}',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (devoir['description'] !=
                                          null) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding:
                                              const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            devoir['description'],
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              couleur.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.access_time,
                                                size: 12, color: couleur),
                                            const SizedBox(width: 4),
                                            Text(
                                              diff < 0
                                                  ? 'Expiré !'
                                                  : diff == 0
                                                      ? 'Aujourd\'hui !'
                                                      : diff == 1
                                                          ? 'Demain !'
                                                          : 'Dans $diff jours — ${date.day}/${date.month}/${date.year}',
                                              style: TextStyle(
                                                color: couleur,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
  }
}