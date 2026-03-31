# MoneyTransferApp

Application mobile de transfert d'argent développée - L3 Informatique

---

## Présentation

MoneyTransferApp est une application complète de transfert d'argent qui permet à ses utilisateurs d'envoyer de l'argent, de recharger leur compte, de payer via QR Code et d'interagir avec un assistant IA financier. Chaque transaction est enregistrée sur la blockchain **Algorand** pour garantir son immuabilité. Des notifications email automatiques informent les utilisateurs à chaque événement important.

---

## Stack technique

| Couche           | Technologie             | Version |
| ---------------- | ----------------------- | ------- |
| Mobile           | Flutter                 | 3.x     |
| Backend          | Laravel                 | 12      |
| Base de données | PostgreSQL              | 16      |
| Cache / Sessions | Redis                   | 7       |
| Conteneurisation | Docker + Docker Compose | -       |
| Authentification | Laravel Sanctum         | 4.x     |
| Paiement         | Stripe                  | -       |
| IA / Chatbot     | Ollama (LLaMA 3.2)      | -       |
| Blockchain       | Algorand Testnet        | -       |
| Email            | Mailtrap SMTP           | -       |

---

## Fonctionnalités

| Fonctionnalité         | Description                                                         |
| ----------------------- | ------------------------------------------------------------------- |
| Inscription / Connexion | Authentification sécurisée avec Bearer Token                      |
| Transfert d'argent      | Envoi entre utilisateurs avec confirmation PIN                      |
| Recharge                | Paiement par carte via Stripe                                       |
| QR Code                 | Génération et scan avec TTL de 10 secondes                        |
| Historique              | Liste paginée avec preuve blockchain                               |
| Chatbot                 | Assistant IA alimenté par Ollama LLaMA 3.2                         |
| Profil                  | Modification des informations, mot de passe et PIN                  |
| Blockchain              | Chaque transfert enregistré sur Algorand testnet                   |
| Mot de passe oublié    | Réinitialisation par code 8 chiffres email (TTL 15 min)            |
| Notifications email     | Alertes automatiques : transfert reçu/envoyé, recharge confirmée |

---

## Structure du projet

```
MoneyTransferApp/
├── Backend/                  ← API Laravel + Docker
│   ├── app/
│   │   ├── Http/Controllers/Api/
│   │   │   ├── AuthController.php
│   │   │   ├── TransactionController.php
│   │   │   ├── RechargeController.php
│   │   │   ├── HistoryController.php
│   │   │   ├── ProfileController.php
│   │   │   ├── QrCodeController.php
│   │   │   ├── ChatbotController.php
│   │   │   └── PasswordResetController.php
│   │   ├── Mail/
│   │   │   ├── ResetPasswordMail.php
│   │   │   ├── TransferReceivedMail.php
│   │   │   ├── TransferSentMail.php
│   │   │   └── RechargeConfirmedMail.php
│   │   ├── Models/
│   │   └── Services/
│   │       └── AlgorandService.php
│   ├── resources/views/emails/
│   │   ├── reset-password.blade.php
│   │   ├── transfer-received.blade.php
│   │   ├── transfer-sent.blade.php
│   │   └── recharge-confirmed.blade.php
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
│   │   │   │   └── api_constants.dart
│   │   │   └── theme/
│   │   │       └── app_theme.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── services/
│   │   │       └── api_service.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   └── transaction_provider.dart
│   │   └── screens/
│   │       ├── auth/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   ├── forgot_password_screen.dart
│   │       │   └── reset_password_screen.dart
│   │       └── home/
│   │           ├── home_screen.dart
│   │           ├── send/
│   │           ├── recharge/
│   │           ├── history/
│   │           ├── qrcode/
│   │           ├── chatbot/
│   │           └── profile/
└── docs/                     ← Documentation
    ├── INFRASTRUCTURE.md
    ├── ARCHITECTURE.md
    ├── SECURITY.md
    ├── ETAPE_1_BACKEND.md
    ├── ETAPE_2_FRONTEND.md
    ├── ETAPE_3_STRIPE.md
    ├── ETAPE_3_BLOCKCHAIN.md
    ├── MOT_DE_PASSE_OUBLIE.md
    ├── NOTIFICATIONS_EMAIL.md
    └── ORAL.md
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
# MAIL_HOST, MAIL_USERNAME, MAIL_PASSWORD (Mailtrap)

# Démarrer tous les services
./setup.sh

# Ou manuellement :
docker-compose up -d --build
```

