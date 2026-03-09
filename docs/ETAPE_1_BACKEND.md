# Etape 1 — Backend Laravel + Docker

## Objectif

Mettre en place l'API REST complète qui sert de cerveau à l'application. Toutes les règles métier (transferts, soldes, sécurité) sont gérées ici.

---

## Technologies utilisées

| Technologie | Version | Rôle |
|-------------|---------|------|
| PHP | 8.2 | Langage serveur |
| Laravel | 12 | Framework MVC |
| PostgreSQL | 16 | Base de données relationnelle |
| Redis | 7 | Cache et sessions |
| Nginx | 1.25 | Serveur web (reverse proxy) |
| Docker | - | Conteneurisation |
| Laravel Sanctum | 4.x | Authentification API (tokens) |

---

## Structure des fichiers

```
Backend/
├── app/
│   ├── Http/
│   │   └── Controllers/Api/
│   │       ├── AuthController.php        ← Inscription, connexion
│   │       ├── TransactionController.php ← Transferts
│   │       ├── RechargeController.php    ← Stripe
│   │       ├── HistoryController.php     ← Historique
│   │       ├── ProfileController.php     ← Profil utilisateur
│   │       ├── QrCodeController.php      ← QR Code
│   │       └── ChatbotController.php     ← Ollama IA
│   ├── Models/
│   │   ├── User.php
│   │   ├── Transaction.php
│   │   └── QrToken.php
│   └── Services/
│       └── AlgorandService.php           ← Blockchain
├── database/
│   ├── migrations/
│   │   ├── ..._create_personal_access_tokens_table.php
│   │   ├── ..._create_users_table.php
│   │   ├── ..._create_transactions_table.php
│   │   ├── ..._create_qr_tokens_table.php
│   │   └── ..._add_blockchain_tx_id_to_transactions.php
│   └── seeders/
│       └── DatabaseSeeder.php
├── routes/
│   └── api.php
├── docker-compose.yml
├── Dockerfile
├── docker/
│   ├── entrypoint.sh
│   └── php/local.ini
├── nginx/
│   └── default.conf
└── .env.example
```

---

## Base de données

### Conception

Le solde est stocké en **centimes** (INTEGER) pour éviter les erreurs d'arrondi des virgules flottantes :

```
1000 centimes = 10,00 €
100000 centimes = 1000,00 €
```

### Migrations

#### Table `users`
```sql
id              UUID PRIMARY KEY
first_name      VARCHAR(255)
last_name       VARCHAR(255)
email           VARCHAR(255) UNIQUE
phone           VARCHAR(255) UNIQUE NULLABLE
password        VARCHAR(255)        ← bcrypt
pin_hash        VARCHAR(255)        ← bcrypt (6 chiffres)
balance         BIGINT DEFAULT 0    ← en centimes
status          ENUM(active/suspended/pending)
created_at      TIMESTAMP
```

#### Table `transactions`
```sql
id                       UUID PRIMARY KEY
sender_id                UUID → users (NULLABLE pour recharge)
receiver_id              UUID → users (NULLABLE)
amount                   BIGINT          ← en centimes
type                     ENUM(transfer/recharge/qr_send/qr_receive)
status                   ENUM(pending/completed/failed/cancelled)
reference                VARCHAR UNIQUE  ← TRF-XXXXXXXXXX
note                     VARCHAR NULLABLE
metadata                 JSON NULLABLE   ← données Stripe
sender_balance_before    BIGINT
sender_balance_after     BIGINT
receiver_balance_before  BIGINT
receiver_balance_after   BIGINT
blockchain_tx_id         VARCHAR NULLABLE ← TX Algorand
blockchain_explorer_url  VARCHAR NULLABLE ← URL Lora
created_at               TIMESTAMP
```

#### Table `qr_tokens`
```sql
id             UUID PRIMARY KEY
user_id        UUID → users
amount         BIGINT          ← montant à recevoir (centimes)
token          VARCHAR(512)    ← HMAC signé
expires_at     TIMESTAMP       ← TTL 10 secondes
is_used        BOOLEAN DEFAULT false
transaction_id UUID → transactions NULLABLE
created_at     TIMESTAMP
```

### Seeders

Deux comptes de test créés automatiquement au démarrage :

```php
alice@test.com  / password / PIN: 123456  → 1 000,00 €
bob@test.com    / password / PIN: 123456  → 500,00 €
```

