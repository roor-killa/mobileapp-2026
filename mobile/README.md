# UAPay mobile (Flutter + Supabase)

Cette application Flutter représente le client mobile du projet UAPay. Elle propose une interface de type wallet bancaire avec :

- inscription / connexion / déconnexion ;
- consultation du solde BKN ;
- transfert entre utilisateurs ;
- réception via QR code ;
- achat de BKN via Stripe ;
- historique des transactions ;
- notifications locales ;
- écran crypto / on-chain en mode démonstration.

> Taux de démonstration : **1 BKN = 1 €**.

## 1) Pré-requis

- Flutter stable
- Android Studio ou un appareil physique
- un projet Supabase
- optionnel : Docker Desktop pour les services locaux

## 2) Configuration Supabase

Tu as deux possibilités.

### Option A — recommandée : `--dart-define`

```bash
flutter run   --dart-define=SUPABASE_URL="https://TONPROJET.supabase.co"   --dart-define=SUPABASE_ANON_KEY="TON_SUPABASE_ANON_KEY"
```

### Option B — via le fichier d’exemple

Consulte `mobile/.env.example` et reporte les mêmes valeurs dans ton environnement d’exécution.

## 3) Mise en place de la base

Dans Supabase Dashboard → **SQL Editor** :

1. exécute `supabase/sql/001_schema.sql` ;
2. vérifie que les tables `profiles`, `wallets` et `transactions` sont bien créées ;
3. active le flux d’authentification email si nécessaire.

### Erreur de limite d’emails (429)
Pendant les tests, Supabase peut répondre `email rate limit exceeded`.
Solutions possibles :
- attendre un peu entre deux inscriptions ;
- changer d’adresse email ;
- désactiver temporairement la confirmation email dans **Auth → Providers / Email**.

## 4) Lancer l’application

```bash
cd mobile
flutter pub get
flutter run
```

## 5) Docker (optionnel)
Si tu veux montrer un environnement local, regarde `mobile/docker/README_DOCKER.md`.

## 6) Clés supplémentaires (Stripe + on-chain)
Tu peux aussi lancer l’application avec ces paramètres :

- `STRIPE_PUBLISHABLE_KEY`
- `STRIPE_BACKEND_BASE_URL`
- `EVM_RPC_URL`
- `EVM_CHAIN`
- `BKN_TOKEN_ADDRESS`
- `EVM_BACKEND_BASE_URL`

Exemple complet :

```bash
flutter run   --dart-define=SUPABASE_URL="https://TONPROJET.supabase.co"   --dart-define=SUPABASE_ANON_KEY="TON_SUPABASE_ANON_KEY"   --dart-define=STRIPE_PUBLISHABLE_KEY="pk_test_xxx"   --dart-define=STRIPE_BACKEND_BASE_URL="http://127.0.0.1:4000"   --dart-define=EVM_RPC_URL="https://sepolia.base.org"   --dart-define=EVM_CHAIN="base-sepolia"   --dart-define=BKN_TOKEN_ADDRESS="0xTON_TOKEN"   --dart-define=EVM_BACKEND_BASE_URL="http://127.0.0.1:4000"
```

## 7) Écran crypto / on-chain
Un bouton **Crypto / On-chain** est disponible sur l’accueil. Pour l’activer :

```env
EVM_RPC_URL=https://sepolia.base.org
EVM_CHAIN=base-sepolia
BKN_TOKEN_ADDRESS=0xTON_TOKEN_DEPLOYE
EVM_BACKEND_BASE_URL=http://10.0.2.2:4000
```

Cet écran appelle le backend `/evm/erc20/transfer` afin de diffuser un vrai transfert ERC-20 sur testnet.
