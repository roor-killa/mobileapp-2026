import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class DevoirsProfScreen extends StatefulWidget {
  const DevoirsProfScreen({super.key});

  @override
  State<DevoirsProfScreen> createState() => _DevoirsProfScreenState();
}

class _DevoirsProfScreenState extends State<DevoirsProfScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _session = SessionService();

  List<Map<String, dynamic>> _devoirs = [];
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _matieres = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    final prof = _session.professeurConnecte!;
    try {
      final results = await Future.wait([
        _apiService.getDevoirsProfesseur(prof.id),
        _apiService.getClasses(),
        _apiService.getMatieres(),
      ]);
      setState(() {
        _devoirs = results[0] as List<Map<String, dynamic>>;
        _classes = results[1] as List<Map<String, dynamic>>;
        _matieres = (results[2] as dynamic)
            .map<Map<String, dynamic>>((m) => {'id': m.id, 'nom': m.nom})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _ouvrirDialogAjouter() {
    final titreController = TextEditingController();
    final descriptionController = TextEditingController();
    Map<String, dynamic>? classeChoisie;
    Map<String, dynamic>? matiereChoisie;
    DateTime? dateLimite;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text(
            'Nouveau devoir',
            style: TextStyle(
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre
                TextField(
                  controller: titreController,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description (optionnel)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),

                // Classe
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: classeChoisie,
                  decoration: InputDecoration(
                    labelText: 'Classe',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _classes
                      .map((c) => DropdownMenuItem(
                          value: c, child: Text(c['nom'])))
                      .toList(),
                  onChanged: (val) =>
                      setStateDialog(() => classeChoisie = val),
                ),
                const SizedBox(height: 10),

                // Matière
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: matiereChoisie,
                  decoration: InputDecoration(
                    labelText: 'Matière',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _matieres
                      .map((m) => DropdownMenuItem(
                          value: m, child: Text(m['nom'])))
                      .toList(),
                  onChanged: (val) =>
                      setStateDialog(() => matiereChoisie = val),
                ),
                const SizedBox(height: 10),

                // Date limite
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(
                          const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setStateDialog(() => dateLimite = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Color(0xFF6C63FF)),
                        const SizedBox(width: 8),
                        Text(
                          dateLimite == null
                              ? 'Date limite'
                              : '${dateLimite!.day}/${dateLimite!.month}/${dateLimite!.year}',
                          style: TextStyle(
                            color: dateLimite == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titreController.text.isEmpty ||
                    classeChoisie == null ||
                    matiereChoisie == null ||
                    dateLimite == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Remplissez tous les champs'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final prof = _session.professeurConnecte!;
                final dateStr =
                    '${dateLimite!.year}-${dateLimite!.month.toString().padLeft(2, '0')}-${dateLimite!.day.toString().padLeft(2, '0')}';

                final success = await _apiService.creerDevoir({
                  'classe_id': classeChoisie!['id'],
                  'matiere_id': matiereChoisie!['id'],
                  'professeur_id': prof.id,
                  'titre': titreController.text,
                  'description': descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  'date_limite': dateStr,
                });

                if (success) {
                  Navigator.pop(context);
                  _chargerDonnees();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Devoir ajouté !'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de l\'ajout'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
              ),
              child: const Text(
                'Ajouter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmerSuppression(int devoirId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce devoir ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _apiService.supprimerDevoir(devoirId);
              if (success) {
                Navigator.pop(context);
                _chargerDonnees();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Devoir supprimé'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCouleurDelai(String dateLimite) {
    final date = DateTime.parse(dateLimite);
    final diff = date.difference(DateTime.now()).inDays;
    if (diff < 2) return Colors.red;
    if (diff < 5) return Colors.orange;
    return const Color(0xFF6C63FF);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          'Mes devoirs',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _devoirs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun devoir assigné',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _devoirs.length,
                  itemBuilder: (context, index) {
                    final devoir = _devoirs[index];
                    final matiere = devoir['matiere'];
                    final classe = devoir['classe'];
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
                            // Icône matière
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: couleur.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
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
                                  Text(
                                    '${matiere['nom']} • ${classe['nom']}',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (devoir['description'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      devoir['description'],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: couleur.withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      diff == 0
                                          ? 'Aujourd\'hui !'
                                          : diff == 1
                                              ? 'Demain !'
                                              : 'Dans $diff jours',
                                      style: TextStyle(
                                        color: couleur,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Bouton supprimer
                            GestureDetector(
                              onTap: () =>
                                  _confirmerSuppression(devoir['id']),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.delete,
                                    color: Color(0xFFE53935), size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ouvrirDialogAjouter,
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouveau devoir',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}