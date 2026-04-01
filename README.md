# UAPay (Flutter + Supabase + backend Stripe)

Ce dépôt regroupe un prototype de portefeuille numérique mobile construit autour de quatre blocs principaux :

- `mobile/` → application Flutter
- `backend/` → backend Node/Express pour Stripe et l’extension EVM (port **4000**)
- `supabase/` → schéma SQL, fonctions RPC et scripts correctifs
- `contracts/` → contrat ERC-20 BKN et scripts de déploiement Hardhat

## 1) Préparer Supabase (obligatoire)
1. Ouvre ton projet Supabase → **SQL Editor** → **New query**.
2. Colle le contenu de `supabase/schema.sql` puis clique sur **Run**.
3. Dans **Project Settings → API**, récupère l’URL du projet et la clé publique `anon`.
4. Renseigne ces valeurs dans `mobile/.env.example` ou lance Flutter avec `--dart-define`.

## Correctif important pour un projet déjà lancé
Si un paiement Stripe est bien accepté mais que le solde du wallet ne change pas, exécute :

1. `supabase/sql/live_fix_payment_and_wallets.sql` dans le SQL Editor Supabase ;
2. redémarre le backend après avoir mis à jour `backend/.env` ;
3. garde `CREDIT_ON_STATUS=true` tant que le webhook Stripe n’est pas validé de bout en bout.

Ce correctif recrée les wallets manquants, rétablit le trigger d’inscription et restaure les fonctions SQL utilisées par l’application.

## 2) Lancer le backend (terminal 1)
Depuis la racine du dépôt :

```bash
docker compose up --build
```

Si Docker garde d’anciens conteneurs :

```bash
docker compose down --remove-orphans
```

## 3) Lancer l’application Flutter (terminal 2)
```bash
cd mobile
flutter pub get
flutter run
```

## URL du backend
- Émulateur Android : `http://10.0.2.2:4000`
- Téléphone réel : `http://<IP_LOCALE_DU_PC>:4000`

Tu peux changer cette valeur via `mobile/.env.example` ou avec :

```bash
flutter run --dart-define=STRIPE_BACKEND_BASE_URL=http://<IP_LOCALE_DU_PC>:4000
```

## Point d’entrée de l’application
Le fichier principal Flutter est :

`mobile/lib/main.dart`

## Extension crypto / on-chain
L’écran d’accueil inclut une action **Crypto / On-chain**. Pour l’activer, déploie d’abord `BKNToken` depuis `contracts/hardhat-deploy`, puis configure :

- `EVM_RPC_URL`
- `EVM_CHAIN`
- `BKN_TOKEN_ADDRESS`
- `EVM_BACKEND_BASE_URL`

L’extension permet alors d’envoyer des transferts ERC-20 BKN sur le réseau de test Base Sepolia.
