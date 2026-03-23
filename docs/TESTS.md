# Guide de Tests - MoneyTransferApp

## Prérequis

### Outils nécessaires

- **Docker Desktop** — backend Laravel en cours d'exécution
- **Thunder Client** — extension VSCode pour tester l'API
- **Android Emulator** — pour tester le frontend Flutter
- **Mailtrap** — pour vérifier les emails (sandbox.smtp.mailtrap.io)
- **Stripe CLI** — pour simuler les webhooks Stripe

### Démarrer le backend

```bash
cd Backend
./setup.sh        # premier lancement
# ou
docker-compose up -d  # relancement normal
```

### Comptes de test

| Email          | Mot de passe | PIN    | Solde initial |
| -------------- | ------------ | ------ | ------------- |
| alice@test.com | password     | 123456 | 1 000,00 €   |
| bob@test.com   | password     | 123456 | 500,00 €     |

### Carte Stripe de test

```
Numéro : 4242 4242 4242 4242
Date   : N'importe quelle date future (ex: 12/30)
CVC    : N'importe quel chiffre (ex: 123)
```

---

## 1. Authentification

### 1.1 Inscription

```
POST http://localhost:8000/api/v1/auth/register
```

```json
{
    "first_name": "Test",
    "last_name": "User",
    "email": "test@example.com",
    "password": "Password123",
    "password_confirmation": "Password123",
    "pin": "123456",
    "phone": "+33600000099"
}
```

 Attendu : `201` + token Bearer

---

### 1.2 Connexion

```
POST http://localhost:8000/api/v1/auth/login
```

```json
{
    "email": "alice@test.com",
    "password": "password"
}
```

 Attendu : `200` + token Bearer + infos utilisateur

> Copier le token pour les tests suivants.

---

### 1.3 Récupérer le profil connecté

```
GET http://localhost:8000/api/v1/auth/me
Authorization: Bearer {token}
```

 Attendu : `200` + données utilisateur avec solde

---

### 1.4 Déconnexion

```
POST http://localhost:8000/api/v1/auth/logout
Authorization: Bearer {token}
```

 Attendu : `200` + message de déconnexion

---

## 2. Mot de passe oublié

### 2.1 Demander un code de réinitialisation

```
POST http://localhost:8000/api/v1/auth/forgot-password
```

```json
{ "email": "alice@test.com" }
```

 Attendu : `200` + message générique (anti-énumération)
 Email reçu dans Mailtrap avec un code à 8 chiffres

---

### 2.2 Réinitialiser le mot de passe

```
POST http://localhost:8000/api/v1/auth/reset-password
```

```json
{
    "email": "alice@test.com",
    "token": "12345678",
    "password": "NouveauMdp1",
    "password_confirmation": "NouveauMdp1"
}
```

 Attendu : `200` + mot de passe modifié + tous les tokens révoqués

**Cas d'erreur à tester :**

| Scénario                    | Résultat attendu            |
| ---------------------------- | ---------------------------- |
| Code incorrect               | `422` Code invalide        |
| Code expiré (après 15 min) | `422` Code expiré         |
| Réutiliser le même code    | `422` Code déjà utilisé |
| Password sans majuscule      | `422` Validation échouée |

---

## 3. Transfert d'argent

### 3.1 Transfert standard

```
POST http://localhost:8000/api/v1/transfer
Authorization: Bearer {token}
```

```json
{
    "receiver_email": "bob@test.com",
    "amount": 1000,
    "pin": "123456",
    "note": "Test transfert"
}
```

 Attendu : `200` + transaction créée + nouveau solde
 2 emails dans Mailtrap (destinataire + expéditeur)
 Transaction enregistrée sur Algorand Testnet (blockchain_tx_id)

**Cas d'erreur à tester :**

| Scénario             | Body                                     | Résultat attendu               |
| --------------------- | ---------------------------------------- | ------------------------------- |
| PIN incorrect         | `"pin": "000000"`                      | `422` PIN incorrect           |
| Solde insuffisant     | `"amount": 9999999`                    | `422` Solde insuffisant       |
| Destinataire inconnu  | `"receiver_email": "inconnu@test.com"` | `404` Utilisateur introuvable |
| Se virer à soi-même | `"receiver_email": "alice@test.com"`   | `422` Erreur                  |

---

## 4. Recharge Stripe

### Prérequis — Lancer le Stripe CLI

**Terminal 1 (laisser tourner)**

```bash
C:\stripe\stripe.exe listen --forward-to http://localhost:8000/api/v1/recharge/webhook
```

Noter le `webhook signing secret` affiché (`whsec_...`) et vérifier qu'il correspond à `STRIPE_WEBHOOK_SECRET` dans `.env`.

### 4.1 Créer un PaymentIntent

```
POST http://localhost:8000/api/v1/recharge/create-intent
Authorization: Bearer {token}
```

```json
{ "amount": 5000 }
```

 Attendu : `200` + `client_secret` + `payment_intent_id`

> Copier le `payment_intent_id` (ex: `pi_3TCW5xJ3tWCwrLkg...`)

### 4.2 Confirmer le paiement

