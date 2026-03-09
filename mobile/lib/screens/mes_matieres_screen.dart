import 'package:flutter/material.dart';
import '../models/matiere.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

// Écran pour que le professeur choisisse ses matières (max 2)
class MesMatieresScreen extends StatefulWidget {
  const MesMatieresScreen({super.key});

  @override
  State<MesMatieresScreen> createState() => _MesMatieresScreenState();
}

class _MesMatieresScreenState extends State<MesMatieresScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _session = SessionService();

  // Toutes les matières disponibles
  List<Matiere> toutesLesMatieres = [];

  // Ids des matières sélectionnées par le professeur
  List<int> matieresSelectionnees = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  /// Charge toutes les matières et les matières actuelles du prof
  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);
    try {
      final professeurId = _session.professeurConnecte!.id;
      final results = await Future.wait([
        _apiService.getMatieres(),
        _apiService.getMatieresProf(professeurId),
      ]);

      setState(() {
        toutesLesMatieres = results[0] as List<Matiere>;
        // Pré-sélectionne les matières déjà assignées
        matieresSelectionnees =
            (results[1] as List<Matiere>).map((m) => m.id).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Sauvegarde les matières sélectionnées
  Future<void> _sauvegarder() async {
    final professeurId = _session.professeurConnecte!.id;
    final success =
        await _apiService.assignerMatieres(professeurId, matieresSelectionnees);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matières sauvegardées !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sauvegarde'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          'Mes matières',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
          : Column(
              children: [
                // Message d'information
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sélectionnez maximum 2 matières que vous enseignez',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Compteur de matières sélectionnées
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${matieresSelectionnees.length}/2 matières sélectionnées',
                        style: TextStyle(
                          color: matieresSelectionnees.length == 2
                              ? const Color(0xFF6C63FF)
                              : Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Liste des matières
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: toutesLesMatieres.length,
                    itemBuilder: (context, index) {
                      final matiere = toutesLesMatieres[index];
                      final estSelectionnee =
                          matieresSelectionnees.contains(matiere.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: estSelectionnee
                              ? const Color(0xFF6C63FF).withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: estSelectionnee
                                ? const Color(0xFF6C63FF)
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          // Icône livre
                          leading: Icon(
                            Icons.book,
                            color: estSelectionnee
                                ? const Color(0xFF6C63FF)
                                : Colors.grey,
                          ),
                          title: Text(
                            matiere.nom,
                            style: TextStyle(
                              fontWeight: estSelectionnee
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: estSelectionnee
                                  ? const Color(0xFF6C63FF)
                                  : Colors.black,
                            ),
                          ),
                          // Coche si sélectionnée
                          trailing: estSelectionnee
                              ? const Icon(Icons.check_circle,
                                  color: Color(0xFF6C63FF))
                              : const Icon(Icons.circle_outlined,
                                  color: Colors.grey),
                          onTap: () {
                            setState(() {
                              if (estSelectionnee) {
                                // Désélectionne la matière
                                matieresSelectionnees.remove(matiere.id);
                              } else if (matieresSelectionnees.length < 2) {
                                // Sélectionne si moins de 2 déjà choisies
                                matieresSelectionnees.add(matiere.id);
                              } else {
                                // Avertissement si déjà 2 matières choisies
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Maximum 2 matières autorisées !'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Bouton sauvegarder en bas
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _sauvegarder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Sauvegarder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}