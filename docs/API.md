# API Reference — MoneyTransferApp

## Informations générales

| Paramètre | Valeur |
|---|---|
| Base URL (Docker) | `http://localhost:8000/api/v1` |
| Base URL (Émulateur Android) | `http://10.0.2.2:8000/api/v1` |
| Format | JSON |
| Authentification | Bearer Token (Laravel Sanctum) |
| Version | v1 |

### Headers communs
```
Content-Type: application/json
Accept: application/json
```

### Headers authentifiés
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
```

---

## Authentification

### POST /auth/register
Créer un nouveau compte utilisateur.

**Body**
```json
{
    "first_name": "Alice",
    "last_name": "Martin",
    "email": "alice@test.com",
    "password": "Password123",
    "password_confirmation": "Password123",
    "pin": "123456",
    "phone": "+33600000001"
}
```

**Réponse 201**
```json
{
    "message": "Compte créé avec succès.",
    "user": { ... },
    "token": "1|abc123..."
}
```

---

### POST /auth/login
Connexion et récupération du token Bearer.

**Body**
```json
{
    "email": "alice@test.com",
    "password": "password"
}
```

**Réponse 200**
```json
{
    "message": "Connexion réussie.",
    "user": {
        "id": "019ccbd8-...",
        "first_name": "Alice",
        "last_name": "Martin",
        "full_name": "Alice Martin",
        "email": "alice@test.com",
        "phone": "+33600000001",
        "balance": 140000,
        "balance_formatted": "1 400,00 €",
        "status": "active"
    },
    "token": "1|abc123..."
}
```

---

### POST /auth/logout 🔒
Déconnexion et révocation du token.

**Réponse 200**
```json
{ "message": "Déconnexion réussie." }
```

---

### GET /auth/me 🔒
Récupérer les informations de l'utilisateur connecté.

**Réponse 200**
```json
{
    "user": {
        "id": "019ccbd8-...",
        "first_name": "Alice",
        "balance_formatted": "1 400,00 €",
        ...
    }
}
```

---

### POST /auth/forgot-password
Envoyer un code de réinitialisation par email.

**Body**
```json
{ "email": "alice@test.com" }
```

**Réponse 200** (même réponse si email inconnu — anti-énumération)
```json
{ "message": "Si cet email existe, un code de réinitialisation a été envoyé." }
```

---

### POST /auth/reset-password
Réinitialiser le mot de passe avec le code reçu par email.

**Body**
```json
{
    "email": "alice@test.com",
    "token": "12345678",
    "password": "NouveauMdp1",
    "password_confirmation": "NouveauMdp1"
}
```

**Réponse 200**
```json
{ "message": "Mot de passe réinitialisé avec succès." }
```

**Erreurs possibles**
| Code | Message |
|---|---|
| 422 | Code invalide ou expiré |
| 422 | Le mot de passe doit contenir au moins une majuscule |

---

## Transfert

### POST /transfer 🔒
Envoyer de l'argent à un autre utilisateur.

**Body**
```json
{
    "receiver_email": "bob@test.com",
    "amount": 1000,
    "pin": "123456",
    "note": "Remboursement restaurant"
}
```
> `amount` en centimes (1000 = 10,00 €)

**Réponse 200**
```json
{
    "message": "Transfert effectué avec succès.",
    "transaction": {
        "id": "019d03c5-...",
        "type": "transfer",
        "status": "completed",
        "amount": 1000,
        "amount_formatted": "10,00 €",
        "reference": "TRF-IGAFG37IDF",
        "note": "Remboursement restaurant",
        "sender": { "full_name": "Alice Martin", "email": "alice@test.com" },
        "receiver": { "full_name": "David Louisy", "email": "david@test.com" },
        "blockchain_tx_id": "XZMVPOF2YL5BS3ACVWBG4EDIKJBT7L5...",
        "blockchain_explorer_url": "https://lora.algokit.io/testnet/transaction/..."
    },
    "new_balance": 130000,
    "new_balance_formatted": "1 300,00 €"
}
```

**Erreurs possibles**
| Code | Message |
|---|---|
| 422 | PIN incorrect |
| 422 | Solde insuffisant |
| 404 | Destinataire introuvable |

---

## Recharge

### POST /recharge/create-intent 🔒
Créer un PaymentIntent Stripe pour recharger le compte.

**Body**
```json
{ "amount": 5000 }
```
> `amount` en centimes (5000 = 50,00 €)

**Réponse 200**
```json
{
    "client_secret": "pi_3TCW5x_secret_...",
    "payment_intent_id": "pi_3TCW5xJ3tWCwrLkg1svdkFo8",
    "amount": 5000,
    "amount_formatted": "50,00 €"
}
```

---

### POST /recharge/webhook
Webhook Stripe déclenché automatiquement après paiement confirmé.

> ⚠️ Ne pas appeler manuellement. Stripe envoie cet événement automatiquement.
> Vérification de la signature Stripe (`STRIPE_WEBHOOK_SECRET`).

**Événement traité** : `payment_intent.succeeded`

---

## Historique

### GET /history 🔒
Récupérer l'historique des transactions.

**Query params optionnels**
```
?type=transfer    → uniquement les virements
?type=recharge    → uniquement les recharges
?type=qr_receive  → uniquement les QR reçus
```

**Réponse 200**
```json
{
    "transactions": [
        {
            "id": "...",
            "type": "transfer",
            "status": "completed",
            "amount": 1000,
            "amount_formatted": "10,00 €",
            "reference": "TRF-IGAFG37IDF",
            "created_at": "2026-03-19T01:46:27.000000Z"
        }
    ]
}
```

---

### GET /history/{id} 🔒
Récupérer le détail d'une transaction.

**Réponse 200**
```json
{
    "transaction": {
        "id": "...",
        "type": "transfer",
        "status": "completed",
        "amount": 1000,
        "sender": { ... },
        "receiver": { ... },
        "blockchain_tx_id": "...",
        ...
    }
}
```

---

## Profil

### PUT /profile 🔒
Modifier les informations du profil.

**Body**
```json
{
    "first_name": "Alice",
    "last_name": "Martin",
    "email": "alice@test.com",
    "phone": "+33600000001"
}
```

**Réponse 200**
```json
{ "message": "Profil mis à jour.", "user": { ... } }
```

---

### PUT /profile/password 🔒
Changer le mot de passe.

**Body**
```json
{
    "current_password": "password",
    "password": "NouveauMdp1",
    "password_confirmation": "NouveauMdp1"
}
```

**Réponse 200**
```json
{ "message": "Mot de passe modifié avec succès." }
```

---

### PUT /profile/pin 🔒
Changer le PIN de transaction.

**Body**
```json
{
    "current_pin": "123456",
    "pin": "654321",
    "pin_confirmation": "654321"
}
```

**Réponse 200**
```json
{ "message": "PIN modifié avec succès." }
```

---

## QR Code

### POST /qr/generate 🔒
Générer un QR code pour recevoir de l'argent.

**Body**
```json
{ "amount": 1500 }
```

**Réponse 200**
```json
{
    "token": "abc123...",
    "amount": 1500,
    "amount_formatted": "15,00 €",
    "expires_at": "2026-03-19T01:56:27.000000Z",
    "qr_data": "moneytransfer://pay?token=abc123&amount=1500"
}
```
> Le token expire après **10 secondes**.

---

### POST /qr/scan 🔒
Scanner un QR code et effectuer le paiement.

**Body**
```json
{
    "token": "abc123...",
    "pin": "123456"
}
```

**Réponse 200**
```json
{
    "message": "Paiement QR effectué avec succès.",
    "transaction": { ... },
    "new_balance": 128500,
    "new_balance_formatted": "1 285,00 €"
}
```

---

## Chatbot

### POST /chatbot/message 🔒
Envoyer un message au chatbot IA (Ollama llama3.2).

**Body**
```json
{ "message": "Quel est mon solde ?" }
```

**Réponse 200**
```json
{
    "response": "Votre solde actuel est de 1 400,00 €. Puis-je vous aider avec autre chose ?"
}
```

---

## Codes d'erreur

| Code HTTP | Signification |
|---|---|
| 200 | Succès |
| 201 | Ressource créée |
| 401 | Non authentifié (token manquant ou invalide) |
| 403 | Accès interdit |
| 404 | Ressource introuvable |
| 422 | Données invalides (voir `errors` dans la réponse) |
| 500 | Erreur serveur interne |

---

## Comptes de test

| Email | Mot de passe | PIN | Solde initial |
|---|---|---|---|
| alice@test.com | password | 123456 | 1 000,00 € |
| bob@test.com | password | 123456 | 500,00 € |

## Carte Stripe de test

| Champ | Valeur |
|---|---|
| Numéro | `4242 4242 4242 4242` |
| Date | N'importe quelle date future |
| CVC | N'importe quel chiffre (ex: 123) |
