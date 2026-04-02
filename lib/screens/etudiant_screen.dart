
// PAGE D'ACCUEIL — HomeWidget
// Affiche une page de bienvenue animée avec :
//   - Un fond dégradé avec une icône cadenas
//   - Un texte de bienvenue animé
//   - Un bouton "Commencez !" qui redirige vers la connexion

 
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
 
// Modèle de données de la page (vide pour l'instant, extensible plus tard)
class HomeModel {
  void dispose() {}
}
 
// Fonction utilitaire pour créer et retourner un modèle
HomeModel createModel(BuildContext context, HomeModel Function() builder) {
  return builder();
}
 
// Widget principal de la page d'accueil (StatefulWidget car il contient des animations)
class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});
 
  // Nom et chemin de la route pour la navigation
  static String routeName = 'Home';
  static String routePath = '/home';
 
  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}
 
// État du widget — gère les animations avec TickerProviderStateMixin
class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
 
  late HomeModel _model;
 
  // ─── Contrôleurs d'animation ───────────────────────────────
  // Chaque contrôleur gère le timing d'une animation
  late AnimationController _containerController; // Animation du fond/conteneur
  late AnimationController _text1Controller;     // Animation du titre "Bonjour!"
  late AnimationController _text2Controller;     // Animation du texte descriptif
  late AnimationController _rowController;       // Animation du bouton
 
  // ─── Animations du conteneur principal ────────────────────
  late Animation<double> _containerFade;  // Fondu : de invisible (0) à visible (1)
  late Animation<double> _containerScale; // Zoom : de grande taille (3x) à normale (1x)
 
  // ─── Animations du titre "Bonjour!" ───────────────────────
  late Animation<double> _text1Fade;    // Fondu : de invisible à visible
  late Animation<Offset> _text1Slide;  // Glissement : du bas vers la position finale
 
  // ─── Animations du texte descriptif ───────────────────────
  late Animation<double> _text2Fade;    // Fondu : de invisible à visible
  late Animation<Offset> _text2Slide;  // Glissement : du bas vers la position finale
 
  // ─── Animations du bouton ─────────────────────────────────
  late Animation<double> _rowFade;    // Fondu : de invisible à visible
  late Animation<double> _rowScale;  // Zoom avec effet rebond (bounceOut)
 
  @override
  void initState() {
    super.initState();
 
    // Création du modèle de données
    _model = createModel(context, () => HomeModel());
 
    // ── Animation 1 : Conteneur principal ──────────────────
    // Durée : 400ms — fondu + zoom arrière depuis 3x jusqu'à taille normale
    _containerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _containerFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _containerController, curve: Curves.easeInOut));
    _containerScale = Tween<double>(begin: 3.0, end: 1.0)
        .animate(CurvedAnimation(parent: _containerController, curve: Curves.easeInOut));
 
    // ── Animation 2 : Titre "Bonjour!" ─────────────────────
    // Durée : 400ms — apparition en fondu + glissement vers le haut
    _text1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _text1Fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _text1Controller, curve: Curves.easeInOut));
    _text1Slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _text1Controller, curve: Curves.easeInOut));
 
    // ── Animation 3 : Texte descriptif ─────────────────────
    // Durée : 400ms — même effet que le titre, décalé légèrement
    _text2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _text2Fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _text2Controller, curve: Curves.easeInOut));
    _text2Slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _text2Controller, curve: Curves.easeInOut));
 
    // ── Animation 4 : Bouton "Commencez !" ─────────────────
    // Durée : 600ms — fondu + zoom avec effet rebond (bounce)
    _rowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _rowFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _rowController, curve: Curves.easeInOut));
    _rowScale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _rowController, curve: Curves.bounceOut));
 
    // ── Séquence d'animations au chargement ────────────────
    // addPostFrameCallback attend que le premier rendu soit terminé
    // avant de lancer les animations les unes après les autres
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _containerController.forward();                        // t=0ms    : fond apparaît
      await Future.delayed(const Duration(milliseconds: 350));
      _text1Controller.forward();                            // t=350ms  : "Bonjour!" apparaît
      await Future.delayed(const Duration(milliseconds: 50));
      _text2Controller.forward();                            // t=400ms  : texte descriptif apparaît
      await Future.delayed(const Duration(milliseconds: 300));
      _rowController.forward();                              // t=700ms  : bouton apparaît
    });
  }
 
  @override
  void dispose() {
    // Libération des ressources quand on quitte la page
    // (important pour éviter les fuites mémoire)
    _model.dispose();
    _containerController.dispose();
    _text1Controller.dispose();
    _text2Controller.dispose();
    _rowController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    // Récupère les couleurs du thème actuel (clair/sombre)
    final cs = Theme.of(context).colorScheme;
 
    return GestureDetector(
      // Ferme le clavier si l'utilisateur tape en dehors d'un champ texte
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: cs.surface, // Couleur de fond selon le thème
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espace entre haut et bas
          children: [
 
            // ── ZONE HAUTE : icône + textes animés ─────────
            Expanded(
              child: FadeTransition(
                opacity: _containerFade, // Fondu du conteneur
                child: ScaleTransition(
                  scale: _containerScale, // Zoom arrière du conteneur
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // Dégradé du haut (transparent) vers le bas (couleur du thème)
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0), cs.surface],
                        stops: const [0, 1],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
 
                        // Icône cadenas — symbole de sécurité/connexion
                        Icon(Icons.lock_rounded, size: 100, color: cs.primary),
 
                        // Titre "Bonjour!" — animé en fondu + glissement
                        Padding(
                          padding: const EdgeInsets.only(top: 44),
                          child: FadeTransition(
                            opacity: _text1Fade,
                            child: SlideTransition(
                              position: _text1Slide,
                              child: Text(
                                'Bonjour!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
 
                        // Texte descriptif — animé en fondu + glissement
                        Padding(
                          padding: const EdgeInsets.fromLTRB(43, 8, 43, 0),
                          child: FadeTransition(
                            opacity: _text2Fade,
                            child: SlideTransition(
                              position: _text2Slide,
                              child: Text(
                                'Merci de nous rejoindre ! Accédez à votre compte ou créez-en un nouveau.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: cs.onSurface.withOpacity(0.6), // Légèrement transparent
                                ),
                              ),
                            ),
                          ),
                        ),
 
                      ],
                    ),
                  ),
                ),
              ),
            ),
 
            // ── ZONE BASSE : bouton "Commencez !" ──────────
            // Animé en fondu + zoom avec effet rebond
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 44),
              child: FadeTransition(
                opacity: _rowFade,
                child: ScaleTransition(
                  scale: _rowScale,
                  child: SizedBox(
                    width: 230,
                    height: 52,
                    child: ElevatedButton(
                      // Redirige vers la page de connexion au clic
                      onPressed: () => Navigator.pushNamed(context, '/page-de-connexion'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,           // Couleur principale du thème
                        foregroundColor: Colors.white,         // Texte blanc
                        elevation: 3,                          // Légère ombre portée
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Coins arrondis
                        ),
                      ),
                      child: const Text(
                        'Commencez !',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ),
 
          ],
        ),
      ),
    );
  }
}