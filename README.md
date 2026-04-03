# 💳 VLT Bank — Application Bancaire Mobile

> Application mobile bancaire simulée, développée avec **Flutter** (frontend) et **FastAPI** (backend), permettant de gérer des comptes, effectuer des virements, suivre ses dépenses et définir des objectifs d'épargne.

---

## 📱 Aperçu

| Accueil | Virement | Historique | Statistiques |
|---------|----------|------------|--------------|
| Solde, IBAN, transactions récentes | Sélection du destinataire, montants rapides | Filtres Envois/Reçus/Échecs, recherche | Graphiques, budget mensuel |

| Profil | Code PIN | Objectifs d'épargne |
|--------|----------|---------------------|
| Mode sombre, sécurité, budget | Verrouillage au démarrage | Suivi de progression par objectif |

---

## ✨ Fonctionnalités

- **Authentification** — Inscription / Connexion avec mot de passe hashé (SHA-256), persistance de session via `SharedPreferences`
- **Tableau de bord** — Solde disponible, IBAN, récapitulatif mensuel (dépensé / reçu), transactions récentes
- **Virement** — Sélection d'un destinataire parmi les utilisateurs enregistrés, montants rapides (10 / 20 / 50 / 100 / 200 / 500 €), validation du solde en temps réel
- **Historique des transactions** — Filtres par type (Tout / Envois / Reçus / Échecs), recherche textuelle, filtre par plage de dates, export CSV
- **Statistiques** — Graphique donut Envoyé/Reçu, graphique en barres sur 6 mois, budget mensuel personnalisable avec alerte de dépassement
- **Objectifs d'épargne** — Création d'objectifs avec émoji, montant cible, barre de progression, alimentation manuelle
- **Profil** — Modification du nom / mot de passe, mode sombre, code PIN au démarrage, alerte solde bas, budget mensuel
- **Mode sombre** — Thème clair/sombre persistant

---

## 🏗️ Architecture du projet

```
mobileapp-2026-valentin/
├── project/
│   ├── backend/                  # API REST Python
│   │   ├── main.py               # FastAPI — routes, modèles SQLAlchemy, schémas Pydantic
│   │   ├── requirements.txt      # Dépendances Python
│   │   └── vltbank.db            # Base de données SQLite (générée automatiquement)
│   │
│   └── firstapp/                 # Application Flutter
│       ├── lib/
│       │   ├── main.dart                   # Point d'entrée, gestion thème & session
│       │   ├── models/
│       │   │   ├── utilisateur.dart        # Modèle utilisateur
│       │   │   ├── transaction_model.dart  # Modèle transaction
│       │   │   ├── goal_model.dart         # Modèle objectif d'épargne
│       │   │   └── transfer_response.dart  # Réponse de virement
│       │   ├── screens/
│       │   │   ├── login_screen.dart       # Connexion
│       │   │   ├── register_screen.dart    # Inscription
│       │   │   ├── pin_screen.dart         # Code PIN (création / vérification)
│       │   │   ├── dashboard_screen.dart   # Navigation principale (BottomNavBar)
│       │   │   ├── home_tab.dart           # Onglet Accueil
│       │   │   ├── transfer_screen.dart    # Onglet Virement
│       │   │   ├── releve_compte_screen.dart  # Onglet Historique
│       │   │   ├── statistics_screen.dart  # Onglet Statistiques
│       │   │   ├── profile_screen.dart     # Onglet Profil
│       │   │   ├── savings_goals_screen.dart  # Objectifs d'épargne
│       │   │   └── forgot_password_screen.dart # Mot de passe oublié
│       │   ├── services/
│       │   │   ├── api_config.dart         # URL de base de l'API
│       │   │   ├── api_service.dart        # Logique métier des virements
│       │   │   ├── auth_service.dart       # Authentification & session
│       │   │   ├── database_service.dart   # Appels HTTP vers le backend
│       │   │   └── preferences_service.dart # SharedPreferences (thème, PIN, budget)
│       │   └── theme/
│       │       └── app_colors.dart         # Palette de couleurs
│       ├── android/                        # Config Android
│       ├── ios/                            # Config iOS
│       └── pubspec.yaml                    # Dépendances Flutter
```

### Schéma de communication

