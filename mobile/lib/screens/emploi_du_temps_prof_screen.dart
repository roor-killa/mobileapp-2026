import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class EmploiDuTempsProfScreen extends StatefulWidget {
  const EmploiDuTempsProfScreen({super.key});

  @override
  State<EmploiDuTempsProfScreen> createState() =>
      _EmploiDuTempsProfScreenState();
}

class _EmploiDuTempsProfScreenState extends State<EmploiDuTempsProfScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _session = SessionService();

  List<Map<String, dynamic>> _cours = [];
  bool _isLoading = true;
  String _jourSelectionne = 'Lundi';

  final List<String> _jours = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'
  ];

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
    final prof = _session.professeurConnecte!;
    try {
      final cours = await _apiService.getEmploiDuTempsProfesseur(prof.id);
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
    return heure.substring(0, 5);
  }

  void _declarerPresence(Map<String, dynamic> cours) {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    String statut = 'present';
    final motifController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(
            '${cours['matiere']['nom']}',
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date : $dateStr',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              const Text(
                'Votre statut pour ce cours :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setStateDialog(() => statut = 'present'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: statut == 'present'
                              ? const Color(0xFF11998E)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Présent',
                            style: TextStyle(
                              color: statut == 'present'
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setStateDialog(() => statut = 'absent'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: statut == 'absent'
                              ? Colors.red
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Absent',
                            style: TextStyle(
                              color: statut == 'absent'
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (statut == 'absent') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: motifController,
                  decoration: InputDecoration(
                    labelText: 'Motif d\'absence (optionnel)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final prof = _session.professeurConnecte!;
                await _apiService.declarerPresence(
                  cours['id'] as int,
                  prof.id,
                  dateStr,
                  statut,
                  motif: motifController.text.isEmpty
                      ? null
                      : motifController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(statut == 'present'
                        ? 'Présence déclarée ✅'
                        : 'Absence déclarée'),
                    backgroundColor: statut == 'present'
                        ? Colors.green
                        : Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
              ),
              child: const Text(
                'Confirmer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          'Mon emploi du temps',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : Column(
              children: [
                // Sélecteur de jours
                Container(
                  color: const Color(0xFF6C63FF),
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
                                        ? const Color(0xFF6C63FF)
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
                                          ? const Color(0xFF6C63FF)
                                          : Colors.white.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$nbCours',
                                        style: const TextStyle(
                                          color: Colors.white,
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
                                  size: 60, color: Colors.grey.shade300),
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
                          itemCount: _coursParJour(_jourSelectionne).length,
                          itemBuilder: (context, index) {
                            final cours =
                                _coursParJour(_jourSelectionne)[index];
                            final matiere = cours['matiere'];
                            final classe = cours['classe'];
                            final couleur =
                                _getCouleur(matiere['id'] as int);

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
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: couleur,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    child: Column(
                                      children: [
                                        Text(
                                          _formatHeure(cours['heure_debut']),
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
                                              Icon(Icons.class_,
                                                  size: 14,
                                                  color: Colors.grey.shade500),
                                              const SizedBox(width: 4),
                                              Text(
                                                classe['nom'],
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
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
                                                    color: Colors.grey.shade500),
                                                const SizedBox(width: 4),
                                                Text(
                                                  cours['salle'],
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
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

                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: GestureDetector(
                                      onTap: () => _declarerPresence(cours),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: couleur.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color:
                                                  couleur.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          'Présence',
                                          style: TextStyle(
                                            color: couleur,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
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