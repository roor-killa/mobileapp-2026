import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EmploiDuTempsAdminScreen extends StatefulWidget {
  const EmploiDuTempsAdminScreen({super.key});

  @override
  State<EmploiDuTempsAdminScreen> createState() =>
      _EmploiDuTempsAdminScreenState();
}

class _EmploiDuTempsAdminScreenState
    extends State<EmploiDuTempsAdminScreen> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _professeurs = [];
  List<Map<String, dynamic>> _matieres = [];
  List<Map<String, dynamic>> _cours = [];

  Map<String, dynamic>? _classeSelectionnee;
  bool _isLoading = true;
  bool _isLoadingCours = false;
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
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    try {
      final results = await Future.wait([
        _apiService.getClasses(),
        _apiService.getProfesseurs(),
        _apiService.getMatieres(),
      ]);
      setState(() {
        _classes = results[0] as List<Map<String, dynamic>>;
        _professeurs = (results[1] as dynamic)
            .map<Map<String, dynamic>>((p) => {
                  'id': p.id,
                  'nom': p.nom,
                  'prenom': p.prenom,
                })
            .toList();
        _matieres = (results[2] as dynamic)
            .map<Map<String, dynamic>>((m) => {
                  'id': m.id,
                  'nom': m.nom,
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _chargerCours(int classeId) async {
    setState(() => _isLoadingCours = true);
    try {
      final cours = await _apiService.getEmploiDuTemps(classeId);
      setState(() {
        _cours = cours;
        _isLoadingCours = false;
      });
    } catch (e) {
      setState(() => _isLoadingCours = false);
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

  void _ouvrirDialogAjouter() {
    if (_classeSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez une classe d\'abord'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? jourChoisi = _jourSelectionne;
    Map<String, dynamic>? matiereChoisie;
    Map<String, dynamic>? professeurChoisi;
    final heureDebutController = TextEditingController(text: '08:00');
    final heureFinController = TextEditingController(text: '10:00');
    final salleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text(
            'Ajouter un créneau',
            style: TextStyle(
              color: Color(0xFFE94560),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Jour
                DropdownButtonFormField<String>(
                  value: jourChoisi,
                  decoration: InputDecoration(
                    labelText: 'Jour',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _jours
                      .map((j) =>
                          DropdownMenuItem(value: j, child: Text(j)))
                      .toList(),
                  onChanged: (val) =>
                      setStateDialog(() => jourChoisi = val),
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

                // Professeur
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: professeurChoisi,
                  decoration: InputDecoration(
                    labelText: 'Professeur',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _professeurs
                      .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                              '${p['prenom']} ${p['nom']}')))
                      .toList(),
                  onChanged: (val) =>
                      setStateDialog(() => professeurChoisi = val),
                ),
                const SizedBox(height: 10),

                // Heure début
                TextField(
                  controller: heureDebutController,
                  decoration: InputDecoration(
                    labelText: 'Heure début (ex: 08:00)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),

                // Heure fin
                TextField(
                  controller: heureFinController,
                  decoration: InputDecoration(
                    labelText: 'Heure fin (ex: 10:00)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),

                // Salle
                TextField(
                  controller: salleController,
                  decoration: InputDecoration(
                    labelText: 'Salle (optionnel)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
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
                if (matiereChoisie == null || professeurChoisi == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Remplissez tous les champs'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final success = await _apiService.creerCreneau({
                  'classe_id': _classeSelectionnee!['id'],
                  'matiere_id': matiereChoisie!['id'],
                  'professeur_id': professeurChoisi!['id'],
                  'jour': jourChoisi,
                  'heure_debut': heureDebutController.text,
                  'heure_fin': heureFinController.text,
                  'salle': salleController.text.isEmpty
                      ? null
                      : salleController.text,
                });

                if (success) {
                  Navigator.pop(context);
                  _chargerCours(_classeSelectionnee!['id'] as int);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Créneau ajouté !'),
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
                backgroundColor: const Color(0xFFE94560),
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

  void _confirmerSuppression(int coursId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce créneau ?'),
        content: const Text(
            'Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _apiService.supprimerCreneau(coursId);
              if (success) {
                Navigator.pop(context);
                _chargerCours(_classeSelectionnee!['id'] as int);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Créneau supprimé'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Emploi du temps',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE94560)))
          : Column(
              children: [
                // Sélection classe
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<Map<String, dynamic>>(
                    value: _classeSelectionnee,
                    decoration: InputDecoration(
                      labelText: 'Sélectionner une classe',
                      prefixIcon: const Icon(Icons.class_,
                          color: Color(0xFFE94560)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _classes
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c['nom'])))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _classeSelectionnee = val);
                      if (val != null)
                        _chargerCours(val['id'] as int);
                    },
                  ),
                ),

                if (_classeSelectionnee != null) ...[
                  // Sélecteur de jours
                  Container(
                    color: const Color(0xFF1A1A2E),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Row(
                        children: _jours.map((jour) {
                          final isSelected = jour == _jourSelectionne;
                          final nbCours = _coursParJour(jour).length;
                          return GestureDetector(
                            onTap: () => setState(
                                () => _jourSelectionne = jour),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE94560)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    jour,
                                    style: const TextStyle(
                                      color: Colors.white,
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
                                        color: Colors.white
                                            .withOpacity(0.3),
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

                  // Liste des cours
                  Expanded(
                    child: _isLoadingCours
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFE94560)))
                        : _coursParJour(_jourSelectionne).isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
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
                                    _coursParJour(_jourSelectionne)
                                        .length,
                                itemBuilder: (context, index) {
                                  final cours = _coursParJour(
                                      _jourSelectionne)[index];
                                  final matiere = cours['matiere'];
                                  final professeur =
                                      cours['professeur'];
                                  final couleur = _getCouleur(
                                      matiere['id'] as int);

                                  return Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.06),
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
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft:
                                                  Radius.circular(16),
                                              bottomLeft:
                                                  Radius.circular(16),
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14),
                                          child: Column(
                                            children: [
                                              Text(
                                                _formatHeure(
                                                    cours['heure_debut']),
                                                style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 14,
                                                  color: couleur,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                width: 1,
                                                height: 20,
                                                color:
                                                    Colors.grey.shade300,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatHeure(
                                                    cours['heure_fin']),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Expanded(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 14),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  matiere['nom'],
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                        Icons.person_outline,
                                                        size: 14,
                                                        color: Colors
                                                            .grey.shade500),
                                                    const SizedBox(
                                                        width: 4),
                                                    Text(
                                                      '${professeur['prenom']} ${professeur['nom']}',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade500,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (cours['salle'] !=
                                                    null) ...[
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          Icons.room_outlined,
                                                          size: 14,
                                                          color: Colors
                                                              .grey.shade500),
                                                      const SizedBox(
                                                          width: 4),
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

                                        // Bouton supprimer
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 12),
                                          child: GestureDetector(
                                            onTap: () =>
                                                _confirmerSuppression(
                                                    cours['id'] as int),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                    0xFFFFEBEE),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                              ),
                                              child: const Icon(
                                                  Icons.delete,
                                                  color: Color(0xFFE53935),
                                                  size: 20),
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
              ],
            ),
      floatingActionButton: _classeSelectionnee != null
          ? FloatingActionButton.extended(
              onPressed: _ouvrirDialogAjouter,
              backgroundColor: const Color(0xFFE94560),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Ajouter un créneau',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}