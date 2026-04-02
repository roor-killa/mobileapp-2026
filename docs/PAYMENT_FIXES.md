# UAPay — Correctifs paiement et wallet

## Problèmes principaux identifiés

### 1) `backend/.env.example` contenait `CREDIT_ON_STATUS=false`  
**Résultat :** un paiement Stripe pouvait réussir alors que le wallet restait inchangé lorsque le webhook n’était pas configuré ou pas reçu.

### 2) Les lignes wallet manquantes n’étaient pas réparées de façon cohérente
**Résultat :** certains comptes pouvaient échouer au chargement du solde ou afficher un mauvais solde après le premier crédit.

### 3) La logique CORS du backend ne traitait pas `ALLOWED_ORIGINS=*` comme un vrai wildcard
**Résultat :** les builds navigateur / web pouvaient être bloqués alors que la configuration semblait permissive.

### 4) Les redirections Stripe success/cancel reposaient sur des URLs de secours / placeholders
**Résultat :** le flux de retour après checkout était fragile.

---

## Ce qui a été modifié

## Flutter app

### `mobile/lib/services/supabase_service.dart`
- crée la ligne wallet à l’inscription si elle est absente ;
- recrée automatiquement un wallet manquant lors de la lecture du solde ;
- recrée automatiquement un profil manquant si nécessaire ;
- affiche un message plus clair lorsque le backend est inaccessible sur téléphone réel.

---

## Backend

### `backend/src/index.js`
- active une vraie gestion wildcard pour `ALLOWED_ORIGINS=*` ;
- ajoute des pages `/success` et `/cancel` pour Stripe Checkout ;
- active par défaut le crédit de secours Stripe sauf désactivation explicite ;
- restaure les wallets manquants avec le bon solde initial (**1500**) ;
- retourne `new_balance` après le crédit du wallet.

---

## Supabase SQL

### `supabase/sql/live_fix_payment_and_wallets.sql`
- recrée les profils et wallets manquants ;
- recrée le trigger d’inscription ;
- recrée `user_id_by_email` et `transfer_bkn` ;
- réapplique les politiques RLS utilisées par l’application mobile.

---

## Ce qu’il faut exécuter maintenant

1. Ouvrir **Supabase SQL Editor**.
2. Exécuter :

```sql
supabase/sql/live_fix_payment_and_wallets.sql
```

3. Redémarrer le backend :

```bash
docker compose down
docker compose up --build
```

4. Tester de nouveau depuis l’application.

---

## Note pour un téléphone réel

Si vous testez depuis un téléphone physique, `localhost` ou `10.0.2.2` ne pointeront pas vers votre PC. Utiliser à la place :

```bash
flutter run --dart-define=STRIPE_BACKEND_BASE_URL=http://YOUR_PC_IP:4000