---

## API REST

### Préfixe : `/api/v1/`
### Format : JSON
### Authentification : Bearer Token (Sanctum)

### Endpoints publics (sans token)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/auth/register` | Créer un compte |
| POST | `/auth/login` | Se connecter |
| POST | `/recharge/webhook` | Webhook Stripe (signature vérifiée) |

### Endpoints protégés (Bearer Token requis)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/auth/logout` | Se déconnecter |
| GET | `/auth/me` | Profil connecté |
| POST | `/transfer` | Transférer de l'argent |
| POST | `/recharge/create-intent` | Créer un paiement Stripe |
| GET | `/history` | Historique des transactions |
| GET | `/history/{id}` | Détail d'une transaction |
| PUT | `/profile` | Modifier les infos |
| PUT | `/profile/password` | Changer le mot de passe |
| PUT | `/profile/pin` | Changer le PIN |
| POST | `/qr/generate` | Générer un QR Code |
| POST | `/qr/scan` | Scanner et payer |
| POST | `/chatbot/message` | Message au chatbot |

---

## Exemples de requêtes / réponses

### Inscription

**Requête :**
```json
POST /api/v1/auth/register
{
    "first_name": "Alice",
    "last_name": "Martin",
    "email": "alice@test.com",
    "password": "Password1",
    "password_confirmation": "Password1",
    "pin": "123456"
}
```

**Réponse (201) :**
```json
{
    "message": "Inscription réussie.",
    "user": {
        "id": "019ccbd8-adca-73ef-...",
        "full_name": "Alice Martin",
        "email": "alice@test.com",
        "balance": 0,
        "balance_formatted": "0,00 €",
        "status": "active"
    },
    "token": "1|AbCdEfGhIjKlMnOpQrStUvWx..."
}
```

### Transfert d'argent

**Requête :**
```json
POST /api/v1/transfer
Authorization: Bearer {token}

{
    "receiver_email": "bob@test.com",
    "amount": 1000,
    "pin": "123456",
    "note": "Remboursement repas"
}
```

**Réponse (201) :**
```json
{
    "message": "Transfert effectué avec succès.",
    "transaction": {
        "id": "019ccea4-31ab-...",
        "type": "transfer",
        "status": "completed",
        "amount": 1000,
        "amount_formatted": "10,00 €",
        "reference": "TRF-9AYYHOCCI8",
        "blockchain_tx_id": "COBUHLC5RRW4EO3...",
        "blockchain_explorer_url": "https://lora.algokit.io/testnet/transaction/..."
    },
    "new_balance": 99000,
    "new_balance_formatted": "990,00 €"
}
```

---

## Points clés de l'implémentation

### Transaction atomique SQL

Le transfert débit/crédit est enveloppé dans une transaction SQL. Si une étape échoue, tout est annulé :

```php
DB::transaction(function () use ($sender, $receiver, $amount) {
    $sender->decrement('balance', $amount);   // Débit
    $receiver->increment('balance', $amount); // Crédit
    Transaction::create([...]);               // Historique
});
// Si une erreur → ROLLBACK automatique
```

### Cast automatique du mot de passe

```php
// Dans le modèle User
protected function casts(): array {
    return ['password' => 'hashed']; // Hash bcrypt automatique
}

// Dans le controller → pas besoin de Hash::make()
User::create(['password' => $validated['password']]);
```

### UUID partout

```php
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class User extends Authenticatable {
    use HasUuids; // UUID auto-généré à la création
}
```

Avantage des UUID vs auto-increment :
- Impossible de deviner les IDs (`/users/1`, `/users/2`...)
- Sécurité renforcée sur les endpoints

---

## Démarrage

```bash
cd Backend

# 1. Configurer l'environnement
cp .env.example .env

# 2. Lancer Docker
docker-compose up -d --build

# 3. Vérifier que tout tourne
docker-compose ps

# 4. Voir les logs du bootstrap
docker-compose logs -f app

# 5. Remettre à zéro (si besoin)
docker-compose exec app php artisan migrate:fresh --seed
```

---

## Comptes de test

| Email | Mot de passe | PIN | Solde |
|-------|-------------|-----|-------|
| alice@test.com | password | 123456 | 1 000,00 € |
| bob@test.com | password | 123456 | 500,00 € |
