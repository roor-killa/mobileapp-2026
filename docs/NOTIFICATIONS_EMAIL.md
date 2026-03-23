# Notifications Email — MoneyTransferApp

## Vue d'ensemble

Le système de notifications email envoie automatiquement des emails HTML stylisés lors des événements clés de l'application. Les emails sont envoyés via **Mailtrap SMTP** (sandbox de développement) et peuvent être basculés vers un vrai serveur SMTP en production.

---

## Emails implémentés

| # | Événement                    | Destinataire | Sujet                                      |
| - | ------------------------------ | ------------ | ------------------------------------------ |
| 1 | Transfert reçu                | Destinataire | "Vous avez reçu X€ 💸"                   |
| 2 | Transfert envoyé              | Expéditeur  | "Votre virement de X€ a été effectué"  |
| 3 | Recharge Stripe confirmée     | Utilisateur  | "Votre compte a été crédité de X€ ✅" |
| 4 | Réinitialisation mot de passe | Utilisateur  | "Réinitialisation de votre mot de passe"  |

---

## Fichiers créés

### Mailables (Backend/app/Mail/)

```
TransferReceivedMail.php     → Email au destinataire d'un virement
TransferSentMail.php         → Email à l'expéditeur d'un virement
RechargeConfirmedMail.php    → Email après recharge Stripe confirmée
ResetPasswordMail.php        → Email avec code de réinitialisation (8 chiffres)
```

### Templates HTML (Backend/resources/views/emails/)

```
transfer-received.blade.php  → Template "Virement reçu"
transfer-sent.blade.php      → Template "Virement effectué"
recharge-confirmed.blade.php → Template "Recharge confirmée"
reset-password.blade.php     → Template "Mot de passe oublié"
```

---

## Flux par événement

### 1. Transfert reçu + envoyé

Déclenché dans `TransactionController::transfer()` après validation du transfert.

```
Alice envoie 10€ à Bob
  └─► Email 1 → bob@test.com   : "Vous avez reçu 10,00 € de Alice Martin"
  └─► sleep(1)                  : pause d'1 seconde (limite Mailtrap sandbox)
  └─► Email 2 → alice@test.com : "Votre virement de 10,00 € a été effectué"
```

**Données incluses dans l'email :**

- Montant du virement
- Nom de l'expéditeur / destinataire
- Nouveau solde (pour l'expéditeur)
- Référence de transaction (ex: `TRF-IGAFG37IDF`)
- Note optionnelle
- Date et heure

### 2. Recharge Stripe confirmée

Déclenché dans `RechargeController::webhook()` après réception de l'événement `payment_intent.succeeded` de Stripe.

```
Stripe confirme le paiement
  └─► Webhook reçu par Laravel
  └─► Solde crédité en base de données
  └─► Email → alice@test.com : "Votre compte a été crédité de 50,00 €"
```

**Données incluses dans l'email :**

- Montant crédité
- Nouveau solde disponible
- Référence Stripe (ex: `pi_3TCW5xJ3tWCwrLkg1svdkFo8`)
- Date et heure

### 3. Mot de passe oublié

Déclenché dans `PasswordResetController::forgotPassword()`.

```
Utilisateur demande un reset
  └─► Code 8 chiffres généré et hashé (bcrypt)
  └─► Email → alice@test.com : code de réinitialisation
  └─► Code expire après 15 minutes
```

---

## Configuration SMTP

Dans `Backend/.env` :

```env
MAIL_MAILER=smtp
MAIL_HOST=sandbox.smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=7072c52673c0e8
MAIL_PASSWORD=7ce55e15ac6114
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@moneytransfer.com"
MAIL_FROM_NAME="MoneyTransferApp"
```

> **Note :** Après toute modification du `.env`, relancer le container avec :
>
> ```bash
> docker-compose up -d --force-recreate app
> ```

---

## Tests avec Thunder Client + Mailtrap

### Test 1 — Transfert reçu + envoyé

**1. Login Alice**

```
POST http://localhost:8000/api/v1/auth/login
Body: { "email": "alice@test.com", "password": "password" }
```

Copier le `token` retourné.

**2. Effectuer un transfert**

```
POST http://localhost:8000/api/v1/transfer
Authorization: Bearer {token}
Body:
{
    "receiver_email": "bob@test.com",
    "amount": 1000,
    "pin": "123456",
    "note": "Test notification email"
}
```

✅ Résultat attendu : 2 emails dans Mailtrap (un pour Bob, un pour Alice)

---

### Test 2 — Recharge Stripe

**Prérequis : Stripe CLI installé et en écoute**

```bash
# Terminal 1 — écoute du webhook
C:\stripe\stripe.exe listen --forward-to http://localhost:8000/api/v1/recharge/webhook
```

**1. Créer un PaymentIntent**

```
POST http://localhost:8000/api/v1/recharge/create-intent
Authorization: Bearer {token}
Body: { "amount": 5000 }
```

Copier le `payment_intent_id` retourné.

**2. Confirmer le paiement (Terminal 2)**

```bash
C:\stripe\stripe.exe payment_intents confirm {payment_intent_id} \
  --payment-method=pm_card_visa \
  --return-url=http://localhost
```

Résultat attendu : email "Recharge confirmée" dans Mailtrap

---

### Test 3 — Mot de passe oublié

**1. Demander un code**

```
POST http://localhost:8000/api/v1/auth/forgot-password
Body: { "email": "alice@test.com" }
```

**2. Récupérer le code dans Mailtrap**

**3. Réinitialiser le mot de passe**

```
POST http://localhost:8000/api/v1/auth/reset-password
Body:
{
    "email": "alice@test.com",
    "token": "12345678",
    "password": "NouveauMdp1",
    "password_confirmation": "NouveauMdp1"
}
```

Résultat attendu : 200 OK + tous les tokens Sanctum révoqués

---

## Résultats des tests

| Test                 | Endpoint                  | Email reçu                            | Statut |
| -------------------- | ------------------------- | -------------------------------------- | ------ |
| Transfert reçu      | `POST /transfer`        | Bob : "Vous avez reçu 10,00 €"       | ✅     |
| Transfert envoyé    | `POST /transfer`        | Alice : "Virement effectué"           | ✅     |
| Recharge confirmée  | Webhook Stripe            | Alice : "Compte crédité de 50,00 €" | ✅     |
| Mot de passe oublié | `POST /forgot-password` | Alice : code 8 chiffres                | ✅     |

---

## Passage en production

Pour envoyer les emails à de vraies adresses (Gmail, etc.), remplacer dans `.env` :

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com       # ou SendGrid, Mailgun, Postmark...
MAIL_PORT=587
MAIL_USERNAME=votre@gmail.com
MAIL_PASSWORD=votre_app_password
MAIL_ENCRYPTION=tls
```

> En production, utiliser une queue Laravel (`QUEUE_CONNECTION=redis`) pour envoyer les emails en arrière-plan sans bloquer la réponse API.
