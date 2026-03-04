import 'package:flutter/material.dart';
import '../models/etudiant.dart';
import '../services/api_service.dart';
import 'ajouter_etudiant_screen.dart'; // Import écran ajout
import 'modifier_etudiant_screen.dart'; // Import écran modification
import 'login_screen.dart'; // Import écran login pour la déconnexion

class EtudiantsScreen extends StatefulWidget {
  const EtudiantsScreen({super.key});

  @override
  State<EtudiantsScreen> createState() => _EtudiantsScreenState();
}

class _EtudiantsScreenState extends State<EtudiantsScreen> {
  // Service pour communiquer avec l'API Laravel
  final ApiService _apiService = ApiService();

  // Liste des étudiants affichés à l'écran
  List<Etudiant> etudiants = [];

  // true = spinner de chargement affiché
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Charge les étudiants dès que l'écran s'ouvre
    _chargerEtudiants();
  }

  /// Récupère tous les étudiants depuis l'API Laravel
  Future<void> _chargerEtudiants() async {
    setState(() => _isLoading = true);
    try {
      final liste = await _apiService.getEtudiants().timeout(
        const Duration(seconds: 5),
        onTimeout: () => [], // Retourne liste vide si timeout
      );
      setState(() {
        etudiants = liste;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          'Étudiants',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Nombre d'étudiants affiché en haut à droite
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '${etudiants.length} étudiant(s)',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Se déconnecter',
            onPressed: () {
              // Retourne au login et efface tout l'historique de navigation
              // Le professeur ne peut plus revenir en arrière avec le bouton retour
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      // Affiche un spinner si chargement en cours
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
          // Affiche un message si aucun étudiant
          : etudiants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined,
                          size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun étudiant',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              // Affiche la liste des étudiants
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: etudiants.length,
                  itemBuilder: (context, index) {
                    final etudiant = etudiants[index];
                    // Vert si note >= 10, rouge sinon
                    final bool bonneNote = etudiant.note >= 10;

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
                            // Avatar avec les initiales de l'étudiant
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: bonneNote
                                      ? [
                                          const Color(0xFF43E97B),
                                          const Color(0xFF38F9D7),
                                        ]
                                      : [
                                          const Color(0xFFFF6B6B),
                                          const Color(0xFFFFE66D),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  '${etudiant.prenom[0]}${etudiant.nom[0]}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Informations de l'étudiant
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nom complet
                                  Text(
                                    '${etudiant.prenom} ${etudiant.nom}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Email
                                  Text(
                                    etudiant.email,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Badge de note coloré
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: bonneNote
                                          ? const Color(0xFF43E97B)
                                              .withOpacity(0.15)
                                          : const Color(0xFFFF6B6B)
                                              .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${etudiant.note}/20',
                                      style: TextStyle(
                                        color: bonneNote
                                            ? const Color(0xFF2ECC71)
                                            : const Color(0xFFE74C3C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Boutons modifier et supprimer
                            Column(
                              children: [
                                // Bouton modifier (crayon orange)
                                GestureDetector(
                                  onTap: () async {
                                    final etudiantModifie =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ModifierEtudiantScreen(
                                                etudiant: etudiant),
                                      ),
                                    );
                                    // Si modifications sauvegardées, on recharge la liste
                                    if (etudiantModifie != null) {
                                      await _apiService
                                          .updateEtudiant(etudiantModifie);
                                      _chargerEtudiants();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.edit,
                                        color: Color(0xFFFF9800), size: 20),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Bouton supprimer (poubelle rouge)
                                GestureDetector(
                                  onTap: () async {
                                    // Supprime l'étudiant via l'API puis recharge la liste
                                    await _apiService
                                        .deleteEtudiant(etudiant.id!);
                                    _chargerEtudiants();
                                  },
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
                          ],
                        ),
                      ),
                    );
                  },
                ),

      // Bouton + en bas à droite pour ajouter un étudiant
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final nouvelEtudiant = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AjouterEtudiantScreen()),
          );
          // Si étudiant ajouté, on l'envoie à l'API et on recharge la liste
          if (nouvelEtudiant != null) {
            await _apiService.addEtudiant(nouvelEtudiant);
            _chargerEtudiants();
          }
        },
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}