# Guide du projet Flutter - MoneyTransferApp

---

## 1. Démarrage rapide

### 1.1 Cloner le projet

Pour commencer avec le projet, clonez le dépôt Git et accédez au répertoire :

```bash
git clone "url_du_depot"
cd MoneyTransferApp/Frontend
```

### 1.2 Installer les dépendances

Installez toutes les dépendances nécessaires avec la commande :

```bash
flutter pub get
```

### 1.3 Démarrer le backend

Avant de lancer l'app Flutter, le backend Laravel doit être en cours d'exécution :

```bash
cd ../Backend
docker-compose up -d
```

> L'app Flutter communique avec le backend via `http://10.0.2.2:8000/api/v1`
> (`10.0.2.2` est l'adresse de `localhost` depuis l'émulateur Android)

### 1.4 Lancer l'application

Assurez-vous d'avoir un émulateur ouvert ou un téléphone connecté, puis lancez l'application :

```bash
flutter run
```

---

## 2. Contrôles en cours d'exécution

Une fois l'application lancée dans le terminal, vous pouvez utiliser les touches suivantes :

| Touche | Action      | Description                                     |
| ------ | ----------- | ----------------------------------------------- |
| `r`  | Hot Reload  | Met à jour l'UI sans redémarrer l'application |
| `R`  | Hot Restart | Redémarre l'app depuis zéro                   |
| `q`  | Quitter     | Arrête l'exécution de l'application           |
| `d`  | Détacher   | Détache le débogueur sans arrêter l'app      |
| `h`  | Aide        | Affiche toutes les commandes disponibles        |

---

## 3. Commandes essentielles

### Nettoyer le projet (en cas de bug)

Si le projet refuse de compiler ou se comporte bizarrement, utilisez ces commandes :

```bash
flutter clean       # Supprime les fichiers de compilation temporaires (dossier build/)
flutter pub get     # Réinstalle proprement toutes les dépendances
flutter run         # Relance la compilation depuis zéro
```

### Vérifier l'environnement

Pour vérifier que tout est correctement installé (SDK, Android Studio, émulateur, etc.) :

```bash
flutter doctor
```

Cette commande affiche un diagnostic complet de votre environnement de développement Flutter.
Un ✅ vert indique que tout est en ordre, un ❌ rouge indique un problème à corriger.

### Autres commandes utiles

```bash
flutter analyze          # Vérifie le code pour détecter les erreurs et warnings
flutter devices          # Liste tous les appareils et émulateurs disponibles
flutter build apk        # Compile l'application en fichier APK (Android)
flutter upgrade          # Met à jour Flutter vers la dernière version stable
```

---

## 4. Configuration de l'émulateur Android

Si aucun appareil n'est détecté (message "No device found"), suivez ces étapes :

1. Ouvrez **Android Studio**
2. Allez dans **Virtual Device Manager** (icône téléphone en haut à droite)
3. Créez un nouveau périphérique (par exemple : **Pixel 6**)
4. Sélectionnez une image système (recommandé : **API 33 - Android 13**)
5. Lancez l'émulateur en cliquant sur le bouton **Play (▶)**
6. Une fois l'émulateur démarré, relancez :

```bash
flutter run
```

### Vérifier que l'émulateur est détecté

```bash
flutter devices
```

---

## 5. Structure des fichiers

### Organisation générale

