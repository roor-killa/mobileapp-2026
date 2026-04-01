# Architecture — PayFlow

## Vue d'ensemble

PayFlow suit une architecture **client-serveur mobile** avec séparation claire des responsabilités entre le frontend Flutter et le backend Laravel.

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT MOBILE                               │
│                        Flutter (Android)                            │
│                                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │  Screens │  │Providers │  │  Models  │  │   API Service    │   │
│  │  (UI)    │◀▶│ (State)  │◀▶│ (Data)   │◀▶│  (HTTP Client)   │   │
│  └──────────┘  └──────────┘  └──────────┘  └────────┬─────────┘   │
└────────────────────────────────────────────────────┬─┘─────────────┘
                                                     │ HTTPS / REST
                                                     │ Bearer Token
┌────────────────────────────────────────────────────▼─────────────────┐
│                          BACKEND LARAVEL                              │
│                                                                       │
│  ┌──────────┐  ┌──────────────┐  ┌──────────┐  ┌────────────────┐   │
│  │  Routes  │  │ Controllers  │  │  Models  │  │   Services     │   │
│  │  api.php │─▶│  (API Layer) │─▶│(Eloquent)│  │  Algorand      │   │
│  └──────────┘  └──────────────┘  └──────────┘  └────────────────┘   │
│                       │                  │                            │
│              ┌─────────▼──────┐  ┌──────▼───────┐                   │
│              │  PostgreSQL    │  │    Redis      │                   │
│              │  (Données)     │  │  (Cache)      │                   │
│              └────────────────┘  └──────────────┘                   │
└───────────────────────────────────────────────────────────────────────┘
                    │                         │
          ┌─────────▼──────┐       ┌──────────▼──────┐
          │     Stripe     │       │    Algorand      │
          │  (Paiements)   │       │   (Blockchain)   │
          └────────────────┘       └─────────────────┘
```

---

## Architecture Backend — Laravel MVC

### Pattern utilisé : **REST API + Service Layer**

```
Request HTTP
    │
    ▼
routes/api.php          ← Définition des endpoints
    │
    ▼
Middleware              ← Sanctum (auth), Rate Limiting
    │
    ▼
Controller              ← Logique métier, validation
    │
    ├──▶ Model (Eloquent) ──▶ PostgreSQL
    │
    └──▶ Service Layer
              ├── AlgorandService  ──▶ Algorand Testnet
              └── (Stripe via webhook)
```

### Controllers

| Controller | Responsabilité |
|-----------|----------------|
| `AuthController` | Inscription, connexion, déconnexion |
| `TransactionController` | Transfert d'argent + Algorand |
| `RechargeController` | Payment Stripe + Webhook |
| `HistoryController` | Historique paginé |
| `ProfileController` | Mise à jour profil, MDP, PIN |
| `QrCodeController` | Génération et scan QR Code |
| `ChatbotController` | Communication avec Ollama |

### Modèles Eloquent

```
User
 ├── hasMany → Transaction (sender_id)
 ├── hasMany → Transaction (receiver_id)
 └── hasMany → QrToken

Transaction
 ├── belongsTo → User (sender)
 └── belongsTo → User (receiver)

QrToken
 ├── belongsTo → User
 └── belongsTo → Transaction (après utilisation)
```

---

## Architecture Frontend — Flutter

### Pattern utilisé : **Provider + Repository**

```
Widget (UI)
    │
    ▼
Provider (State Management)     ← ChangeNotifier
    │
    ▼
ApiService (Repository)         ← HTTP + Token
    │
    ▼
Backend Laravel API
```

### Structure des providers

```dart
AuthProvider
 ├── status: AuthStatus (unknown/authenticated/unauthenticated)
 ├── user: UserModel?
 ├── login(), register(), logout()
 └── refreshUser()

TransactionProvider
 ├── transactions: List<TransactionModel>
 ├── loadHistory()
 ├── transfer()
 ├── generateQr()
 └── scanQr()
```

### Navigation

```
_AppRoot (routing automatique)
    ├── AuthStatus.unknown      → Splash (chargement)
    ├── AuthStatus.unauthenticated → LoginScreen
    │                               └── RegisterScreen
    └── AuthStatus.authenticated   → HomeScreen
                                      ├── [0] DashboardTab
                                      ├── [1] SendScreen
                                      ├── [2] RechargeScreen
                                      ├── [3] HistoryScreen
                                      ├── [4] QrCodeScreen
                                      └── [5] ChatbotScreen
