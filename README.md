# 📱 NEGs App — Application Bancaire Mobile

> **Cours** : Création d'application mobile — L3 2026  
> **Technologie** : Flutter (Dart) — Application Android/iOS  
> **Étudiant** : Yannelle NEGUI  
> **Année** : 2025–2026

---

## 🗂️ Table des matières

1. [Présentation du projet](#-présentation-du-projet)
2. [Fonctionnalités complètes](#-fonctionnalités-complètes)
3. [Structure du dépôt](#-structure-du-dépôt)
4. [Comment lancer l'application](#-comment-lancer-lapplication)
5. [Guide de navigation — écran par écran](#-guide-de-navigation--écran-par-écran)
6. [Captures d'écran](#-captures-décran)
7. [Présentation PowerPoint](#-présentation-powerpoint)
8. [Architecture technique](#-architecture-technique)
9. [Choix techniques et particularités](#-choix-techniques-et-particularités)

---

## 📌 Présentation du projet

**NEGs App** est une application bancaire mobile complète développée avec **Flutter**, conçue pour offrir une expérience fintech moderne et immersive.

L'application propose une interface entièrement en **dark mode** avec des effets **glassmorphisme**, une navigation fluide par barre inférieure à 5 onglets, et un ensemble complet de fonctionnalités bancaires, crypto et lifestyle.

### Objectif pédagogique
Démontrer la maîtrise du développement mobile Flutter en construisant une application mono-fichier (`main.dart`) de **3 400+ lignes** intégrant :
- Navigation multi-écrans avec `Navigator`
- Gestion d'état avec `StatefulWidget`
- UI avancée : animations, `CustomPainter`, glassmorphisme, dégradés
- Architecture avec modèles de données, widgets réutilisables et services

---

## ✅ Fonctionnalités complètes

| # | Fonctionnalité | Écran | Status |
|---|----------------|-------|--------|
| 1 | **Splash Screen animé** | `SplashScreen` | ✅ Fait |
| 2 | **Login avec animation** | `LoginScreenV3` | ✅ Fait |
| 3 | **Dashboard principal** | `DashboardScreenV3` | ✅ Fait |
| 4 | **Transfert d'argent** | `TransferScreen` | ✅ Fait |
| 5 | **QR Code** (génération + scan simulé) | `QRScreen` | ✅ Fait |
| 6 | **Gestion des bénéficiaires** | `BeneficiairesScreen` | ✅ Fait |
| 7 | **Paiement de factures** | `FacturesScreen` | ✅ Fait |
| 8 | **Gestion des abonnements** | `AbonnementsScreen` | ✅ Fait |
| 9 | **Chatbot IA** | `ChatbotScreen` | ✅ Fait |
| 10 | **Convertisseur multi-devises** | `ConvertisseurScreen` | ✅ Fait |
| 11 | **Partage de dépenses** | `PartageScreen` | ✅ Fait |
| 12 | **Crypto Trading + graphes** | `CryptoScreenV3` | ✅ Fait |
| 13 | **Système de coins + mini-jeux** | `GagnerScreenV3` | ✅ Fait |
| 14 | **Cartes bancaires** (PageView) | `CardsScreenV3` | ✅ Fait |
| 15 | **Personnalisation de carte** (6 thèmes) | `CardCustomizerSheet` | ✅ Fait |
| 16 | **Analyse financière** | `AnalyticsScreenV3` | ✅ Fait |
| 17 | **Profil & paramètres** | `ProfileScreenV3` | ✅ Fait |
| 18 | **Mode Étudiant** (budget + conseils) | `ModeEtudiantScreen` | ✅ Fait |

---

## 📁 Structure du dépôt

```
📦 negs-app/
├── 📄 README.md                        ← Vous êtes ici
├── 📄 .gitignore
├── 📂 presentation/
│   ├── 📊 NEGs_App_Presentation.pptx   ← Slides de soutenance
│   └── 📄 NEGs_App_Rapport.pdf         ← Rapport écrit (si demandé)
├── 📂 screenshots/
│   ├── 01_splash.png
│   ├── 02_login.png
│   ├── 03_dashboard.png
│   ├── 04_transfer.png
│   ├── 05_qr_code.png
│   ├── 06_beneficiaires.png
│   ├── 07_factures.png
│   ├── 08_abonnements.png
│   ├── 09_chatbot.png
│   ├── 10_convertisseur.png
│   ├── 11_partage.png
│   ├── 12_crypto.png
│   ├── 13_gagner.png
│   ├── 14_cartes.png
│   ├── 15_carte_personnalisation.png
│   ├── 16_analytics.png
│   ├── 17_profil.png
│   └── 18_mode_etudiant.png
└── 📂 negs_app/                        ← Projet Flutter
    ├── 📄 pubspec.yaml
    ├── 📂 lib/
    │   ├── 📄 main.dart                ← Fichier principal (3 400+ lignes)
    │   ├── 📂 core/
    │   │   ├── constants/              (colors.dart, styles.dart)
    │   │   ├── models/                 (9 modèles de données)
    │   │   ├── theme/                  (theme.dart)
    │   │   └── widgets/                (glassmorphisme, logo, texte dégradé)
    │   ├── 📂 features/               (17 écrans organisés par feature)
    │   ├── 📂 models/                 (chat, crypto, investment, transaction)
    │   └── 📂 services/               (api_service, storage_service)
    └── 📂 android/ ios/ web/          (configs plateformes)
```

---

## 🚀 Comment lancer l'application

### Prérequis
- Flutter SDK ≥ 3.0 installé → [flutter.dev](https://flutter.dev)
- Android Studio ou VS Code avec le plugin Flutter
- Un émulateur Android (ex : Pixel 6, API 33+) **OU** un appareil physique

### Étapes

```bash
# 1. Cloner le dépôt
git clone https://github.com/[VOTRE_USERNAME]/[NOM_DU_REPO].git
cd [NOM_DU_REPO]/negs_app

# 2. Installer les dépendances
flutter pub get

# 3. Vérifier que Flutter est bien configuré
flutter doctor

# 4. Lancer l'émulateur (depuis Android Studio)
#    OU brancher un téléphone Android en mode développeur

# 5. Lancer l'application
flutter run

# Pour lancer en mode release (plus fluide) :
flutter run --release
```

### En cas de problème
```bash
# Nettoyer le cache et relancer
flutter clean
flutter pub get
flutter run
```

---

## 🗺️ Guide de navigation — écran par écran

> Ce guide explique exactement comment accéder à chaque fonctionnalité dans l'application.

---

### 🔵 Écran 1 — Splash Screen
**Accès :** Automatique au lancement de l'application  
**Durée :** ~2 secondes  
**Ce qu'on voit :** Logo NEGs animé sur fond sombre, transition vers le login

---

### 🔵 Écran 2 — Login
**Accès :** Après le splash screen  
**Identifiants de test :**
- Email : `demo@negs.com` *(ou n'importe quel texte)*
- Mot de passe : `1234` *(ou n'importe quel texte)*

**Ce qu'on voit :** Formulaire animé, effet glassmorphisme, bouton de connexion  
**Action :** Appuyer sur **"Se connecter"** → arrive sur le Dashboard

---

### 🏠 Écran 3 — Dashboard (Accueil)
**Accès :** Onglet **"Accueil"** (icône maison) dans la barre du bas  
**Ce qu'on voit :** Solde du compte, 8 boutons d'actions rapides :

| Bouton | Mène vers |
|--------|-----------|
| 💸 Virement | TransferScreen |
| 📷 QR Code | QRScreen |
| 👥 Bénéficiaires | BeneficiairesScreen |
| 🧾 Factures | FacturesScreen |
| 📺 Abonnements | AbonnementsScreen |
| 🤖 Chatbot | ChatbotScreen |
| 💱 Convertisseur | ConvertisseurScreen |
| 🤝 Partage | PartageScreen |
| 🎓 Étudiant | ModeEtudiantScreen |

---

### 💸 Écran 4 — Transfert d'argent
**Accès :** Dashboard → bouton **"Virement"**  
**Ce qu'on voit :** Liste de contacts, champ IBAN, champ montant, bouton envoyer  
**Particularité :** Contacts avec photos/avatars, validation du montant

---

### 📷 Écran 5 — QR Code
**Accès :** Dashboard → bouton **"QR Code"**  
**Ce qu'on voit :** QR Code généré avec `CustomPainter`, bouton scanner simulé  
**Particularité :** Le QR est dessiné pixel par pixel en Flutter (pas de librairie externe)

---

### 👥 Écran 6 — Bénéficiaires
**Accès :** Dashboard → bouton **"Bénéficiaires"**  
**Ce qu'on voit :** Liste de contacts, barre de recherche, système de favoris (étoile)  
**Particularité :** Filtrage en temps réel par nom

---

### 🧾 Écran 7 — Paiement de factures
**Accès :** Dashboard → bouton **"Factures"**  
**Ce qu'on voit :** Liste de factures (EDF, Orange, loyer...), statut payé/impayé  
**Particularité :** Bouton de paiement avec confirmation

---

### 📺 Écran 8 — Abonnements
**Accès :** Dashboard → bouton **"Abonnements"**  
**Ce qu'on voit :** Netflix, Spotify, Amazon Prime... avec toggles on/off  
**Particularité :** Calcul automatique du total mensuel

---

### 🤖 Écran 9 — Chatbot IA
**Accès :** Dashboard → bouton **"Chatbot"**  
**Ce qu'on voit :** Interface de chat, réponses automatiques intelligentes  
**Comment tester :** Taper "Quel est mon solde ?" ou "Aide" ou "Virement"

---

### 💱 Écran 10 — Convertisseur de devises
**Accès :** Dashboard → bouton **"Convertisseur"**  
**Ce qu'on voit :** Champ montant, sélecteur EUR/XAF/USD/GBP/JPY  
**Particularité :** Conversion en temps réel avec taux de change intégrés

---

### 🤝 Écran 11 — Partage de dépenses
**Accès :** Dashboard → bouton **"Partage"**  
**Ce qu'on voit :** Créer un groupe, ajouter des membres, saisir une dépense, calculer la part de chacun

---

### 🎓 Écran 12 — Mode Étudiant *(fonctionnalité bonus)*
**Accès :** Dashboard → bouton **"Étudiant"**  
**Ce qu'on voit :**
- Slider pour définir le budget mensuel (400€ à 2000€)
- 6 catégories de dépenses (Loyer, Courses, Transport, Loisirs, Abonnements, Divers)
- Appuyer sur une catégorie → modifier le montant
- Barre de progression globale (verte = dans le budget, rouge = dépassé)
- Section conseils d'économies

---

### 💳 Écran 13 — Cartes bancaires
**Accès :** Onglet **"Cartes"** (2e icône) dans la barre du bas  
**Ce qu'on voit :** PageView de 2 cartes, swiper pour changer de carte  
**Particularité :** Bouton **"Personnaliser"** sur chaque carte → ouvre le sélecteur de thème

---

### 🎨 Écran 14 — Personnalisation de carte *(fonctionnalité bonus)*
**Accès :** Onglet Cartes → bouton **"Personnaliser"**  
**Ce qu'on voit :** Bottom sheet avec 6 thèmes de couleurs :
- Nuit violette, Océan, Forêt, Coucher de soleil, Rose gold, Onyx
- Aperçu animé en temps réel de la carte avec le nouveau thème
- Bouton **"Appliquer ce thème"**

---

### 📈 Écran 15 — Crypto Trading
**Accès :** Onglet **"Crypto"** (3e icône) dans la barre du bas  
**Ce qu'on voit :** Liste BTC, ETH, BNB... avec prix et variation, graphe avec `CustomPainter`  
**Particularité :** Graphe dessiné en Flutter natif, simulation de cours en temps réel

---

### 🎮 Écran 16 — Gagner des coins
**Accès :** Onglet **"Gagner"** (4e icône) dans la barre du bas  
**Ce qu'on voit :** Solde de coins, mini-jeux pour gagner des récompenses  
**Particularité :** Système de gamification intégré à l'app bancaire

---

### 👤 Écran 17 — Profil & Paramètres
**Accès :** Onglet **"Profil"** (5e icône) dans la barre du bas  
**Ce qu'on voit :** Photo de profil, informations personnelles, paramètres (notifications, sécurité, langue)  
**Particularité :** Toggle dark/light mode depuis le profil

---

### 📊 Écran 18 — Analyse financière
**Accès :** Depuis le Dashboard → section Analyse  
**Ce qu'on voit :** Graphiques en barres des dépenses par mois, répartition par catégorie

---

## 📸 Captures d'écran

> Toutes les captures sont dans le dossier `screenshots/`

| Capture | Description |
|---------|-------------|
| `01_splash.png` | Écran de démarrage animé |
| `02_login.png` | Formulaire de connexion glassmorphisme |
| `03_dashboard.png` | Tableau de bord avec les 8 boutons |
| `04_transfer.png` | Formulaire de virement |
| `05_qr_code.png` | QR Code généré en CustomPainter |
| `06_beneficiaires.png` | Liste des bénéficiaires avec recherche |
| `07_factures.png` | Paiement de factures |
| `08_abonnements.png` | Gestion des abonnements |
| `09_chatbot.png` | Interface chatbot IA |
| `10_convertisseur.png` | Convertisseur EUR/XAF/USD |
| `11_partage.png` | Partage de dépenses |
| `12_crypto.png` | Trading crypto avec graphe |
| `13_gagner.png` | Système de coins et mini-jeux |
| `14_cartes.png` | PageView des cartes bancaires |
| `15_carte_personnalisation.png` | Sélecteur de 6 thèmes de carte |
| `16_analytics.png` | Analyse financière en barres |
| `17_profil.png` | Profil et paramètres |
| `18_mode_etudiant.png` | Budget étudiant avec slider |

---

## 📊 Présentation PowerPoint

> Le fichier de présentation se trouve dans : `presentation/NEGs_App_Presentation.pptx`

### Plan de la présentation

1. **Slide 1** — Page de titre (NEGs App, nom, cours, année)
2. **Slide 2** — Contexte et objectif du projet
3. **Slide 3** — Technologies utilisées (Flutter, Dart, Material Design)
4. **Slide 4** — Architecture de l'application (structure des fichiers)
5. **Slide 5** — Fonctionnalité : Authentification & Login animé
6. **Slide 6** — Fonctionnalité : Dashboard & Navigation
7. **Slide 7** — Fonctionnalité : Transferts & QR Code
8. **Slide 8** — Fonctionnalité : Crypto Trading (CustomPainter)
9. **Slide 9** — Fonctionnalité : Mode Étudiant *(innovation)*
10. **Slide 10** — Fonctionnalité : Personnalisation de carte *(innovation)*
11. **Slide 11** — Fonctionnalité : Chatbot IA intégré
12. **Slide 12** — Choix techniques et défis rencontrés
13. **Slide 13** — Démonstration live (captures d'écran émulateur)
14. **Slide 14** — Bilan et perspectives d'amélioration
15. **Slide 15** — Conclusion & Questions

---

## 🏗️ Architecture technique

```
NEGsAppV3 (MaterialApp)
    └── NEGsHomeV3 (Routeur principal)
        ├── LoginScreenV3          ← Authentification animée
        └── Scaffold + BottomNav   ← 5 onglets permanents
            ├── [0] DashboardScreenV3
            │       ├── TransferScreen
            │       ├── QRScreen (CustomPainter QRPainter)
            │       ├── BeneficiairesScreen
            │       ├── FacturesScreen
            │       ├── AbonnementsScreen
            │       ├── ChatbotScreen
            │       ├── ConvertisseurScreen
            │       ├── PartageScreen
            │       └── ModeEtudiantScreen ← NOUVEAU
            ├── [1] CardsScreenV3
            │       └── CardCustomizerSheet ← NOUVEAU (BottomSheet)
            ├── [2] CryptoScreenV3 (CustomPainter CryptoPricePainter)
            ├── [3] GagnerScreenV3
            └── [4] ProfileScreenV3
                    └── AnalyticsScreenV3
```

---

## 🔧 Choix techniques et particularités

### 1. Application mono-fichier `main.dart`
Toute l'application (19 classes, 3 400+ lignes) est contenue dans un seul fichier `main.dart`. Cela permet de voir l'intégralité de la logique en un seul endroit, tout en maintenant une organisation claire par classes.

### 2. CustomPainter pour les graphiques
Les graphes crypto et le QR Code sont dessinés **à la main** avec l'API `CustomPainter` de Flutter, sans aucune librairie externe. Cela démontre la maîtrise du canvas Flutter.

### 3. Glassmorphisme natif
Les effets de verre dépoli (`BackdropFilter`, `ImageFilter.blur`) sont implémentés nativement en Flutter via le widget `GlassContainer` dans `lib/core/widgets/glass_container.dart`.

### 4. Design system cohérent
Un système de couleurs et styles centralisé (`lib/core/constants/colors.dart` et `styles.dart`) assure la cohérence visuelle à travers toute l'application.

### 5. Navigation sans librairie externe
Toute la navigation utilise le `Navigator` natif de Flutter (`push`, `pop`, `pushReplacement`) sans `go_router` ni `auto_route`.

### 6. Mode Étudiant — fonctionnalité originale
Fonctionnalité non présente dans les apps bancaires classiques : un module de gestion budgétaire spécialement conçu pour les étudiants, avec slider de budget, suivi par catégorie et alertes de dépassement.

### 7. Personnalisation de carte — UX avancée
Le bottom sheet de personnalisation avec prévisualisation animée en temps réel montre la maîtrise des animations Flutter (`AnimatedContainer`, transitions d'état).

---

## 👨‍💻 Auteur

**[Votre Prénom NOM]**  
Étudiant L3 — [Nom de votre université]  
Cours : Création d'application mobile 2025–2026  

---

*README rédigé avec soin pour faciliter la correction — toutes les fonctionnalités sont accessibles en suivant ce guide.*

---

## 🔴 Problèmes rencontrés & Solutions

> Cette section détaille les difficultés techniques réelles rencontrées pendant le développement et comment elles ont été résolues.

---

### Problème 1 — BUILD FAILED : Gradle incompatible avec AGP 8+

**Erreur obtenue :**
```
BUILD FAILED — Gradle task assembleDebug failed with exit code 1
If you've specified the package attribute in the source AndroidManifest.xml...
```

**Cause :** La version de Gradle (`8.14`) et du plugin Android (`AGP 8.11.1`) spécifiées dans le projet n'existaient pas, provoquant un échec total de la compilation.

**Solution appliquée :**
- Remplacement de Gradle `8.14` → `8.9` dans `gradle-wrapper.properties`
- Remplacement d'AGP `8.11.1` → `8.7.0` dans `build.gradle`
- Remplacement de Kotlin `2.2.20` → `2.1.0`
- Passage de `compileSdk = 35` → `36`

**Leçon apprise :** Toujours vérifier la compatibilité entre les versions de Gradle, AGP et Kotlin avant de lancer un projet Flutter sur Android.

---

### Problème 2 — Packages incompatibles avec AGP 8+

**Erreur obtenue :**
```
Package qr_code_scanner incompatible with current AGP version
Package awesome_notifications incompatible with current AGP version
```

**Cause :** Plusieurs packages listés dans `pubspec.yaml` (`qr_code_scanner`, `awesome_notifications`, et 15 autres) étaient incompatibles avec AGP 8+ et n'étaient pas utilisés dans `main.dart`.

**Solution appliquée :** Suppression de tous les packages non utilisés et simplification du `pubspec.yaml` au strict minimum nécessaire.

**Leçon apprise :** Ne pas accumuler des dépendances inutilisées — chaque package peut créer des conflits de compatibilité.

---

### Problème 3 — Émulateur absent (pas de Pixel 6 disponible)

**Problème :** L'émulateur Pixel 6 n'était présent ni dans Android Studio ni dans VS Code.

**Cause :** L'AVD (Android Virtual Device) n'avait pas été créé au préalable.

**Solution appliquée :**
1. Ouverture d'Android Studio → Virtual Device Manager
2. Création d'un nouvel AVD : Pixel 6 avec API 34 (Android 14)
3. Téléchargement de l'image système (~1.5 Go)
4. Lancement de l'émulateur puis `flutter run` depuis VS Code

**Leçon apprise :** Configurer l'environnement de test dès le début du projet, pas seulement à la fin.

---

### Problème 4 — Application mono-fichier de 3 400+ lignes difficile à maintenir

**Problème :** Tout le code dans un seul `main.dart` rendait la navigation et la modification complexes.

**Cause :** Développement progressif sans architecture séparée dès le départ.

**Solution appliquée :** Maintien de l'approche mono-fichier pour la livraison finale, mais création d'une structure de dossiers `lib/core/`, `lib/features/`, `lib/services/` pour les futures itérations.

**Leçon apprise :** Définir l'architecture du projet avant de commencer à coder les fonctionnalités.

---

### Problème 5 — Graphes crypto sans librairie externe

**Problème :** Aucune librairie de graphes compatible n'était disponible après le nettoyage des packages.

**Solution appliquée :** Développement d'un graphe entièrement custom avec `CustomPainter` de Flutter — les courbes de prix sont tracées pixel par pixel sur un `Canvas` natif.

**Leçon apprise :** Flutter offre des capacités de dessin natif très puissantes avec `CustomPainter` — il n'est pas toujours nécessaire d'utiliser une librairie externe.

---

## 👩‍💻 Auteur

**Yannelle NEGUI**
Étudiante L3 — Université des Antilles
Cours : Création d'application mobile 2025–2026

---

*README rédigé avec soin pour faciliter la correction — toutes les fonctionnalités sont accessibles en suivant ce guide.*