L'API est disponible sur : **http://localhost:8000/api/v1/**

### Lancer le Frontend

```bash
cd Frontend

# Installer les dépendances
flutter pub get

# Lancer sur émulateur Android
flutter run -d emulator-5554

# Lancer sur 2 émulateurs simultanément
flutter run -d emulator-5554   # Terminal 1
flutter run -d emulator-5556   # Terminal 2
```

### Tester les webhooks Stripe (recharge)

```bash
# Terminal séparé - laisser tourner pendant les tests
C:\stripe\stripe.exe listen --forward-to http://localhost:8000/api/v1/recharge/webhook
```

---

## Comptes de test

| Email          | Mot de passe | PIN    | Solde initial |
| -------------- | ------------ | ------ | ------------- |
| alice@test.com | password     | 123456 | 1 000,00 €   |
| bob@test.com   | password     | 123456 | 500,00 €     |

### Carte Stripe de test

```
Numéro : 4242 4242 4242 4242
Date   : n'importe quelle date future
CVC    : n'importe lequel (3 chiffres)
```

---

## Ports exposés

| Service     | Port  | URL                    |
| ----------- | ----- | ---------------------- |
| API Laravel | 8000  | http://localhost:8000  |
| PostgreSQL  | 5432  | -                      |
| Redis       | 6379  | -                      |
| Ollama      | 11434 | http://localhost:11434 |
| PgAdmin     | 5400  | http://localhost:5400  |

> **Note :** PgAdmin utilise le port **5400** (5050 réservé par Windows)
> Login : `admin@moneytransfer.local` / `admin`

---

## API Endpoints

### Publiques (sans authentification)

```
POST /api/v1/auth/register          - Inscription
POST /api/v1/auth/login             - Connexion → Token
POST /api/v1/auth/forgot-password   - Demande reset mot de passe
POST /api/v1/auth/reset-password    - Réinitialisation mot de passe
POST /api/v1/recharge/webhook       - Webhook Stripe (signature)
```

### Protégées (Bearer Token requis)

```
POST   /api/v1/auth/logout           - Déconnexion
GET    /api/v1/auth/me               - Profil courant
POST   /api/v1/transfer              - Transfert (PIN requis)
POST   /api/v1/recharge/create-intent - Créer PaymentIntent Stripe
GET    /api/v1/history               - Historique paginé
GET    /api/v1/history/{id}          - Détail transaction
PUT    /api/v1/profile               - Modifier informations
PUT    /api/v1/profile/password      - Changer mot de passe
PUT    /api/v1/profile/pin           - Changer PIN
POST   /api/v1/qr/generate           - Générer QR Code
POST   /api/v1/qr/scan               - Scanner et payer
POST   /api/v1/chatbot/message       - Message chatbot IA
```

---

## Notifications Email

Emails automatiques envoyés via Mailtrap SMTP :

| Événement                | Destinataire                   |
| -------------------------- | ------------------------------ |
| Transfert reçu            | Destinataire du virement       |
| Transfert envoyé          | Expéditeur du virement        |
| Recharge Stripe confirmée | Utilisateur rechargé          |
| Mot de passe oublié       | Utilisateur demandant le reset |

---

## Documentation détaillée

| Document                                         | Contenu                                             |
| ------------------------------------------------ | --------------------------------------------------- |
| [Infrastructure](docs/INFRASTRUCTURE.md)            | Docker, services, configuration                     |
| [Architecture](docs/ARCHITECTURE.md)                | Stack technique, flux de données, schémas         |
| [Sécurité](docs/SECURITY.md)                      | Authentification, PIN, blockchain, Stripe           |
| [Etape 1 - Backend](docs/ETAPE_1_BACKEND.md)        | Laravel, API REST, base de données                 |
| [Etape 2 - Frontend](docs/ETAPE_2_FRONTEND.md)      | Flutter, navigation, écrans                        |
| [Etape 3 - Stripe](docs/ETAPE_3_STRIPE.md)          | Intégration paiement par carte                     |
| [Etape 3 - Blockchain](docs/ETAPE_3_BLOCKCHAIN.md)  | Algorand, signature Ed25519                         |
| [Mot de passe oublié](docs/MOT_DE_PASSE_OUBLIE.md) | Réinitialisation par code email, sécurité, tests |
| [Notifications Email](docs/NOTIFICATIONS_EMAIL.md)  | Emails automatiques, Mailtrap, tests Thunder Client |

---

## Auteur

**Louisy David** - L3 Informatique, Semestre 6
Programmation Mobile - 2026
