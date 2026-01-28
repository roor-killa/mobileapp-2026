# 📱 Mon Application Flutter

Bienvenue sur le dépôt de mon application mobile développée avec **Flutter**.  
Ce projet est une démonstration technique incluant une interface utilisateur moderne et réactive.

---

## 🚀 Démarrage rapide

### 🔧 Pré-requis
Assurez-vous d’avoir installé le **Flutter SDK** sur votre machine.

---

## 📥 Installation

### 1️⃣ Cloner le projet
```bash
git clone <votre-lien-repo-git>
cd mon_app_bonjour

2️⃣ Installer les dépendances : flutter pub get

3️⃣ Lancer l’application
Assurez-vous d’avoir un émulateur ouvert ou un téléphone connecté :
flutter run

⌨️ Contrôles en cours d’exécution

Une fois l’application lancée dans le terminal :
| Touche | Action      | Description                                   |
| -----: | ----------- | --------------------------------------------- |
|      r | Hot Reload  | Met à jour l'UI sans redémarrer l'application |
|      R | Hot Restart | Redémarre l'app depuis zéro                   |
|      q | Quitter     | Arrête l'exécution                            |

🧰 Commandes essentielles
Nettoyer le projet (en cas de bug)

Si le projet refuse de compiler ou se comporte bizarrement :
flutter clean
flutter pub get
flutter run

Vérifier l’environnement

Pour vérifier que tout est correctement installé : flutter create mon_nouveau_projet

🤖 Configuration de l’émulateur Android

Si aucun appareil n’est détecté (No device found) :

1. Ouvrez Android Studio

2. Allez dans Virtual Device Manager

3. Créez un nouveau device (ex : Pixel 6)

4. Lancez-le avec le bouton ▶

5. Relancez : flutter run

📂 Structure des fichiers

- lib/ → Contient tout le code source Dart

- lib/main.dart → Point d’entrée de l’application

- pubspec.yaml → Dépendances et assets (images, polices…)

- android/ → Code natif Android

- ios/ → Code natif iOS

- test/ → Tests unitaires et tests de widgets

