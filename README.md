PayAPP

Application mobile de transfert d'argent sécurisé avec paiement par QR code, recharge via Stripe, assistant IA local et traçabilité blockchain.

---

## Sommaire

1. [Présentation générale](#1-présentation-générale)
2. [Architecture de l&#39;application](#2-architecture-de-lapplication)
3. [Infrastructure &amp; Docker](#3-infrastructure--docker)
4. [Base de données](#4-base-de-données)
5. [API Backend - Endpoints](#5-api-backend--endpoints)
6. [Sécurité](#6-sécurité)
7. [Fonctionnalités détaillées](#7-fonctionnalités-détaillées)
8. [Blockchain &amp; Traçabilité](#8-blockchain--traçabilité)
9. [Intégration Stripe](#9-intégration-stripe)
10. [Assistant IA (Ollama)](#10-assistant-ia-ollama)
11. [Application Mobile Flutter](#11-application-mobile-flutter)
12. [Installation &amp; Lancement](#12-installation--lancement)
13. [Variables d&#39;environnement](#13-variables-denvironnement)
14. [Stack technique](#14-stack-technique)
15. [Difficultés rencontrées](#15-difficultés-rencontrées)

---

## 1. Présentation générale

**PayApp** est une application mobile de paiement inspirée des services comme Lydia ou PayPal. Elle permet à des utilisateurs de :

- S'inscrire et gérer un compte avec solde
- Envoyer de l'argent à un autre utilisateur par e-mail
- Payer via QR code (comme WeChat Pay)
- Recharger son solde par carte bancaire (Stripe)
- Consulter un historique de transactions complet
- Poser des questions à un assistant IA local (Ollama / llama3.2)

---

## 2. Architecture de l'application

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT (Flutter)                            │
│                                                                     │
│   ┌───────────┐  ┌──────────┐  ┌────────┐  ┌──────────┐  ┌──────┐   │
│   │ Dashboard │  │Historique│  │   QR   │  │ Chatbot  │  │Profil│   │
│   └───────────┘  └──────────┘  └────────┘  └──────────┘  └──────┘   │
│        │               │            │             │            │    │
│        └───────────────┴────────────┴─────────────┴────────────┘    │
│                                    │                                │
│                        Provider (State Management)                  │
│                        ApiService (Dio HTTP Client)                 │
│                        SecureStorage (Token JWT)                    │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ HTTP/JSON (Bearer Token)
                               │ Base URL: http://10.0.2.2:8000/api
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         NGINX (Port 8000)                           │
│                      Reverse Proxy / Load Balancer                  │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    BACKEND Laravel 11 (PHP 8.3)                     │
│                                                                     │
│  ┌──────────────┐  ┌────────────────┐  ┌───────────────────────┐    │
│  │AuthController│  │TransactionCtrl │  │   RechargeController  │    │
│  │ ProfileCtrl  │  │QrPaymentCtrl   │  │   BlockchainController│    │
│  │ DashboardCtrl│  │NotificationCtrl│  │   ChatbotController   │    │
│  └──────────────┘  └────────────────┘  └───────────────────────┘    │
│                                                                     │
│              Laravel Sanctum (Authentification par token)           │
│              Middleware CheckPin (Protection des transfers)         │
└────────┬──────────────────────────┬────────────────────────────────┘
         │                          │
         ▼                          ▼
┌─────────────────┐      ┌──────────────────────┐
│  PostgreSQL 15  │      │     Redis 7          │
│  (Base de       │      │  Cache / Sessions /  │
│   données)      │      │  Files d'attente     │
└─────────────────┘      └──────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│           Services externes            │
│                                        │
│  ┌──────────────┐  ┌────────────────┐  │
│  │    Stripe    │  │ Ollama (LLM)   │  │
│  │ Payment Sheet│  │  llama3.2      │  │
│  │  Webhooks    │  │  Port 11434    │  │
│  └──────────────┘  └────────────────┘  │
└────────────────────────────────────────┘
```

### Flux de données

| Direction             | Protocole             | Format                 |
| --------------------- | --------------------- | ---------------------- |
| Flutter → Backend    | HTTP REST             | JSON + Bearer Token    |
| Backend → PostgreSQL | TCP (interne Docker)  | SQL                    |
| Backend → Redis      | TCP (interne Docker)  | Key-Value              |
| Backend → Stripe     | HTTPS                 | JSON (API REST Stripe) |
| Stripe → Backend     | HTTPS Webhook         | JSON signé            |
| Backend → Ollama     | HTTP (interne Docker) | JSON (API Chat)        |

---

## 3. Infrastructure & Docker

L'ensemble de l'application tourne dans des conteneurs Docker orchestrés par `docker-compose`.

```
docker-compose.yml
├── nginx          → Reverse proxy (port 8000)
├── app            → Backend Laravel (PHP-FPM)
├── postgres       → Base de données relationnelle
├── redis          → Cache et sessions
├── pgadmin        → Interface d'admin BDD (port 5050)
└── ollama         → Modèle IA local (port 11434)
```

### Détail des services

| Service            | Image                    | Port exposé    | Rôle                       |
| ------------------ | ------------------------ | --------------- | --------------------------- |
| **nginx**    | `nginx:1.25-alpine`    | `8000:80`     | Reverse proxy HTTP          |
| **app**      | `myapp-app` (custom)   | Interne         | Backend API Laravel         |
| **postgres** | `postgres:15-alpine`   | `5432:5432`   | Base de données principale |
| **redis**    | `redis:7-alpine`       | `6379:6379`   | Cache, sessions, queues     |
| **pgadmin**  | `dpage/pgadmin4`       | `5050:80`     | Interface admin PostgreSQL  |
| **ollama**   | `ollama/ollama:latest` | `11434:11434` | LLM local (llama3.2)        |

### Réseau Docker

Tous les conteneurs communiquent sur un réseau bridge interne `transfert_network`, isolé du reste du système.

```
transfert_network (bridge)
├── nginx       ← accessible depuis l'extérieur (port 8000)
├── app         ← uniquement accessible par nginx et les autres conteneurs
├── postgres    ← uniquement accessible par app
├── redis       ← uniquement accessible par app
├── pgadmin     ← accessible depuis l'extérieur (port 5050)
└── ollama      ← accessible par app (HTTP interne)
```

### Volumes persistants

| Volume            | Contenu                                         |
| ----------------- | ----------------------------------------------- |
| `postgres_data` | Données PostgreSQL (transactions, users, etc.) |
| `redis_data`    | Données Redis persistantes                     |
| `ollama_data`   | Modèles IA téléchargés (llama3.2)           |
| `laravel_data`  | Fichiers Laravel (code applicatif)              |

### Health Check

Le service `postgres` dispose d'un health check Docker (`pg_isready`) - le service `app` ne démarre que lorsque la base de données est prête.

---

## 4. Base de données

### Schéma complet

```
users
├── id (UUID, PK)
├── first_name, last_name
├── email (unique, indexé)
├── phone (unique)
├── password (bcrypt)
├── pin (bcrypt, 4-6 chiffres)
├── balance (decimal 15,2 - défaut 0.00)
├── is_verified (boolean)
├── kyc_status (pending | approved | rejected)
├── avatar (nullable)
└── timestamps

transactions
├── id (UUID, PK)
├── sender_id (FK → users, nullOnDelete)
├── receiver_id (FK → users, nullOnDelete)
├── amount (decimal 15,2)
├── type (send | recharge | qr_payment | withdraw)
├── status (pending | success | failed)
├── reference_code (unique, indexé)
├── description (nullable)
├── metadata (JSON - stripe_id, etc.)
└── timestamps (indexé)

qr_payments
├── id (UUID, PK)
├── user_id (FK → users, cascadeDelete)
├── amount (decimal 15,2)
├── token (UUID unique)
├── expires_at (timestamp - TTL 30 secondes)
├── is_used (boolean)
├── used_by (FK → users, nullOnDelete)
└── timestamps

recharges
├── id (UUID, PK)
├── user_id (FK → users, cascadeDelete)
├── amount (decimal 15,2)
├── stripe_payment_intent_id (unique, indexé)
├── stripe_status (string)
├── status (pending | success | failed)
└── timestamps

notifications
├── id (UUID, PK)
├── user_id (FK → users, cascadeDelete)
├── title, body
├── type (transfer | recharge | qr_payment | system)
├── is_read (boolean)
├── data (JSON)
└── timestamps

blockchain_logs
├── id (UUID, PK)
├── block_index (bigint séquentiel)
├── transaction_id (FK → transactions, nullable)
├── event_type (send | qr_payment | recharge)
├── block_hash (SHA-256, 64 chars)
├── previous_hash (SHA-256, 64 chars)
├── data (JSON - snapshot de la transaction)
└── created_at
```

### Choix de conception

- **UUID** pour toutes les clés primaires : sécurité, compatibilité distribué
- **bcrypt** pour mots de passe ET codes PIN séparément
- **Index composites** sur `[sender_id, created_at]`, `[receiver_id, created_at]` pour les requêtes fréquentes
- **nullOnDelete** sur les FK utilisateurs (conservation de l'historique si un compte est supprimé)

---

## 5. API Backend - Endpoints

**Base URL :** `http://localhost:8000/api`

### Routes publiques (sans authentification)

| Méthode | Endpoint              | Description                                          |
| -------- | --------------------- | ---------------------------------------------------- |
| `POST` | `/auth/register`    | Inscription (nom, email, téléphone, password, PIN) |
| `POST` | `/auth/login`       | Connexion → retourne un Bearer Token                |
| `POST` | `/recharge/webhook` | Webhook Stripe (signature vérifiée)                |

### Routes protégées (Bearer Token requis)

#### Authentification

| Méthode | Endpoint         | Description                       |
| -------- | ---------------- | --------------------------------- |
| `POST` | `/auth/logout` | Révocation du token courant      |
| `GET`  | `/auth/me`     | Profil de l'utilisateur connecté |

#### Dashboard

| Méthode | Endpoint       | Description                                                   |
| -------- | -------------- | ------------------------------------------------------------- |
| `GET`  | `/dashboard` | Solde + 5 dernières tx + stats mensuelles + nb notifications |

#### Transactions

| Méthode | Endpoint                      | Description                                         |
| -------- | ----------------------------- | --------------------------------------------------- |
| `GET`  | `/transactions`             | Historique paginé (20 par page)                    |
| `POST` | `/transactions/send`        | Envoi d'argent (email destinataire + montant + PIN) |
| `GET`  | `/transactions/{reference}` | Détail d'une transaction par code de référence   |

#### Paiement QR

| Méthode | Endpoint         | Description                                     |
| -------- | ---------------- | ----------------------------------------------- |
| `POST` | `/qr/generate` | Génère un token QR avec montant et expiration |
| `POST` | `/qr/scan`     | Scanne et traite un paiement QR (PIN requis)    |

#### Recharge Stripe

| Méthode | Endpoint                    | Description                                  |
| -------- | --------------------------- | -------------------------------------------- |
| `POST` | `/recharge/create-intent` | Crée un PaymentIntent Stripe                |
| `POST` | `/recharge/confirm`       | Confirme la recharge après paiement réussi |

#### Profil

| Méthode | Endpoint                     | Description               |
| -------- | ---------------------------- | ------------------------- |
| `GET`  | `/profile`                 | Voir le profil            |
| `PUT`  | `/profile`                 | Modifier les informations |
| `POST` | `/profile/change-password` | Changer le mot de passe   |
| `POST` | `/profile/change-pin`      | Changer le code PIN       |
| `POST` | `/profile/avatar`          | Mettre à jour l'avatar   |

#### Notifications

| Méthode | Endpoint                     | Description                        |
| -------- | ---------------------------- | ---------------------------------- |
| `GET`  | `/notifications`           | Liste paginée des notifications   |
| `POST` | `/notifications/read-all`  | Marquer tout comme lu              |
| `POST` | `/notifications/{id}/read` | Marquer une notification comme lue |

#### Chatbot

| Méthode | Endpoint          | Description                          |
| -------- | ----------------- | ------------------------------------ |
| `POST` | `/chatbot/chat` | Envoyer un message à l'assistant IA |

#### Blockchain

| Méthode | Endpoint               | Description                           |
| -------- | ---------------------- | ------------------------------------- |
| `GET`  | `/blockchain`        | Journal d'audit paginé               |
| `GET`  | `/blockchain/verify` | Vérifier l'intégrité de la chaîne |

---

## 6. Sécurité

### Authentification

- **Laravel Sanctum** : authentification par token Bearer (sans cookie ni session)
- Chaque connexion révoque les anciens tokens (pas d'accumulation)
- Token stocké côté client dans `flutter_secure_storage` (chiffrement natif Android/iOS)
- Durée de session configurable (défaut : 120 minutes)

### Protection des opérations sensibles

- **Code PIN** : distinct du mot de passe, hashé en bcrypt, requis pour tout transfert d'argent
- Middleware `CheckPin` intercepte les routes de paiement avant le contrôleur
- Le PIN n'est jamais stocké en clair ni transmis dans les logs

### Validation des transactions

- **Prévention d'auto-transfert** : un utilisateur ne peut pas s'envoyer de l'argent à lui-même
- **Vérification du solde** avant tout débit
- **Limite journalière** : 5 000 € par jour (configurable)
- **Limite par transaction** : 1 000 € (configurable)
- **Idempotence Stripe** : double confirmation (webhook + endpoint `/confirm`) avec vérification du statut Stripe

### Sécurité Stripe

- **Webhook signature** : vérification HMAC de chaque webhook Stripe via `STRIPE_WEBHOOK_SECRET`
- Recharge confirmée côté serveur uniquement après vérification du statut `succeeded` sur l'API Stripe
- Pas de confiance aveugle aux données envoyées par le client Flutter

### Sécurité QR Code

- Chaque QR est à usage unique (`is_used = true` après utilisation)
- Expiration automatique en **30 secondes**
- Token UUID non prédictible

### Blockchain

- Chaque transaction est enregistrée dans un bloc avec un hash SHA-256
- Toute modification a posteriori des données est détectable via `verifyChain()`

### Bonnes pratiques générales

- Mots de passe hashés (bcrypt)
- Messages d'erreur génériques (pas de fuite d'information)
- Contraintes d'intégrité en base de données (FK, unique, not null)
- Séparation réseau Docker (pas d'accès direct à PostgreSQL depuis l'extérieur)

---

## 7. Fonctionnalités détaillées

### Inscription / Connexion

```
Inscription → email + téléphone + password + PIN → Token Bearer
Connexion   → email + password → Token Bearer
```

### Envoi d'argent

```
1. Saisie : email destinataire + montant + PIN
2. Validation : PIN correct, destinataire existant, pas d'auto-envoi,
                solde suffisant, limite journalière, limite unitaire
3. Transaction DB atomique : débit expéditeur + crédit destinataire
4. Enregistrement blockchain (SHA-256)
5. Notification push interne au destinataire
6. Mise à jour du dashboard et de l'historique
```

### Paiement QR

```
Payeur (générateur) :
  → Saisit le montant → QR code généré (TTL 30s)

Payé (scanner) :
  → Scanne le QR → entre son PIN
  → Serveur : vérifie token valide, non expiré, non utilisé
  → Transaction identique au transfert classique
  → QR marqué comme utilisé
```

### Recharge Stripe

```
1. Utilisateur choisit un montant (10/20/50/100/200/500€ ou libre)
2. Backend crée un PaymentIntent Stripe
3. Flutter ouvre le Payment Sheet Stripe (sécurisé, PCI-DSS)
4. Après paiement : Flutter appelle /recharge/confirm
5. Backend vérifie le statut Stripe (status === 'succeeded')
6. Crédit du solde + Transaction + Blockchain log
7. Webhook Stripe en parallèle (idempotent)
```

### Historique

- Paginé (20 transactions par page)
- Affiche : type, montant, direction (envoyé/reçu), date, statut, référence
- Actualisé automatiquement après chaque opération

### Dashboard

- Solde en temps réel
- 5 dernières transactions
- Stats du mois courant (montant envoyé / reçu)
- Nombre de notifications non lues

---

## 8. Blockchain & Traçabilité

Chaque événement financier (transfert, paiement QR, recharge) crée un bloc immuable.

### Structure d'un bloc

```json
{
  "block_index": 42,
  "event_type": "send",
  "transaction_id": "uuid-...",
  "data": {
    "sender": "alice@example.com",
    "receiver": "bob@example.com",
    "amount": 50.00,
    "reference": "TXN-ABC123"
  },
  "previous_hash": "a3f8c2...",
  "block_hash": "7d91e4..."
}
```

### Formule de hachage

```
block_hash = SHA256(block_index + previous_hash + JSON(data))
```

### Vérification de la chaîne

L'endpoint `GET /blockchain/verify` recalcule tous les hashes en séquence et retourne :

- `is_valid: true` si aucune altération détectée
- `is_valid: false` + liste des blocs corrompus sinon

Cela garantit qu'aucune transaction ne peut être modifiée sans détection.

---

## 9. Intégration Stripe

### Configuration requise

```env
STRIPE_KEY=pk_test_...
STRIPE_SECRET=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### Flux de paiement

```
Flutter                    Backend                   Stripe
  │                           │                        │
  │── POST /recharge/create-intent ──────────────────► │
  │                           │── Create PaymentIntent►│
  │◄── client_secret ─────────│◄── intent_id ───────── │
  │                           │                        │
  │── Payment Sheet (SDK) ───────────────────────────► │
  │◄── Payment confirmed ────────────────────────────- │
  │                           │                        │
  │── POST/recharge/confirm ─►│                        │
  │                           │── Verify intent ──────►│
  │                           │◄── status: succeeded ──│
  │                           │── Credit balance       │
  │◄── new_balance ───────────│                        │
  │                           │                        │
  │                           │◄─── Webhook event ─────│
  │                           │── (idempotent check)   │
```

### Lancer le webhook en développement

```bash
.\stripe listen --forward-to localhost:8000/api/recharge/webhook
```

### Carte de test

| Champ   | Valeur                            |
| ------- | --------------------------------- |
| Numéro | `4242 4242 4242 4242`           |
| Date    | N'importe quelle date future      |
| CVC     | N'importe quel code à 3 chiffres |

---

## 10. Assistant IA (Ollama)

### Architecture

```
Flutter → POST /chatbot/chat → ChatbotController → Ollama (llama3.2)
```

Ollama tourne en local dans un conteneur Docker - **aucune donnée ne sort vers un service cloud**.

### Prompt système

Le chatbot reçoit automatiquement le contexte de l'utilisateur :

- Son prénom
- Son solde actuel
- Ses 5 dernières transactions

Il répond **exclusivement en français**, se concentre sur les questions financières liées à l'application, et ne divulgue pas d'informations sensibles.

### Modèle utilisé

**llama3.2** - modèle de langage open-source, léger, optimisé pour les dialogues en français.

### Première installation du modèle

```bash
docker exec -it transfert_ollama ollama pull llama3.2
```

---

## 11. Application Mobile Flutter

### Structure des pages

```
lib/
├── main.dart              ← Initialisation Stripe + Providers
├── app.dart               ← Router principal + Splash
├── core/
│   ├── constants/         ← URLs API, couleurs
│   ├── models/            ← UserModel, TransactionModel
│   └── services/          ← ApiService (Dio), StorageService
├── features/
│   ├── auth/              ← Login, Register
│   ├── dashboard/         ← Page d'accueil (solde, stats)
│   ├── history/           ← Historique des transactions
│   ├── transfer/          ← Envoi d'argent (email)
│   ├── qr/                ← Génération + scan QR
│   ├── recharge/          ← Recharge Stripe
│   ├── chatbot/           ← Assistant IA
│   └── profile/           ← Profil utilisateur
├── navigation/
│   └── main_navigation.dart  ← Navigation 5 onglets
├── providers/
│   ├── auth_provider.dart
│   ├── dashboard_provider.dart
│   └── transaction_provider.dart
└── widgets/               ← Composants réutilisables
```

### Navigation

```
SplashScreen
  ├── (non connecté) → LoginPage / RegisterPage
  └── (connecté) → MainNavigation
                       ├── [0] Dashboard
                       ├── [1] Historique
                       ├── [2] QR Code (bouton central)
                       ├── [3] Chatbot
                       └── [4] Profil
```

### État (State Management)

- **Provider** pattern pour l'état global
- Mise à jour automatique du dashboard et de l'historique après chaque opération
- Token persisté en `flutter_secure_storage` (chiffrement natif)

### Dépendances principales

| Package                    | Version | Usage                        |
| -------------------------- | ------- | ---------------------------- |
| `flutter_stripe`         | ^10.1.1 | Payment Sheet Stripe         |
| `provider`               | ^6.1.2  | State management             |
| `dio`                    | ^5.4.3  | Client HTTP                  |
| `flutter_secure_storage` | ^9.2.2  | Stockage sécurisé du token |
| `qr_flutter`             | ^4.1.0  | Génération QR code         |
| `mobile_scanner`         | ^5.2.3  | Scan QR code                 |
| `intl`                   | ^0.19.0 | Formatage dates et devises   |

---

## 12. Installation & Lancement

### Prérequis

- Docker Desktop installé et démarré
- Flutter SDK (>= 3.x)
- Android Emulator ou appareil physique (Android >= 6.0)
- Stripe CLI (pour les tests de webhook en développement)

### 1. Démarrer le backend

```bash
cd Backend
docker-compose up -d
```

Vérifier que tous les conteneurs sont actifs :

```bash
docker ps
```

### 2. Installer le modèle IA (première fois uniquement)

```bash
docker exec -it transfert_ollama ollama pull llama3.2
```

### 3. Lancer le webhook Stripe (terminal dédié)

```bash
.\stripe listen --forward-to localhost:8000/api/recharge/webhook
```

### 4. Lancer l'application Flutter

```bash
cd Frontend
flutter run
```

### Interfaces disponibles

| Service          | URL                          |
| ---------------- | ---------------------------- |
| API Backend      | http://localhost:8000/api    |
| PgAdmin (BDD)    | http://localhost:5050        |
| Ollama           | http://localhost:11434       |
| Stripe Dashboard | https://dashboard.stripe.com |

### Identifiants PgAdmin

| Champ        | Valeur                     |
| ------------ | -------------------------- |
| Email        | `admin@transfertapp.com` |
| Mot de passe | `admin123`               |

---

## 13. Variables d'environnement

```env
# Application
APP_NAME=TransfertApp
APP_ENV=local
APP_KEY=
APP_URL=http://localhost:8000

# Base de données PostgreSQL
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=transfert_db
DB_USERNAME=transfert_user
DB_PASSWORD=transfert_password

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Stripe
STRIPE_KEY=pk_test_...
STRIPE_SECRET=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Ollama (IA locale)
OLLAMA_HOST=ollama
OLLAMA_PORT=11434
OLLAMA_MODEL=llama3.2

# Limites de transfert
MAX_DAILY_TRANSFER=5000.00
MAX_SINGLE_TRANSFER=1000.00

# QR Code
QR_TOKEN_TTL=30
```

---

## 14. Stack technique

| Couche                     | Technologie             | Version |
| -------------------------- | ----------------------- | ------- |
| **Mobile**           | Flutter / Dart          | >= 3.x  |
| **Backend**          | Laravel                 | 11      |
| **Langage backend**  | PHP                     | 8.3     |
| **Base de données** | PostgreSQL              | 15      |
| **Cache / Sessions** | Redis                   | 7       |
| **Reverse proxy**    | Nginx                   | 1.25    |
| **Conteneurisation** | Docker + Docker Compose | Latest  |
| **Paiement**         | Stripe Payment Sheet    | API v1  |
| **IA locale**        | Ollama + llama3.2       | Latest  |
| **Auth**             | Laravel Sanctum         | -       |
| **Hachage**          | SHA-256 (blockchain)    | -       |

---

## 15. Difficultés rencontrées

### 1. Stripe - `MissingPluginException` au lancement

**Problème :** Le plugin `flutter_stripe` crashait au démarrage de l'app avec `MissingPluginException`.

**Cause :** La version minimale d'Android SDK était trop basse. Stripe nécessite `minSdk = 23` minimum, mais le fichier `build.gradle.kts` utilisait `flutter.minSdkVersion` (API 16).

**Solution :** Forcer `minSdk = 23` dans `android/app/build.gradle.kts`.

**Complication supplémentaire :** Cette valeur revenait automatiquement à `flutter.minSdkVersion` après certaines opérations Flutter, nécessitant une vérification systématique avant chaque lancement.

---

### 2. Stripe - `PlatformException: MainActivity is not a subclass of FlutterFragmentActivity`

**Problème :** Le Payment Sheet Stripe refusait de s'ouvrir.

**Cause :** Stripe Payment Sheet exige que l'activité principale Android hérite de `FlutterFragmentActivity` et non de `FlutterActivity` (la valeur par défaut Flutter).

**Solution :**

- Modifier `MainActivity.kt` : `FlutterActivity()` → `FlutterFragmentActivity()`
- Mettre à jour `styles.xml` : `Theme.AppCompat` → `Theme.MaterialComponents.Light.NoActionBar`
- Ajouter la dépendance Material Components dans `build.gradle.kts`

---

### 3. Crash de type au retour d'un transfert

**Problème :** L'application crashait après un transfert réussi avec l'erreur :

```
type 'int' is not a subtype of type 'double?'
```

**Cause :** L'API Laravel retourne `new_balance` comme entier JSON (`900`) dans certains cas. Flutter essayait de le caster directement en `double?`, ce qui échoue si la valeur est un `int`.

**Solution :** Remplacer `result['new_balance'] as double?` par `(result['new_balance'] as num?)?.toDouble()` pour accepter `int` et `double`.

---

### 4. Historique des transactions non actualisé

**Problème :** Après un transfert ou une recharge, l'historique affichait toujours "Aucune transaction" même si la transaction venait d'être effectuée.

**Cause :** Flutter utilise un `IndexedStack` pour la navigation - toutes les pages restent montées en mémoire. La méthode `initState()` n'est appelée qu'une seule fois au montage initial. Changer d'onglet ne re-déclenche pas le chargement des données.

**Solution :**

- Ajouter une méthode `_onTabTap()` dans la navigation principale qui appelle explicitement `loadDashboard()` et `loadTransactions()` lors d'un changement d'onglet
- Ajouter un rafraîchissement des données après chaque opération réussie (transfert, recharge)

---

### 5. Boucle de crash au redémarrage du backend

**Problème :** Après un arrêt et redémarrage de `docker-compose`, le backend entrait en boucle de crash avec l'erreur :

```
SQLSTATE[42P07]: Duplicate table: personal_access_tokens already exists
```

**Cause :** La migration Laravel tentait de recréer la table `personal_access_tokens` déjà existante en base (la base PostgreSQL persiste via un volume Docker).

**Solution :** Ajouter `Schema::dropIfExists('personal_access_tokens')` avant `Schema::create()` dans la migration correspondante.

---

### 6. Chatbot - "Service temporairement indisponible"

**Problème :** Le chatbot affichait toujours "Service temporairement indisponible" malgré le modèle Ollama correctement installé.

**Cause :** Le client HTTP Flutter (Dio) avait un `receiveTimeout` de 15 secondes. Ollama (llama3.2) peut mettre 30 à 60 secondes pour générer une réponse, surtout au premier appel (chargement du modèle en mémoire). Dio déclenchait donc un timeout avant d'obtenir la réponse.

**Solution :** Passer le `receiveTimeout` à 90 secondes spécifiquement pour les appels au chatbot, sans modifier le timeout global des autres endpoints.

---

### 7. Avertissements Flutter analyze (28 → 0)

**Problème :** `flutter analyze` retournait 28 avertissements bloquants pour la soumission.

**Principaux problèmes :**

| Avertissement                       | Cause                                                         | Solution                                                                  |
| ----------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `withOpacity` deprecated          | API Flutter dépréciée                                      | Remplacer par `.withValues(alpha: x)`                                   |
| `use_build_context_synchronously` | Utilisation du context après un `await` sans vérification | Ajouter `if (context.mounted)` avant chaque usage du context post-await |
| `prefer_const_constructors`       | Widgets instanciés sans `const`                            | Ajouter le mot-clé `const`                                             |

**Solution :** Correction fichier par fichier dans tout le projet Flutter.

---

### 8. Fausses erreurs VSCode depuis le cache Pub

**Problème :** Le panneau PROBLEMS de VSCode affichait 6 erreurs provenant de fichiers dans `C:\Users\...\AppData\Local\Pub\Cache\` - le cache des packages Flutter.

**Cause :** L'extension Java/Kotlin de VSCode analysait les fichiers source des plugins Flutter stockés dans le cache global, les confondant avec du code du projet.

**Caractéristique importante :** Ces erreurs n'impactaient pas la compilation - `flutter run` et `flutter analyze` fonctionnaient parfaitement.

**Solution :** Ajouter un fichier `.vscode/settings.json` avec des exclusions d'analyse :

```json
{
  "java.import.exclusions": ["**/AppData/Local/Pub/Cache/**"],
  "dart.analysisExcludedFolders": ["C:\\Users\\...\\AppData\\Local\\Pub\\Cache"],
  "files.watcherExclude": { "**/AppData/Local/Pub/Cache/**": true }
}
```

---

## Auteur

Projet réalisé dans le cadre du cours de **Programmation Mobile** - L3 Informatique, Semestre 6.