```
┌─────────────────────────────┐        HTTP/REST        ┌──────────────────────────┐
│        Flutter App          │ ──────────────────────► │    FastAPI Backend        │
│                             │                          │                          │
│  DatabaseService            │  GET  /users             │  SQLAlchemy ORM          │
│  (http calls)               │  POST /users             │                          │
│                             │  POST /transactions      │  ┌────────────────────┐  │
│  AuthService                │  GET  /transactions      │  │   SQLite           │  │
│  (SHA-256 + SharedPrefs)    │  POST /objectifs         │  │   vltbank.db       │  │
│                             │  PATCH /objectifs/:id    │  └────────────────────┘  │
│  PreferencesService         │  DELETE /objectifs/:id   │                          │
│  (thème, PIN, budget)       │  POST /users/:id/favoris │                          │
└─────────────────────────────┘                          └──────────────────────────┘
```

---

## 🗄️ Base de données (SQLite)

Le backend crée automatiquement 4 tables au démarrage :

| Table | Colonnes principales |
|-------|----------------------|
| `utilisateurs` | id, nom, email, mot_de_passe (SHA-256), solde_initial, solde_actuel, cree_le |
| `transactions` | id, utilisateur_id, montant, solde_avant, solde_apres, statut, type, autre_partie_nom, date_heure |
| `objectifs` | id, utilisateur_id, nom, emoji, montant_cible, montant_actuel, date_creation |
| `favoris` | user_id, destinataire_id |

---

## 🚀 Lancer le projet

### Prérequis

- [Python 3.10+](https://www.python.org/)
- [Flutter SDK 3.4+](https://flutter.dev/docs/get-started/install)
- Un émulateur Android / iOS ou un appareil physique

---

### 1. Démarrer le backend

```bash
cd project/backend

# Créer un environnement virtuel (recommandé)
python -m venv venv
source venv/bin/activate        # macOS / Linux
# venv\Scripts\activate         # Windows

# Installer les dépendances
pip install -r requirements.txt

# Lancer le serveur
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

L'API est accessible sur `http://localhost:8000`.  
La documentation interactive Swagger est disponible sur `http://localhost:8000/docs`.

---

### 2. Configurer l'URL de l'API dans Flutter

Ouvrir `project/firstapp/lib/services/api_config.dart` et adapter l'URL selon votre environnement :

```dart
class ApiConfig {
  // Navigateur / Desktop
  static const String baseUrl = 'http://localhost:8000';

  // Émulateur Android
  // static const String baseUrl = 'http://10.0.2.2:8000';

  // Appareil physique (remplacer par l'IP locale de votre machine)
  // static const String baseUrl = 'http://192.168.x.x:8000';
}
```

---

### 3. Lancer l'application Flutter

```bash
cd project/firstapp

# Récupérer les dépendances
flutter pub get

# Lancer sur un appareil connecté ou émulateur
flutter run
```

Pour build un APK Android :

```bash
flutter build apk --release
```

---
 En cas de bug, veuillez utiliser ces ligne de code pour lancer le serveur tout d'abord :

```bash
py -m uvicorn main:app --reload --host 127.0.0.1 --port 8000       (ou python a la place de py tous depend de votre terminal)
```

puis pour lancer l'application flutter run  :

```bash
flutter run -d chrome       
```



## 📦 Dépendances

### Backend Python (`requirements.txt`)

| Package | Rôle |
|---------|------|
| `fastapi` | Framework API REST |
| `uvicorn[standard]` | Serveur ASGI |
| `sqlalchemy` | ORM pour SQLite |

### Frontend Flutter (`pubspec.yaml`)

| Package | Rôle |
|---------|------|
| `http` | Requêtes HTTP vers le backend |
| `shared_preferences` | Persistance locale (session, thème, PIN, budget) |
| `crypto` | Hashage SHA-256 des mots de passe |

---

## 🔒 Sécurité

- Les mots de passe sont hashés en **SHA-256** avant d'être envoyés et stockés.
- La session est persistée localement via `SharedPreferences` (identifiant utilisateur).
- Un **code PIN à 4 chiffres** optionnel verrouille l'accès à l'application au démarrage.
- Les données sont stockées dans une base **SQLite** gérée par le serveur FastAPI — aucun envoi vers des services tiers.

> ⚠️ Ce projet est une **simulation pédagogique**. En production, il faudrait utiliser HTTPS, bcrypt/argon2 pour les mots de passe, et un système d'authentification par token (JWT).

---

## 👤 Auteur

**Valentin** — Projet mobile 2026  
Version `2.0.0`

#(si l'aperçu GitHub ne fonctionne pas: cliquer sur Download en haut a droite )
Le document fonctionne correctement aprés téléchargement.