**Terminal 2**

```bash
C:\stripe\stripe.exe payment_intents confirm {payment_intent_id} --payment-method=pm_card_visa --return-url=http://localhost
```

 Attendu : `status: "succeeded"` + `amount_received: 5000`
 Email "Recharge confirmée" dans Mailtrap
 Solde Alice crédité de 50,00 €

---

## 5. Historique des transactions

### 5.1 Récupérer tout l'historique

```
GET http://localhost:8000/api/v1/history
Authorization: Bearer {token}
```

 Attendu : `200` + liste des transactions

### 5.2 Filtrer par type

```
GET http://localhost:8000/api/v1/history?type=transfer
GET http://localhost:8000/api/v1/history?type=recharge
```

 Attendu : `200` + liste filtrée

### 5.3 Détail d'une transaction

```
GET http://localhost:8000/api/v1/history/{id}
Authorization: Bearer {token}
```

 Attendu : `200` + détails complets avec blockchain_tx_id

---

## 6. Profil

### 6.1 Modifier les informations

```
PUT http://localhost:8000/api/v1/profile
Authorization: Bearer {token}
```

```json
{
    "first_name": "Alice",
    "last_name": "Dupont",
    "email": "alice@test.com",
    "phone": "+33611111111"
}
```

 Attendu : `200` + profil mis à jour

### 6.2 Changer le mot de passe

```
PUT http://localhost:8000/api/v1/profile/password
Authorization: Bearer {token}
```

```json
{
    "current_password": "password",
    "password": "NouveauMdp1",
    "password_confirmation": "NouveauMdp1"
}
```

 Attendu : `200` + mot de passe modifié

### 6.3 Changer le PIN

```
PUT http://localhost:8000/api/v1/profile/pin
Authorization: Bearer {token}
```

```json
{
    "current_pin": "123456",
    "pin": "654321",
    "pin_confirmation": "654321"
}
```

 Attendu : `200` + PIN modifié

---

## 7. QR Code

### 7.1 Générer un QR Code

Se connecter en tant que **Bob** (destinataire) et générer le QR.

```
POST http://localhost:8000/api/v1/qr/generate
Authorization: Bearer {token_bob}
```

```json
{ "amount": 1500 }
```

 Attendu : `200` + token QR (valable 10 secondes) + qr_data

### 7.2 Scanner le QR Code

Se connecter en tant que **Alice** (payeur) et scanner le QR.

```
POST http://localhost:8000/api/v1/qr/scan
Authorization: Bearer {token_alice}
```

```json
{
    "token": "{token_du_qr}",
    "pin": "123456"
}
```

 Attendu : `200` + transaction effectuée + nouveau solde

> ⚠️ Le token expire après 10 secondes — faire vite !

**Cas d'erreur à tester :**

| Scénario             | Résultat attendu             |
| --------------------- | ----------------------------- |
| Token expiré         | `422` Token expiré         |
| Token déjà utilisé | `422` Token déjà utilisé |
| PIN incorrect         | `422` PIN incorrect         |

---

## 8. Chatbot IA

### 8.1 Poser une question

```
POST http://localhost:8000/api/v1/chatbot/message
Authorization: Bearer {token}
```

```json
{ "message": "Quel est mon solde ?" }
```

 Attendu : `200` + réponse de l'IA

**Questions à tester :**

- `"Comment faire un virement ?"`
- `"Quelles sont mes dernières transactions ?"`
- `"Comment recharger mon compte ?"`

> ⚠️ Ollama doit être en cours d'exécution dans Docker (peut être lent au 1er démarrage).

---

## 9. Tests depuis l'émulateur Flutter

### Flux complet à tester dans l'app

1. **Login** → alice@test.com / password
2. **Dashboard** → vérifier solde affiché
3. **Envoyer** → saisir email bob@test.com, montant 10€, PIN 123456
4. **Recharger** → saisir 20€, carte `4242 4242 4242 4242`
5. **Historique** → vérifier les 2 transactions
6. **QR Code** → générer depuis Bob, scanner depuis Alice
7. **Chatbot** → poser une question
8. **Profil** → modifier le nom, changer le PIN
9. **Mot de passe oublié** → saisir email, récupérer code dans Mailtrap, réinitialiser
10. **Déconnexion** → vérifier retour au login

---

## Récapitulatif des résultats

| Test                    | Méthode                               | Statut |
| ----------------------- | -------------------------------------- | ------ |
| Inscription             | Thunder Client                         | ✅     |
| Connexion               | Thunder Client                         | ✅     |
| Mot de passe oublié    | Thunder Client + Mailtrap              | ✅     |
| Transfert + emails      | Thunder Client + Mailtrap              | ✅     |
| Recharge Stripe + email | Thunder Client + Stripe CLI + Mailtrap | ✅     |
| Historique              | Thunder Client                         | ✅     |
| Profil                  | Thunder Client                         | ✅     |
| QR Code                 | Thunder Client                         | ✅     |
| Chatbot                 | Thunder Client                         | ✅     |
| App Flutter complète   | Émulateur Android                     | ✅     |
