import 'package:flutter/material.dart';
import '../models/professeur.dart';
import '../models/matiere.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'login_screen.dart';
import 'emploi_du_temps_admin_screen.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _session = SessionService();

  List<Professeur> professeurs = [];
  List<Matiere> matieres = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.getProfesseurs(),
        _apiService.getMatieres(),
      ]);
      setState(() {
        professeurs = results[0] as List<Professeur>;
        matieres = results[1] as List<Matiere>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _ouvrirDialogCreerProfesseur() {
    final nomController = TextEditingController();
    final prenomController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    List<int> matieresSelectionnees = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text(
            'Créer un professeur',
            style: TextStyle(
              color: Color(0xFFE94560),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(
                    controller: prenomController, label: 'Prénom'),
                const SizedBox(height: 10),
                _buildDialogField(controller: nomController, label: 'Nom'),
                const SizedBox(height: 10),
                _buildDialogField(
                    controller: emailController,
                    label: 'Email',
                    type: TextInputType.emailAddress),
                const SizedBox(height: 10),
                _buildDialogField(
                    controller: passwordController,
                    label: 'Mot de passe',
                    obscure: true),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Matières assignées (max 2) :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ...matieres.map((matiere) {
                  final estSelectionnee =
                      matieresSelectionnees.contains(matiere.id);
                  return CheckboxListTile(
                    title: Text(matiere.nom),
                    value: estSelectionnee,
                    activeColor: const Color(0xFFE94560),
                    onChanged: (val) {
                      setStateDialog(() {
                        if (val == true) {
                          if (matieresSelectionnees.length < 2) {
                            matieresSelectionnees.add(matiere.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Maximum 2 matières autorisées !'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        } else {
                          matieresSelectionnees.remove(matiere.id);
                        }
                      });
                    },
                  );
                }),
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
                if (nomController.text.isEmpty ||
                    prenomController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Remplissez tous les champs'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final success = await _apiService.creerProfesseur(
                  nomController.text,
                  prenomController.text,
                  emailController.text,
                  passwordController.text,
                  matieresSelectionnees,
                );

                if (success) {
                  Navigator.pop(context);
                  _chargerDonnees();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Professeur créé avec succès !'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de la création'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
              ),
              child: const Text(
                'Créer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ouvrirDialogModifierMatieres(Professeur professeur) {
    List<int> matieresSelectionnees =
        professeur.matieres.map((m) => m.id).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(
            'Matières de ${professeur.prenom} ${professeur.nom}',
            style: const TextStyle(
              color: Color(0xFFE94560),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Sélectionnez max 2 matières :'),
                const SizedBox(height: 8),
                ...matieres.map((matiere) {
                  final estSelectionnee =
                      matieresSelectionnees.contains(matiere.id);
                  return CheckboxListTile(
                    title: Text(matiere.nom),
                    value: estSelectionnee,
                    activeColor: const Color(0xFFE94560),
                    onChanged: (val) {
                      setStateDialog(() {
                        if (val == true) {
                          if (matieresSelectionnees.length < 2) {
                            matieresSelectionnees.add(matiere.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Maximum 2 matières autorisées !'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        } else {
                          matieresSelectionnees.remove(matiere.id);
                        }
                      });
                    },
                  );
                }),
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
                final success =
                    await _apiService.modifierMatieresProfesseur(
                  professeur.id,
                  matieresSelectionnees,
                );
                if (success) {
                  Navigator.pop(context);
                  _chargerDonnees();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Matières mises à jour !'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
              ),
              child: const Text(
                'Sauvegarder',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmerSuppression(Professeur professeur) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le professeur'),
        content: Text(
          'Voulez-vous vraiment supprimer ${professeur.prenom} ${professeur.nom} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success =
                  await _apiService.supprimerProfesseur(professeur.id);
              if (success) {
                Navigator.pop(context);
                _chargerDonnees();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Professeur supprimé'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    TextInputType type = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE94560), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tableau de bord',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            Text(
              'Admin : ${_session.adminConnecte?.prenom} ${_session.adminConnecte?.nom}',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
        actions: [
          // Bouton emploi du temps
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            tooltip: 'Emploi du temps',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const EmploiDuTempsAdminScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Se déconnecter',
            onPressed: () {
              _session.deconnecterAdmin();
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
              child: CircularProgressIndicator(color: Color(0xFFE94560)),
            )
          : professeurs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_outlined,
                          size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun professeur',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: professeurs.length,
                  itemBuilder: (context, index) {
                    final professeur = professeurs[index];

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
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE94560),
                                    Color(0xFFFF6B6B)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  '${professeur.prenom[0]}${professeur.nom[0]}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${professeur.prenom} ${professeur.nom}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    professeur.email,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  professeur.matieres.isEmpty
                                      ? Text(
                                          'Aucune matière assignée',
                                          style: TextStyle(
                                            color: Colors.orange.shade400,
                                            fontSize: 12,
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 4,
                                          children: professeur.matieres
                                              .map((m) => Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xFFE94560)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Text(
                                                      m.nom,
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFFE94560),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                ],
                              ),
                            ),

                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _ouvrirDialogModifierMatieres(professeur),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.book,
                                        color: Color(0xFFFF9800), size: 20),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () =>
                                      _confirmerSuppression(professeur),
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ouvrirDialogCreerProfesseur,
        backgroundColor: const Color(0xFFE94560),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Nouveau professeur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}