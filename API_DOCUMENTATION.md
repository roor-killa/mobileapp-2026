# 📡 Documentation API REST MyBank

Base URL: `http://localhost:8000/api`

## Authentification

Tous les endpoints marqués avec 🔒 requirent un header:
```
Authorization: Bearer {token}
```

---

## 🔐 Authentification (Public)

### Inscription

```
POST /auth/register
```

**Body:**
```json
{
  "first_name": "Jean",
  "last_name": "Dupont",
  "email": "jean@example.com",
  "phone": "0612345678",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Réponse 201:**
```json
{
  "message": "Utilisateur créé avec succès",
  "user": {
    "id": 1,
    "first_name": "Jean",
    "last_name": "Dupont",
    "email": "jean@example.com",
    "phone": "0612345678"
  },
  "token": "1|abc123def456..."
}
```

**Erreurs 422:**
- Email déjà utilisé
- Mot de passe < 8 caractères
- Champs manquants

---

### Connexion

```
POST /auth/login
```

**Body:**
```json
{
  "email": "jean@example.com",
  "password": "password123"
}
```

**Réponse 200:**
```json
{
  "message": "Connexion réussie",
  "user": {
    "id": 1,
    "first_name": "Jean",
    "last_name": "Dupont",
    "email": "jean@example.com",
    "phone": "0612345678"
  },
  "token": "1|abc123def456..."
}
```

**Erreurs 422:**
- Email/mot de passe incorrect
- Utilisateur non trouvé

---

### Déconnexion 🔒

```
POST /auth/logout
```

**Réponse 200:**
```json
{
  "message": "Déconnecté avec succès"
}
```

---

## 💳 Gestion des Comptes

### Récupérer tous les comptes 🔒

```
GET /accounts
```

**Réponse 200:**
```json
{
  "accounts": [
    {
      "id": 1,
      "account_number": "ACC0000000001",
      "account_type": "Compte Chèques",
      "balance": "1500.50",
      "currency": "EUR",
      "iban": "FR1420041000011234567890123",
      "is_active": true,
      "created_at": "2026-02-26T10:00:00Z",
      "updated_at": "2026-02-26T10:00:00Z"
    },
    {
      "id": 2,
      "account_number": "SAV0000000001",
      "account_type": "Compte d'Épargne",
      "balance": "5000.00",
      "currency": "EUR",
      "iban": "FR1420041000011234567890124",
      "is_active": true,
      "created_at": "2026-02-26T10:00:00Z",
      "updated_at": "2026-02-26T10:00:00Z"
    }
  ],
  "total_balance": "6500.50"
}
```

---

### Récupérer un compte spécifique 🔒

```
GET /accounts/{id}
```

**Réponse 200:**
```json
{
  "account": {
    "id": 1,
    "account_number": "ACC0000000001",
    "account_type": "Compte Chèques",
    "balance": "1500.50",
    "currency": "EUR",
    "iban": "FR1420041000011234567890123",
    "is_active": true,
    "created_at": "2026-02-26T10:00:00Z",
    "updated_at": "2026-02-26T10:00:00Z"
  }
}
```

**Erreurs:**
- 404: Compte non trouvé
- 403: Accès refusé (compte d'un autre utilisateur)

---

### Créer un nouveau compte 🔒

```
POST /accounts
```

**Body:**
```json
{
  "account_type": "Compte d'Épargne"
}
```

Types autorisés:
- `Compte Chèques`
- `Compte d'Épargne`
- `Compte Titre`

**Réponse 201:**
```json
{
  "message": "Compte créé avec succès",
  "account": {
    "id": 3,
    "account_number": "ACC0000000002",
    "account_type": "Compte d'Épargne",
    "balance": "0.00",
    "currency": "EUR",
    "iban": "FR1420041000011234567890125",
    "is_active": true,
    "created_at": "2026-02-26T10:00:00Z",
    "updated_at": "2026-02-26T10:00:00Z"
  }
}
```

---

## 🔄 Transactions

### Récupérer toutes les transactions 🔒

```
GET /transactions
```

**Réponse 200:**
```json
{
  "transactions": [
    {
      "id": 1,
      "from_account_id": 1,
      "to_account_id": 2,
      "transaction_type": "transfer",
      "amount": "100.00",
      "description": "Virement personnel",
      "status": "completed",
      "reference_number": "TRF0A1B2C3D4E5F",
      "transaction_date": "2026-02-26T15:30:00Z",
      "created_at": "2026-02-26T15:30:00Z",
      "updated_at": "2026-02-26T15:30:00Z"
    }
  ]
}
```

