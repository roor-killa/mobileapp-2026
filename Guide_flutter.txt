# Mon Application Flutter

Bienvenue sur le dépôt de mon application mobile développée avec **Flutter**.  
Ce projet est une démonstration technique incluant une interface utilisateur moderne et réactive.

## Démarrage rapide

### Pré-requis
Assurez-vous d’avoir installé le **Flutter SDK** sur votre machine.

### 1) Cloner le projet
```bash
git clone <votre-lien-repo-git>
cd mon_app_bonjour

2) Installer les dépendances
flutter pub get

3) Lancer l'application
Assurez-vous d’avoir un émulateur ouvert ou un téléphone connecté, puis lancez :
flutter run

Contrôles en cours d’exécution
Une fois l’application lancée dans le terminal, utilisez ces touches :

| Touche | Action      | Description                                      |
| ------ | ----------- | ------------------------------------------------ |
| r      | Hot Reload  | Met à jour l'UI rapidement sans redémarrer l'app |
| R      | Hot Restart | Redémarre l'app depuis zéro                      |
| q      | Quitter     | Arrête l'exécution                               |

Commandes essentielles
Nettoyer le projet (en cas de bug)
Si le projet refuse de compiler ou se comporte bizarrement, lancez ce “combo” :

flutter clean
flutter pub get
flutter run

Vérifier l’environnement
Pour vérifier que tout est bien installé (Android Studio, SDK, etc.) :
flutter create mon_nouveau_projet

Configuration émulateur (Android)
Si aucun appareil n’est détecté (“No device found”) :

1. Ouvrez Android Studio.

2. Allez dans Virtual Device Manager (ou Device Manager).

3. Créez un nouveau device (ex: Pixel 6).

4. Lancez-le avec le bouton Play (▶).

5. Réessayez :
flutter run


Structure des fichiers
- lib/ : Contient tout le code source Dart.

- lib/main.dart : Point d’entrée de l’application.

- pubspec.yaml : Gestion des dépendances (librairies) et assets (images/polices).

- android/ : Code natif Android.

- ios/ : Code natif iOS.

- test/ : Tests unitaires et tests de widgets.