```

---

## Flux de données — Transfert d'argent

```
[Flutter]                 [Laravel]              [Algorand]
   │                          │                      │
   │ POST /transfer            │                      │
   │ {email, amount, pin} ───▶│                      │
   │                          │ Valider PIN           │
   │                          │ Vérifier solde        │
   │                          │ DB Transaction:       │
   │                          │  - Débit sender       │
   │                          │  - Crédit receiver    │
   │                          │  - Créer Transaction  │
   │                          │                      │
   │                          │ Signer TX Ed25519 ──▶│
   │                          │◀── TX ID retourné ───│
   │                          │ Sauvegarder TX ID     │
   │                          │                      │
   │◀── {transaction, txId} ──│                      │
   │                          │                      │
   │ Afficher badge Algorand   │                      │
   │ Ouvrir lora.algokit.io ──────────────────────────────▶ Explorer
```

---

## Flux de données — Recharge Stripe

```
[Flutter]              [Laravel]              [Stripe]
   │                       │                      │
   │ POST /recharge/        │                      │
   │   create-intent ─────▶│                      │
   │                       │ Créer PaymentIntent ▶│
   │                       │◀─ client_secret ──── │
   │◀── {client_secret} ───│                      │
   │                       │                      │
   │ Stripe.initPaymentSheet│                      │
   │ Stripe.presentSheet   │                      │
   │ [Saisie carte]        │                      │
   │ ────────────────────────────────────────────▶│
   │                       │                      │ Paiement confirmé
   │                       │◀── Webhook ──────────│
   │                       │ Vérifier signature    │
   │                       │ Créditer le compte    │
   │                       │ Créer Transaction DB  │
   │                       │                      │
   │ refreshUser() ───────▶│                      │
   │◀── Nouveau solde ─────│                      │
```

---

## Flux de données — QR Code

```
[Utilisateur A]              [Utilisateur B]
 (génère le QR)               (scanne le QR)
      │                             │
      │ POST /qr/generate           │
      │ {amount: 500}               │
      │──────────────▶ Laravel      │
      │                │ Générer HMAC token
      │                │ TTL = 10 secondes
      │◀── {token, qr} │            │
      │                             │
      │ Afficher QR Code            │
      │ Compte à rebours 10s        │
      │                    Scanner ─│
      │                    POST /qr/scan
      │                    {token, pin}──▶ Laravel
      │                             │ Valider token (non expiré, non utilisé)
      │                             │ Vérifier PIN
      │                             │ DB Transaction atomique
      │                             │ Marquer token is_used = true
      │                             │◀── {success, txId}
```

---

## Modèle de données

```sql
users
─────────────────────────────────────────
id              UUID (primary key)
first_name      VARCHAR
last_name       VARCHAR
email           VARCHAR (unique)
phone           VARCHAR (unique, nullable)
password        VARCHAR (bcrypt)
pin_hash        VARCHAR (bcrypt)
balance         BIGINT (centimes, ex: 1000 = 10,00€)
status          ENUM (active/suspended/pending)
created_at      TIMESTAMP

transactions
─────────────────────────────────────────
id                      UUID
sender_id               UUID → users
receiver_id             UUID → users
amount                  BIGINT (centimes)
type                    ENUM (transfer/recharge/qr_send/qr_receive)
status                  ENUM (pending/completed/failed)
reference               VARCHAR (TRF-XXXXXXXXXX)
note                    VARCHAR (nullable)
metadata                JSON (données Stripe)
sender_balance_before   BIGINT
sender_balance_after    BIGINT
receiver_balance_before BIGINT
receiver_balance_after  BIGINT
blockchain_tx_id        VARCHAR (TX ID Algorand)
blockchain_explorer_url VARCHAR (URL Lora)
created_at              TIMESTAMP

qr_tokens
─────────────────────────────────────────
id             UUID
user_id        UUID → users
amount         BIGINT (centimes)
token          VARCHAR (HMAC signé)
expires_at     TIMESTAMP (TTL 10s)
is_used        BOOLEAN
transaction_id UUID → transactions (après scan)
created_at     TIMESTAMP

personal_access_tokens
─────────────────────────────────────────
id             BIGINT
tokenable_type VARCHAR (App\Models\User)
tokenable_id   UUID → users
name           VARCHAR
token          VARCHAR (64, hashé SHA-256)
abilities      JSON
last_used_at   TIMESTAMP
expires_at     TIMESTAMP
created_at     TIMESTAMP
```

---

## Choix techniques

| Choix | Alternative | Raison |
|-------|-------------|--------|
| Laravel 12 | Node.js / Django | Ecosystème PHP riche, Eloquent ORM, Sanctum natif |
| PostgreSQL | MySQL | UUID natif, meilleure conformité SQL, types JSON avancés |
| Flutter | React Native | Performances natives, un seul codebase, Material 3 |
| Provider | Riverpod / Bloc | Simple, adapté à l'échelle du projet |
| Algorand | Ethereum | Frais quasi nuls, finalité immédiate, eco-friendly |
| Solde en centimes | Float | Évite les erreurs d'arrondi des virgules flottantes |
