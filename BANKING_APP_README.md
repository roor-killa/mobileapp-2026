# MyBank - Application Bancaire Réaliste

Application mobile bancaire complète avec authentification, gestion de comptes et virements.

## 🏦 Caractéristiques

- ✅ **Authentification sécurisée** - Connexion et inscription avec validation
- ✅ **Gestion des comptes** - Plusieurs types de comptes (Chèques, Épargne, etc.)
- ✅ **Virements bancaires** - Transferts entre comptes avec numéros de référence
- ✅ **Historique des transactions** - Suivi complet des mouvements bancaires
- ✅ **Soldes en temps réel** - Mise à jour instantanée des montants
- ✅ **IBAN et numéros de compte** - Informations bancaires réalistes

## 🏗️ Architecture

```
MyBank/
├── Backend (Laravel)
│   ├── API REST sur http://localhost:8000/api
│   ├── Authentification avec Sanctum tokens
│   ├── Base de données SQLite/MySQL
│   └── Gestion des transactions
│
└── Frontend (Flutter)
    ├── Écran de connexion/inscription
    ├── Tableau de bord principal
    ├── Gestion des virements
    └── Historique des transactions
```

## 📋 Prérequis

### Backend (Laravel)
- PHP 8.2+
- Composer
- SQLite ou MySQL
- Node.js & npm

### Frontend (Flutter)
- Flutter 3.4+
- Dart SDK
- Éditeur IDE (Android Studio, VS Code)

## 🚀 Configuration et Démarrage

### 1. Configuration du Backend Laravel

```bash
cd infrastructure/back-laravel

# Installation des dépendances
composer install

# Configuration de l'environnement
cp .env.example .env
php artisan key:generate

# Migration de la base de données
php artisan migrate

# Démarrer le serveur
php artisan serve
```

L'API sera disponible sur: **http://localhost:8000/api**

### 2. Configuration du Frontend Flutter

```bash
cd project/firstapp

# Installation des dépendances
flutter pub get

# Configuration de l'URL API
# Éditer lib/config/api_config.dart et modifier baseUrl si nécessaire

# Lancer l'application
flutter run
```

## 📚 API REST Endpoints

### Authentification

```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout (protégé)
```

### Comptes Bancaires

```
GET  /api/accounts (protégé)
GET  /api/accounts/{id} (protégé)
POST /api/accounts (protégé)
```

### Transactions

```
GET  /api/transactions (protégé)
POST /api/transactions/transfer (protégé)
GET  /api/accounts/{id}/transactions (protégé)
```

## 🔐 Sécurité

- **Tokens Sanctum** - Authentification sans état basée sur les tokens
- **Validation des données** - Vérification complète des montants et comptes
- **Vérification de propriété** - Les utilisateurs ne peuvent accéder qu'à leurs comptes
- **Hashage des mots de passe** - Utilisation de bcrypt

## 📱 Flux utilisateur

### 1. Inscription
```
1. L'utilisateur entre ses informations (prénom, nom, email, téléphone, mot de passe)
2. Un compte chèques par défaut est créé automatiquement
3. Crédit initial de 1000 EUR
4. Redirection vers le tableau de bord
```

### 2. Connexion
```
1. L'utilisateur entre email et mot de passe
2. Réception d'un token d'authentification
3. Accès au tableau de bord
```

### 3. Virement
```
1. Sélection du compte source
2. Sélection du compte destination
3. Saisie du montant
4. Ajout d'une description (optionnel)
5. Confirmation et exécution
6. Numéro de référence généré automatiquement
```

## 🗄️ Schéma de Base de Données

### Table: users
```sql
- id (PK)
- first_name
- last_name
- email (UNIQUE)
- phone
- password (hashé)
- timestamps
```

### Table: accounts
```sql
- id (PK)
- user_id (FK)
- account_number (UNIQUE)
- account_type
- balance (DECIMAL)
- currency
- iban (UNIQUE)
- is_active
- timestamps
```

### Table: transactions
```sql
- id (PK)
- from_account_id (FK)
- to_account_id (FK, nullable)
- transaction_type
- amount (DECIMAL)
- description
- status
- reference_number (UNIQUE)
- transaction_date
- timestamps
```

## 🧪 Données de Test

Après la migration, vous pouvez créer des utilisateurs de test :

```php
// Utiliser le tinker de Laravel
php artisan tinker

// Créer un utilisateur test
>>> $user = User::create([
    'first_name' => 'Jean',
    'last_name' => 'Dupont',
    'email' => 'jean.dupont@example.com',
    'phone' => '0612345678',
    'password' => bcrypt('password123')
]);

>>> $user->accounts()->create([
    'account_number' => 'ACC0000000001',
    'account_type' => 'Compte Chèques',
    'balance' => 1500.00,
    'currency' => 'EUR',
    'iban' => 'FR1420041000011234567890123',
]);
```

## 🛠️ Développement

### Ajouter de nouvelles migrations

```bash
php artisan make:migration create_new_table_name
```

### Ajouter de nouveaux controllers

```bash
php artisan make:controller Api/NewController --api
```

### Renew le frontend

```bash
flutter clean
flutter pub get
flutter run
```

## 📝 Notes Important es

- L'URL de base de l'API est `http://localhost:8000/api` (modifiable dans `lib/config/api_config.dart`)
- Les tokens d'authentification sont stockés localement avec `SharedPreferences`
- Les mots de passe minimum 8 caractères
- Les montants de virement doivent être supérieurs à 0

## 🐛 Dépannage

### Erreur de connexion à l'API
- Vérifier que le serveur Laravel est en cours d'exécution
- Vérifier l'URL de la base de l'API dans `api_config.dart`
- Vérifier que CORS est correctement configuré

### Erreur de migration
```bash
php artisan migrate:rollback
php artisan migrate
```

### Flutter: Packages not found
```bash
flutter pub get
flutter pub upgrade
```

## 📧 Support

Pour toute question ou problème, consultez:
- Documentation Laravel: https://laravel.com/docs
- Documentation Flutter: https://flutter.dev/docs
- Documentation Sanctum: https://laravel.com/docs/sanctum

## 📄 Licence

Ce projet est fourni à titre d'exemple éducatif.

---

**Version:** 1.0.0  
**Dernière mise à jour:** Février 2026