---

### Effectuer un virement 🔒

```
POST /transactions/transfer
```

**Body:**
```json
{
  "from_account_id": 1,
  "to_account_id": 2,
  "amount": 100.50,
  "description": "Remboursement restaurant"
}
```

**Réponse 201:**
```json
{
  "message": "Virement effectué avec succès",
  "transaction": {
    "id": 2,
    "from_account_id": 1,
    "to_account_id": 2,
    "transaction_type": "transfer",
    "amount": "100.50",
    "description": "Remboursement restaurant",
    "status": "completed",
    "reference_number": "Trfx1Y2Z3A4B5C6",
    "transaction_date": "2026-02-26T16:00:00Z",
    "created_at": "2026-02-26T16:00:00Z",
    "updated_at": "2026-02-26T16:00:00Z"
  },
  "from_account": {
    "id": 1,
    "balance": "1399.50"
  },
  "to_account": {
    "id": 2,
    "balance": "5100.50"
  }
}
```

**Erreurs:**
- 422: Solde insuffisant / Comptes identiques / Validation
- 403: Vous ne pouvez transférer que depuis vos propres comptes

---

### Récupérer les transactions d'un compte 🔒

```
GET /accounts/{id}/transactions
```

**Paramètres optionnels:**
```
?page=1&per_page=20
```

**Réponse 200:**
```json
{
  "account": {
    "id": 1,
    "account_number": "ACC0000000001",
    "account_type": "Compte Chèques",
    "balance": "1399.50",
    "currency": "EUR",
    "iban": "FR1420041000011234567890123",
    "is_active": true
  },
  "transactions": {
    "data": [
      {
        "id": 2,
        "from_account_id": 1,
        "to_account_id": 2,
        "transaction_type": "transfer",
        "amount": "100.50",
        "description": "Remboursement restaurant",
        "status": "completed",
        "reference_number": "TRF0A1B2C3D4E5F",
        "transaction_date": "2026-02-26T16:00:00Z"
      }
    ],
    "current_page": 1,
    "total": 5,
    "per_page": 20
  }
}
```

---

## 📋 Codes d'Erreur

| Code | Signification |
|------|---------------|
| 200 | Succès |
| 201 | Créé avec succès |
| 400 | Requête invalide |
| 401 | Non authentifié |
| 403 | Accès refusé |
| 404 | Non trouvé |
| 422 | Validation échouée |
| 500 | Erreur serveur |

---

## 🔄 Flux Exemple: Virement Complet

```
1. POST /auth/login
   → Récéption du token

2. GET /accounts
   → Récupération du compte source et destination

3. POST /transactions/transfer
   → Exécution du virement

4. GET /accounts/{id}/transactions
   → Vérification de l'historique

5. POST /auth/logout
   → Déconnexion
```

---

## 🛠️ Exemples cURL

### Inscription
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Test",
    "last_name": "User",
    "email": "test@example.com",
    "phone": "0123456789",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### Connexion
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Récupérer les comptes
```bash
curl -X GET http://localhost:8000/api/accounts \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Effectuer un virement
```bash
curl -X POST http://localhost:8000/api/transactions/transfer \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "from_account_id": 1,
    "to_account_id": 2,
    "amount": 50.00,
    "description": "Test virement"
  }'
```

---

## 📊 Modèle de Données

### User
```
- id: integer (PK)
- first_name: string
- last_name: string
- email: string (UNIQUE)
- phone: string
- password: string (bcrypt)
- created_at: timestamp
- updated_at: timestamp
```

### Account
```
- id: integer (PK)
- user_id: integer (FK)
- account_number: string (UNIQUE)
- account_type: enum
- balance: decimal(15,2)
- currency: string
- iban: string (UNIQUE)
- is_active: boolean
- created_at: timestamp
- updated_at: timestamp
```

### Transaction
```
- id: integer (PK)
- from_account_id: integer (FK)
- to_account_id: integer (FK, nullable)
- transaction_type: enum
- amount: decimal(15,2)
- description: string
- status: enum
- reference_number: string (UNIQUE)
- transaction_date: timestamp
- created_at: timestamp
- updated_at: timestamp
```

---

**Dernière mise à jour:** Février 2026
