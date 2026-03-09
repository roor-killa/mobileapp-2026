# MoneyTransferApp

Application mobile de transfert d'argent développée — L3 Informatique

---

## Présentation

MoneyTransferApp est une application complète de transfert d'argent qui permet à ses utilisateurs d'envoyer de l'argent, de recharger leur compte, de payer via QR Code et d'interagir avec un assistant IA financier. Chaque transaction est enregistrée sur la blockchain **Algorand** pour garantir son immuabilité.

---

## Stack technique

| Couche | Technologie | Version |
|--------|-------------|---------|
| Mobile | Flutter | 3.x |
| Backend | Laravel | 12 |
| Base de données | PostgreSQL | 16 |
| Cache / Sessions | Redis | 7 |
| Conteneurisation | Docker + Docker Compose | - |
| Authentification | Laravel Sanctum | 4.x |
| Paiement | Stripe | - |
| IA / Chatbot | Ollama (LLaMA 3.2) | - |
| Blockchain | Algorand Testnet | - |

---

## Fonctionnalités

| Fonctionnalité | Description |
|----------------|-------------|
| Inscription / Connexion | Authentification sécurisée avec Bearer Token |
| Transfert d'argent | Envoi entre utilisateurs avec confirmation PIN |
| Recharge | Paiement par carte via Stripe |
| QR Code | Génération et scan avec TTL de 10 secondes |
| Historique | Liste paginée avec preuve blockchain |
| Chatbot | Assistant IA alimenté par Ollama LLaMA 3.2 |
| Profil | Modification des informations, mot de passe et PIN |
| Blockchain | Chaque transfert enregistré sur Algorand testnet |

---

## Structure du projet

```
MoneyTransferApp/
├── Backend/                  ← API Laravel + Docker
│   ├── app/
│   │   ├── Http/Controllers/Api/
│   │   ├── Models/
│   │   └── Services/
│   │       └── AlgorandService.php
│   ├── database/
│   │   ├── migrations/
│   │   └── seeders/
│   ├── docker/
│   ├── nginx/
│   ├── routes/
│   │   └── api.php
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── setup.sh
├── Frontend/                 ← Application Flutter
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   └── theme/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── services/
│   │   ├── providers/
│   │   └── screens/
│   │       ├── auth/
│   │       └── home/
└── docs/                     ← Documentation
    ├── INFRASTRUCTURE.md
    ├── ARCHITECTURE.md
    ├── SECURITY.md
    ├── ETAPE_1_BACKEND.md
    ├── ETAPE_2_FRONTEND.md
    ├── ETAPE_3_STRIPE.md
    └── ETAPE_3_BLOCKCHAIN.md
```

---

## Démarrage rapide

### Prérequis

- [Docker Desktop](https://www.docker.com/products/docker-desktop) installé et démarré
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installé
- [Stripe CLI](https://github.com/stripe/stripe-cli/releases) (pour les tests de paiement)

### Lancer le Backend

```bash
cd Backend

# Copier la configuration
cp .env.example .env

# Renseigner les clés dans .env :
# STRIPE_KEY, STRIPE_SECRET, STRIPE_WEBHOOK_SECRET
# ALGORAND_MNEMONIC, ALGORAND_ADDRESS

# Démarrer tous les services
./setup.sh

# Ou manuellement :
docker-compose up -d --build
```

L'API est disponible sur : **http://localhost:8000/api/v1/**

### Lancer le Frontend

```bash
cd Frontend

# Générer les fichiers natifs (première fois)
flutter create . --project-name money_transfer_app --org com.moneytransfer

# Installer les dépendances
flutter pub get

# Lancer sur émulateur Android
flutter run -d emulator-5554
```

### Comptes de test

| Email | Mot de passe | PIN | Solde initial |
|-------|-------------|-----|---------------|
| alice@test.com | password | 123456 | 1 000,00 € |
| bob@test.com | password | 123456 | 500,00 € |

### Carte Stripe de test

```
Numéro : 4242 4242 4242 4242
Date   : n'importe quelle date future
CVC    : n'importe lequel (3 chiffres)
```

---

## Ports exposés

| Service | Port | URL |
|---------|------|-----|
| API Laravel | 8000 | http://localhost:8000 |
| PostgreSQL | 5432 | - |
| Redis | 6379 | - |
| Ollama | 11434 | http://localhost:11434 |
| PgAdmin | 5050 | http://localhost:5050 |

---

## Documentation détaillée

| Document | Contenu |
|----------|---------|
| [Infrastructure](docs/INFRASTRUCTURE.md) | Docker, services, configuration |
| [Architecture](docs/ARCHITECTURE.md) | Stack technique, flux de données, schémas |
| [Sécurité](docs/SECURITY.md) | Authentification, PIN, blockchain, Stripe |
| [Etape 1 — Backend](docs/ETAPE_1_BACKEND.md) | Laravel, API REST, base de données |
| [Etape 2 — Frontend](docs/ETAPE_2_FRONTEND.md) | Flutter, navigation, écrans |
| [Etape 3 — Stripe](docs/ETAPE_3_STRIPE.md) | Intégration paiement par carte |
| [Etape 3 — Blockchain](docs/ETAPE_3_BLOCKCHAIN.md) | Algorand, signature Ed25519 |

---

## Auteur

**Louisy David** — L3 Informatique, Semestre 6
Programmation Mobile — 2026/2027
