import 'package:flutter/material.dart';
import '../models/etudiant.dart';
import '../services/api_service.dart';
import 'ajouter_etudiant_screen.dart';
import 'modifier_etudiant_screen.dart';
import 'login_screen.dart';
import 'notes_screen.dart';
import 'mes_matieres_screen.dart'; // Écran pour gérer les matières du prof

class EtudiantsScreen extends StatefulWidget {
  const EtudiantsScreen({super.key});

  @override
  State<EtudiantsScreen> createState() => _EtudiantsScreenState();
}

class _EtudiantsScreenState extends State<EtudiantsScreen> {
  final ApiService _apiService = ApiService();
  List<Etudiant> etudiants = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerEtudiants();
  }

  /// Récupère tous les étudiants depuis l'API Laravel
  Future<void> _chargerEtudiants() async {
    setState(() => _isLoading = true);
    try {
      final liste = await _apiService.getEtudiants().timeout(
        const Duration(seconds: 5),
        onTimeout: () => [],
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
          // Nombre d'étudiants
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Text(
                '${etudiants.length} étudiant(s)',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
          // Bouton pour gérer ses matières
          IconButton(
            icon: const Icon(Icons.book, color: Colors.white),
            tooltip: 'Mes matières',
            onPressed: () {
              // Navigue vers l'écran de gestion des matières
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MesMatieresScreen(),
                ),
              );
            },
          ),
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Se déconnecter',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: etudiants.length,
                  itemBuilder: (context, index) {
                    final etudiant = etudiants[index];

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
                            // Avatar avec les initiales
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6C63FF),
                                    Color(0xFF3B82F6),
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
                                  Text(
                                    '${etudiant.prenom} ${etudiant.nom}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    etudiant.email,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Bouton voir les notes
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NotesScreen(
                                            etudiant: etudiant,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C63FF)
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Voir les notes',
                                        style: TextStyle(
                                          color: Color(0xFF6C63FF),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Boutons modifier et supprimer
                            Column(
                              children: [
                                // Bouton modifier
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
                                // Bouton supprimer
                                GestureDetector(
                                  onTap: () async {
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

      // Bouton + pour ajouter un étudiant
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final nouvelEtudiant = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AjouterEtudiantScreen()),
          );
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