```
Frontend/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart      → URLs des endpoints API
│   │   │   └── stripe_constants.dart   → Clé publique Stripe
│   │   ├── theme/
│   │   │   └── app_theme.dart          → Couleurs et styles globaux
│   │   └── utils/
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart         → Modèle utilisateur
│   │   │   └── transaction_model.dart  → Modèle transaction
│   │   └── services/
│   │       └── api_service.dart        → Appels HTTP vers le backend
│   ├── providers/
│   │   ├── auth_provider.dart          → État de l'authentification
│   │   └── transaction_provider.dart   → État des transactions
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart           → Écran de connexion
│   │   │   ├── register_screen.dart        → Écran d'inscription
│   │   │   ├── forgot_password_screen.dart → Mot de passe oublié
│   │   │   └── reset_password_screen.dart  → Réinitialisation
│   │   └── home/
│   │       ├── home_screen.dart        → Dashboard principal
│   │       ├── send/                   → Écran de transfert
│   │       ├── recharge/               → Écran de recharge Stripe
│   │       ├── history/                → Historique des transactions
│   │       ├── qrcode/                 → QR Code (générer/scanner)
│   │       ├── chatbot/                → Chatbot IA
│   │       └── profile/                → Profil utilisateur
│   └── main.dart                       → Point d'entrée de l'application
├── android/                            → Configuration Android native
├── pubspec.yaml                        → Dépendances et assets
└── test/                               → Tests unitaires
```

### Fichiers clés à connaître

| Fichier                                   | Rôle                                          |
| ----------------------------------------- | ---------------------------------------------- |
| `lib/main.dart`                         | Point d'entrée, initialisation des providers  |
| `lib/core/constants/api_constants.dart` | Toutes les URLs de l'API backend               |
| `lib/data/services/api_service.dart`    | Toutes les requêtes HTTP                      |
| `lib/providers/auth_provider.dart`      | Gestion du token et de l'utilisateur connecté |
| `pubspec.yaml`                          | Dépendances Flutter du projet                 |

---

## 6. Dépendances principales

Les packages utilisés dans ce projet (`pubspec.yaml`) :

| Package                | Rôle                                            |
| ---------------------- | ------------------------------------------------ |
| `provider`           | Gestion d'état (authentification, transactions) |
| `http`               | Requêtes HTTP vers le backend Laravel           |
| `shared_preferences` | Stockage local du token Bearer                   |
| `flutter_stripe`     | Intégration des paiements Stripe                |
| `google_fonts`       | Police Poppins pour l'interface                  |
| `qr_flutter`         | Génération de QR codes                         |
| `mobile_scanner`     | Scan de QR codes via la caméra                  |
| `intl`               | Formatage des dates et montants                  |

---

## 7. Comptes de test

| Email          | Mot de passe | PIN    | Solde       |
| -------------- | ------------ | ------ | ----------- |
| alice@test.com | password     | 123456 | 1 000,00 € |
| bob@test.com   | password     | 123456 | 500,00 €   |

### Carte Stripe de test

```
Numéro : 4242 4242 4242 4242
Date   : N'importe quelle date future (ex: 12/30)
CVC    : N'importe quel chiffre (ex: 123)
```

---

## 8. Commandes Git de base

Pour travailler efficacement sur votre branche :

| Commande                    | Description                                                |
| --------------------------- | ---------------------------------------------------------- |
| `git branch`              | Affiche la liste des branches disponibles                  |
| `git checkout louisy`     | Bascule sur votre branche personnelle                      |
| `git status`              | Affiche les fichiers modifiés et leur statut              |
| `git add .`               | Ajoute tous les fichiers modifiés à la zone de staging   |
| `git commit -m "message"` | Enregistre les modifications avec un message               |
| `git push`                | Envoie les modifications vers GitHub                       |
| `git pull`                | Récupère les dernières modifications du dépôt distant |

---

## 9. Résolution des problèmes courants

| Problème                      | Solution                                                      |
| ------------------------------ | ------------------------------------------------------------- |
| `No device found`            | Lancer l'émulateur Android Studio puis `flutter run`       |
| `flutter: command not found` | Vérifier que Flutter est dans le PATH                        |
| Écran blanc au lancement      | Vérifier que le backend Docker est démarré                 |
| Erreur de connexion API        | Vérifier que l'URL est `10.0.2.2:8000` (pas `localhost`) |
| `pub get failed`             | Faire `flutter clean` puis `flutter pub get`              |
| Erreur Stripe                  | Vérifier la clé publique dans `stripe_constants.dart`     |
