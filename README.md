# 🧊 IceBank — Application Bancaire Mobile

> Application bancaire mobile complète avec gestion de compte,
> cryptomonnaies et assistant IA intelligent.

---

## 👨‍💻 Auteur

**Tevi Elolo Peniel Lawson Body**
Licence Informatique L3 — 2026

---

## 📱 Aperçu

IceBank est une application bancaire mobile moderne développée avec
Flutter (frontend) et Laravel (backend), intégrant :

- 🏦 Gestion de compte bancaire
- 💳 Gestion de carte (paramètres, opposition, PIN)
- 🔄 Virements et transactions
- ₿ Achat, vente et envoi de cryptomonnaies
- 🤖 Assistant IA bancaire intelligent (IceAI)
- 🐳 Infrastructure Docker complète

---

## 🛠️ Technologies

| Couche       | Technologie         |
|-------------|---------------------|
| Frontend    | Flutter 3.x / Dart  |
| Backend     | Laravel 10 / PHP 8.2|
| Base de données | MySQL 8.0       |
| Cache       | Redis               |
| Auth        | Laravel Sanctum     |
| IA          | OpenAI GPT-3.5      |
| Crypto API  | CoinGecko API       |
| DevOps      | Docker / Docker Compose |

---

## 📁 Structure du projet
```
icebank/
├── infrastructure/
│   └── docker-compose.yml
└── projet/
    ├── backend/          ← API Laravel
    │   ├── app/
    │   │   ├── Http/Controllers/
    │   │   │   ├── AuthController.php
    │   │   │   ├── AccountController.php
    │   │   │   ├── TransactionController.php
    │   │   │   ├── CryptoController.php
    │   │   │   ├── CardController.php
    │   │   │   └── AIController.php
    │   │   └── Models/
    │   │       ├── User.php
    │   │       ├── Transaction.php
    │   │       ├── Card.php
    │   │       ├── CryptoWallet.php
    │   │       └── CryptoTransaction.php
    │   ├── database/
    │   │   ├── migrations/
    │   │   └── seeders/
    │   ├── routes/api.php
    │   └── Dockerfile
    └── frontend/         ← App Flutter
        ├── lib/
        │   ├── main.dart
        │   ├── theme/
        │   ├── providers/
        │   ├── screens/
        │   └── services/
        └── pubspec.yaml
```

---

## 🚀 Lancer le projet

### Prérequis
- Docker Desktop
- Flutter SDK
- PHP 8.2 + Composer

### Backend + Base de données
```bash
cd infrastructure
docker-compose up -d
docker exec icebank_backend php artisan migrate --seed
```

### Frontend Flutter
```bash
cd projet/frontend
flutter pub get
flutter run
```

---

## 🔌 API Endpoints

### Auth
| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | /api/register | Créer un compte |
| POST | /api/login | Se connecter |
| POST | /api/logout | Se déconnecter |

### Compte
| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | /api/balance | Solde du compte |
| GET | /api/transactions | Liste des transactions |
| POST | /api/transfer | Nouveau virement |

### Crypto
| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | /api/crypto/prices | Prix des cryptos |
| GET | /api/crypto/portfolio | Portefeuille |
| POST | /api/crypto/buy | Acheter |
| POST | /api/crypto/sell | Vendre |
| POST | /api/crypto/send | Envoyer |

### IA
| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | /api/ai/chat | Chat avec IceAI |

---

## 📸 Captures d'écran

> Captures disponibles dans le rapport PDF

---

## 📄 Licence

Projet académique — L3 Informatique 2026
