import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class EmploiDuTempsScreen extends StatefulWidget {
  const EmploiDuTempsScreen({super.key});

  @override
  State<EmploiDuTempsScreen> createState() => _EmploiDuTempsScreenState();
}

class _EmploiDuTempsScreenState extends State<EmploiDuTempsScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _session = SessionService();

  List<Map<String, dynamic>> _cours = [];
  bool _isLoading = true;
  String _jourSelectionne = 'Lundi';

  final List<String> _jours = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'
  ];

  // Couleurs par matière
  final List<Color> _couleurs = [
    const Color(0xFF6C63FF),
    const Color(0xFF11998E),
    const Color(0xFFFF6B6B),
    const Color(0xFFFF9800),
    const Color(0xFF3B82F6),
    const Color(0xFFE94560),
  ];

  @override
  void initState() {
    super.initState();
    _chargerEmploi();
  }

  Future<void> _chargerEmploi() async {
    final etudiant = _session.etudiantConnecte!;
    if (etudiant.classeId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final cours = await _apiService.getEmploiDuTemps(etudiant.classeId!);
      setState(() {
        _cours = cours;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _coursParJour(String jour) {
    return _cours.where((c) => c['jour'] == jour).toList();
  }

  Color _getCouleur(int matiereId) {
    return _couleurs[(matiereId - 1) % _couleurs.length];
  }

  String _formatHeure(String heure) {
    // Enlève les secondes : "08:00:00" → "08:00"
    return heure.substring(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11998E),
        title: const Text(
          'Emploi du temps',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF11998E)))
          : _session.etudiantConnecte?.classeId == null
              ? const Center(
                  child: Text(
                    'Vous n\'êtes assigné à aucune classe.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    // Sélecteur de jours
                    Container(
                      color: const Color(0xFF11998E),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Row(
                          children: _jours.map((jour) {
                            final isSelected = jour == _jourSelectionne;
                            final nbCours = _coursParJour(jour).length;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _jourSelectionne = jour),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      jour,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF11998E)
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (nbCours > 0) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF11998E)
                                              : Colors.white.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$nbCours',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Liste des cours du jour
                    Expanded(
                      child: _coursParJour(_jourSelectionne).isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_available,
                                      size: 60,
                                      color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Pas de cours le $_jourSelectionne',
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount:
                                  _coursParJour(_jourSelectionne).length,
                              itemBuilder: (context, index) {
                                final cours =
                                    _coursParJour(_jourSelectionne)[index];
                                final matiere = cours['matiere'];
                                final professeur = cours['professeur'];
                                final couleur =
                                    _getCouleur(matiere['id'] as int);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withOpacity(0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Barre colorée à gauche
                                      Container(
                                        width: 6,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: couleur,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            bottomLeft: Radius.circular(16),
                                          ),
                                        ),
                                      ),

                                      // Heure
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        child: Column(
                                          children: [
                                            Text(
                                              _formatHeure(
                                                  cours['heure_debut']),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: couleur,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              width: 1,
                                              height: 20,
                                              color: Colors.grey.shade300,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatHeure(cours['heure_fin']),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Infos cours
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                matiere['nom'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.person_outline,
                                                      size: 14,
                                                      color: Colors
                                                          .grey.shade500),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${professeur['prenom']} ${professeur['nom']}',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (cours['salle'] != null) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(Icons.room_outlined,
                                                        size: 14,
                                                        color: Colors
                                                            .grey.shade500),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      cours['salle'],
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade500,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Badge durée
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 14),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: couleur.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '2h',
                                            style: TextStyle(
                                              color: couleur,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}