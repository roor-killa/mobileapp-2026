# 🏦 FirstApp — Application Bancaire Mobile

> Projet de fin de L3 Informatique — Université des Antilles, Campus de Schoelcher (2025-2026)

Une application mobile bancaire complète développée avec **Flutter** (frontend) et **Laravel** (backend), offrant transferts d'argent, paiement par QR code, rechargement Stripe, échange de cryptomonnaie BKN sur la blockchain Algorand, chatbot IA et notifications en temps réel.

---

## 🎯 Contexte & Objectifs

Ce projet a été réalisé dans le cadre de la Licence 3 Informatique pour expérimenter le développement d'une application mobile multi-plateforme de type fintech. Chaque étudiant a développé son application sur une branche Git dédiée.

**Stack technique :**
- **Flutter** — Application mobile (iOS, Android)
- **Laravel 12** — API REST sécurisée (backend)
- **Stripe** — Paiement par carte bancaire
- **Algorand** — Blockchain pour la cryptomonnaie BKN
- **Resend** — Service d'envoi d'e-mails transactionnels
- **Nginx** — Reverse Proxy
- **PostgreSQL** — Base de données

---

## 📁 Structure du projet

```
project/
├── firstapp/              # 📱 Application Flutter (frontend)
│   ├── lib/
│   │   ├── main.dart                    # Point d'entrée, init Stripe & auto-login
│   │   ├── login_screen.dart            # Écran de connexion
│   │   ├── register_screen.dart         # Écran d'inscription
│   │   ├── main_navigation.dart         # Navigation par onglets
│   │   ├── models/
│   │   │   ├── transaction.dart         # Modèle transaction
│   │   │   └── transfer_response.dart   # Modèle réponse virement
│   │   ├── screens/
│   │   │   ├── transfer_screen.dart     # Écran principal (solde, virement, QR)
│   │   │   ├── profile_screen.dart      # Profil utilisateur
│   │   │   ├── receive_money_screen.dart# Affichage QR code personnel
│   │   │   └── scanner_screen.dart      # Scanner QR pour payer
│   │   └── services/
│   │       ├── api_service.dart         # Service HTTP (singleton)
│   │       └── stripe_service.dart      # Service Stripe
│   ├── android/                         # Config Android
│   ├── ios/                             # Config iOS
│   └── pubspec.yaml                     # Dépendances Flutter
│
├── secondapp/             # 📱 App secondaire (branche expérimentale)
│
└── mon_api_flutter/       # ⚙️ Backend Laravel (API REST)
    ├── app/
    │   ├── Http/Controllers/
    │   │   ├── AuthController.php       # Auth, virements, historique
    │   │   └── StripeController.php     # Paiements Stripe & webhooks
    │   ├── Mail/
    │   │   ├── LoginNotification.php    # E-mail alerte connexion
    │   │   ├── WelcomeNotification.php  # E-mail bienvenue
    │   │   └── TransferNotification.php # E-mail confirmation virement
    │   └── Models/
    │       ├── User.php                 # Modèle utilisateur (Sanctum)
    │       ├── Transfer.php             # Modèle virement
    │       └── Transaction.php          # Modèle transaction Stripe
    ├── database/migrations/             # Migrations DB
    ├── routes/api.php                   # Routes API
    └── resources/views/emails/          # Templates e-mails Blade
```

---

## 🚀 Lancer l'application

### Prérequis

| Outil | Version minimale |
|-------|-----------------|
| Flutter | 3.x |
| PHP | 8.2+ |
| Composer | 2.x |
| Node.js | 18+ |

### 1. Backend Laravel

```bash
# Cloner le projet
git clone https://github.com/[votre-repo]/mobileapp-2026.git
cd project/mon_api_flutter

# Installer les dépendances PHP
composer install

# Configurer l'environnement
cp .env.example .env
php artisan key:generate

# Configurer .env (renseigner vos clés)
# DB_CONNECTION=pgsql
# STRIPE_SECRET=sk_test_...
# STRIPE_WEBHOOK_SECRET=whsec_...
# RESEND_API_KEY=re_...
# MAIL_MAILER=resend
# MAIL_FROM_ADDRESS=noreply@votredomaine.com

# Lancer les migrations
php artisan migrate

# Démarrer le serveur
php artisan serve
# → API disponible sur http://127.0.0.1:8000/api
```

### 2. Frontend Flutter

```bash
cd project/firstapp

# Installer les dépendances
flutter pub get

# ⚠️ Modifier l'IP du backend dans lib/services/api_service.dart
# static const String baseUrl = 'http://VOTRE_IP_LOCALE/api';
# (ex: http://192.168.1.12/api)

# Lancer sur émulateur ou appareil physique
flutter run
```

> **💡 Note :** Sur appareil physique Android, utilisez l'IP locale de votre machine (pas `localhost`). Sur iOS, assurez-vous que les droits réseau sont configurés dans `Info.plist`.

---

## 🔑 Variables d'environnement (.env)

```env
APP_NAME=FirstApp
APP_KEY=base64:...          # Généré par php artisan key:generate
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=pgsql        # ou mysql

STRIPE_SECRET=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

MAIL_MAILER=resend
RESEND_API_KEY=re_...
MAIL_FROM_ADDRESS=noreply@exemple.com
MAIL_FROM_NAME="FirstApp"
```

---

## 📡 Routes API principales

| Méthode | Route | Auth | Description |
|---------|-------|------|-------------|
| `POST` | `/api/register` | ❌ | Inscription |
| `POST` | `/api/login` | ❌ | Connexion |
| `POST` | `/api/stripe/webhook` | ❌ | Webhook Stripe |
| `GET` | `/api/user` | ✅ | Infos utilisateur |
| `GET` | `/api/transactions` | ✅ | Historique |
| `POST` | `/api/send-money` | ✅ | Virement (avec PIN) |
| `POST` | `/api/payment/intent` | ✅ | Intent Stripe |
| `POST` | `/api/qr-payment` | ✅ | Paiement QR |

---

## 🔒 Sécurité

- Authentification via **Laravel Sanctum** (tokens Bearer)
- Virements protégés par **code PIN** (hashé en base avec bcrypt)
- Protection **CSRF** désactivée uniquement pour le webhook Stripe
- Anti-doublon sur les transactions Stripe (vérification par `payment_intent.id`)
- Tokens révoqués à chaque nouvelle connexion (session unique)

---

## 📦 Dépendances Flutter principales

```yaml
dependencies:
  http: ^1.1.0
  flutter_stripe: ^12.4.0
  shared_preferences: ^2.5.4
  qr_flutter: ^4.1.0
  mobile_scanner: ^7.2.0
```

---

## 📄 Licence

Projet académique — Université des Antilles, L3 Informatique 2025-2026.
