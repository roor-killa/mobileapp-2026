
// PAGE "MOT DE PASSE" — MotDePasseWidget
// Gestionnaire de comptes connecté à Firebase :
//   - Affiche la liste des comptes enregistrés (Firestore)
//   - Permet d'ajouter, modifier ou supprimer un compte
//   - Données propres à chaque utilisateur connecté (Firebase Auth)


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget principal de la page (StatefulWidget car données dynamiques)
class MotDePasseWidget extends StatefulWidget {
  const MotDePasseWidget({super.key});

  // Nom et chemin de la route pour la navigation
  static String routeName = 'Mot_de_Passe';
  static String routePath = '/motDePasse';

  @override
  State<MotDePasseWidget> createState() => _MotDePasseWidgetState();
}

class _MotDePasseWidgetState extends State<MotDePasseWidget> {

  // Instance Firebase Auth — pour récupérer l'utilisateur connecté
  final _auth = FirebaseAuth.instance;

  // Instance Firestore — pour lire/écrire les comptes dans la base de données
  final _firestore = FirebaseFirestore.instance;

  // ============================================================
  // DIALOG : Ajouter ou Modifier un compte
  // Si [compte] est null → mode "Ajouter"
  // Si [compte] est fourni → mode "Modifier" (pré-remplit les champs)
  // ============================================================
  void _afficherDialog({DocumentSnapshot? compte}) {

    // Contrôleurs de texte pré-remplis si on est en mode "Modifier"
    final nomController   = TextEditingController(text: compte?['nom_organisme'] ?? '');
    final emailController = TextEditingController(text: compte?['email'] ?? '');
    final mdpController   = TextEditingController(text: compte?['mot_de_passe'] ?? '');

    // Contrôle la visibilité du mot de passe (œil ouvert/fermé)
    bool mdpVisible = false;

    showDialog(
      context: context,
      // StatefulBuilder permet de mettre à jour l'état DANS le dialog
      // (nécessaire pour le bouton œil du mot de passe)
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          // Titre dynamique selon le mode ajouter ou modifier
          title: Text(compte == null ? 'Ajouter un compte' : 'Modifier'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Le dialog prend le minimum de hauteur
            children: [

              // Champ : Nom de l'organisme
              TextField(
                controller: nomController,
                decoration: _dialogInput("Nom de l'organisme"),
              ),
              const SizedBox(height: 12),

              // Champ : Email (clavier adapté à l'email)
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _dialogInput('Email'),
              ),
              const SizedBox(height: 12),

              // Champ : Mot de passe avec bouton pour afficher/masquer
              TextField(
                controller: mdpController,
                obscureText: !mdpVisible, // Masque le texte si mdpVisible = false
                decoration: _dialogInput('Mot de passe').copyWith(
                  suffixIcon: IconButton(
                    // Icône change selon l'état de visibilité
                    icon: Icon(mdpVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    // setDialogState met à jour l'état à l'intérieur du dialog
                    onPressed: () => setDialogState(() => mdpVisible = !mdpVisible),
                  ),
                ),
              ),
            ],
          ),
          actions: [

            // Bouton Annuler — ferme le dialog sans rien sauvegarder
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),

            // Bouton Ajouter / Enregistrer — sauvegarde dans Firestore
            ElevatedButton(
              onPressed: () async {
                // Validation : les champs nom et email sont obligatoires
                if (nomController.text.isEmpty || emailController.text.isEmpty) return;

                // Récupère l'ID de l'utilisateur connecté
                final userId = _auth.currentUser!.uid;

                // Prépare les données à enregistrer
                final data = {
                  'nom_organisme': nomController.text,
                  'email':         emailController.text,
                  'mot_de_passe':  mdpController.text,
                  'user_id':       userId,
                };

                if (compte == null) {
                  // MODE AJOUTER : crée un nouveau document dans la sous-collection "comptes"
                  await _firestore
                      .collection('users')
                      .doc(userId)
                      .collection('comptes')
                      .add(data);
                } else {
                  // MODE MODIFIER : met à jour le document existant
                  await compte.reference.update(data);
                }

                // Ferme le dialog après la sauvegarde
                Navigator.pop(context);
              },
              // Texte du bouton dynamique selon le mode
              child: Text(compte == null ? 'Ajouter' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DIALOG : Confirmation de suppression d'un compte
  // Demande confirmation avant de supprimer définitivement
  // ============================================================
  void _supprimerCompte(DocumentSnapshot compte) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        // Affiche le nom de l'organisme dans le message de confirmation
        content: Text('Supprimer le compte "${compte['nom_organisme']}" ?'),
        actions: [

          // Bouton Annuler — ferme sans supprimer
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),

          // Bouton Supprimer — supprime le document Firestore
          TextButton(
            onPressed: () async {
              await compte.reference.delete(); // Suppression dans Firestore
              Navigator.pop(context);
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: Theme.of(context).colorScheme.error), // Texte rouge
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UTILITAIRE : Style commun pour les champs texte du dialog
  // Retourne une InputDecoration avec bordure arrondie
  // ============================================================
  InputDecoration _dialogInput(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );

  // ============================================================
  // BUILD : Construction de l'interface
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final userId = _auth.currentUser?.uid; // null si l'utilisateur n'est pas connecté

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [

            // ── ZONE PRINCIPALE SCROLLABLE ─────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Titre de la page en rouge (couleur error du thème)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 50, 0, 0),
                      child: Text(
                        'Mot de passe',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: cs.error, // Rouge
                        ),
                      ),
                    ),

                    // Sous-titre "Tous les comptes" + bouton "+" pour ajouter
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 22, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 21),
                            child: Text(
                              'Tous les comptes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          // Bouton "+" — ouvre le dialog d'ajout
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: IconButton(
                              onPressed: () => _afficherDialog(),
                              icon: Icon(
                                Icons.add_rounded,
                                color: cs.onSurface.withOpacity(0.6),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── LISTE DES COMPTES (temps réel via Firestore) ──
                    Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: userId == null

                          // Si l'utilisateur n'est pas connecté
                          ? const Center(child: Text('Non connecté'))

                          // StreamBuilder écoute les changements Firestore en temps réel
                          : StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('users')
                                  .doc(userId)
                                  .collection('comptes') // Sous-collection propre à l'utilisateur
                                  .snapshots(),          // .snapshots() = écoute en temps réel
                              builder: (context, snapshot) {

                                // Chargement en cours
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(color: cs.primary),
                                  );
                                }

                                // Aucun compte enregistré — affiche un état vide
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 60),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.lock_outline,
                                            size: 64,
                                            color: cs.onSurface.withOpacity(0.3),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Aucun compte enregistré',
                                            style: TextStyle(
                                              color: cs.onSurface.withOpacity(0.5),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                // Données disponibles — récupère la liste des documents
                                final comptes = snapshot.data!.docs;

                                // Construit une carte par compte
                                return ListView.builder(
                                  shrinkWrap: true,           // S'adapte à la hauteur du contenu
                                  physics: const NeverScrollableScrollPhysics(), // Scroll géré par le parent
                                  itemCount: comptes.length,
                                  itemBuilder: (context, index) {
                                    final compte = comptes[index];

                                    return Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          // ── CARTE D'UN COMPTE ──────────────────
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.9, // 90% de la largeur
                                            decoration: BoxDecoration(
                                              color: cs.surfaceContainerHighest, // Fond légèrement coloré
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [

                                                  // Infos du compte (nom + email)
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        // Nom de l'organisme
                                                        Text(
                                                          compte['nom_organisme'],
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        // Email (légèrement transparent)
                                                        Text(
                                                          compte['email'],
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: cs.onSurface.withOpacity(0.6),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Boutons d'action : Modifier + Supprimer
                                                  Row(
                                                    children: [

                                                      // Bouton Modifier (orange)
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 8),
                                                        child: IconButton(
                                                          onPressed: () => _afficherDialog(compte: compte),
                                                          style: IconButton.styleFrom(
                                                            backgroundColor: const Color(0xFFFFF3E0), // Fond orange clair
                                                            shape: const CircleBorder(),
                                                          ),
                                                          icon: const Icon(
                                                            Icons.edit_outlined,
                                                            color: Color(0xFFFF6F00), // Icône orange foncé
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),

                                                      // Bouton Supprimer (rouge)
                                                      IconButton(
                                                        onPressed: () => _supprimerCompte(compte),
                                                        style: IconButton.styleFrom(
                                                          backgroundColor: const Color(0xFFFFEBEE), // Fond rouge clair
                                                          shape: const CircleBorder(),
                                                        ),
                                                        icon: Icon(
                                                          Icons.delete_outline,
                                                          color: cs.error, // Icône rouge
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // ── BARRE DE NAVIGATION EN BAS ─────────────────
            // Fixée en bas avec une légère ombre vers le haut
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [
                  BoxShadow(
                    color: cs.onSurface.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2), // Ombre vers le haut
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Bouton Accueil
                  IconButton(
                    icon: Icon(Icons.home_outlined, color: cs.onSurface.withOpacity(0.6)),
                    onPressed: () => Navigator.pushNamed(context, '/accueil'),
                  ),
                  // Bouton Mot de passe (page actuelle — icône colorée)
                  IconButton(
                    icon: Icon(Icons.lock_outlined, color: cs.primary),
                    onPressed: () {}, // Aucune action (déjà sur cette page)
                  ),
                  // Bouton Paramètres
                  IconButton(
                    icon: Icon(Icons.settings, color: cs.onSurface.withOpacity(0.6)),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}