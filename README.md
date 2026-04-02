# UAPay 

UAPay est une application mobile de type **wallet / application bancaire** développée dans le cadre d’un projet de programmation mobile.  
Le projet repose sur une architecture **full-stack** combinant :

- une **application Flutter** côté client ;
- un **backend Node.js / Express** pour la logique Stripe et les flux métiers complémentaires ;
- une **base de données Supabase / PostgreSQL** pour l’authentification, les profils, les wallets et les transactions ;
- une **extension blockchain ERC-20** de démonstration sur réseau EVM de test.

L’objectif du projet est de permettre à un utilisateur de :

- créer un compte et se connecter ;
- consulter son solde en BKN ;
- effectuer des transferts entre utilisateurs ;
- recevoir des fonds via QR code ;
- acheter des BKN via Stripe ;
- consulter l’historique des opérations ;
- recevoir des notifications ;
- utiliser un chatbot pour certains transferts ;
- explorer une extension on-chain en environnement de démonstration.

---

## 1. Fonctionnalités principales

### Authentification
- inscription ;
- connexion ;
- vérification email ;
- gestion de session utilisateur.

### Wallet BKN
- création automatique du profil et du wallet à l’inscription ;
- solde initial attribué automatiquement ;
- affichage du solde en BKN avec équivalence approximative en euros.

### Transferts internes
- transfert manuel par email ;
- transfert via QR code ;
- transfert assisté par chatbot ;
- mise à jour du solde côté expéditeur et destinataire ;
- enregistrement des opérations dans l’historique.

### Paiement Stripe
- création d’une session Stripe Checkout ;
- validation du paiement ;
- crédit automatique du wallet ;
- enregistrement de la transaction d’achat.

### Historique et notifications
- consultation des achats et transferts ;
- centre de notifications persistantes ;
- événements de type achat confirmé, paiement en attente, fonds reçus, etc.

### Extension blockchain
- préparation d’un transfert ERC-20 BKN via backend EVM ;
- réseau de démonstration Base Sepolia ;
- stockage possible des traces on-chain.

---

## 2. Architecture du projet

Le dépôt est structuré en plusieurs blocs :

- **mobile/** : application Flutter ;
- **backend/** : serveur Node.js / Express ;
- **supabase/** : schéma SQL, politiques RLS, triggers, fonctions RPC, scripts correctifs ;
- **contracts/** : contrat intelligent ERC-20 BKN et scripts Hardhat ;
- **docs/** : documentation, notes de publication et correctifs ;
- **scripts/** : scripts utilitaires.

### Vue d’ensemble
- **Flutter** gère l’interface, la navigation, les appels backend et Supabase ;
- **Supabase** gère l’authentification, les profils, les wallets, les transactions et les RPC ;
- **Express** gère Stripe, la vérification de statut de paiement et certains flux métiers ;
- **Stripe** gère le paiement hébergé ;
- **Base Sepolia / EVM** sert à la démonstration de l’extension blockchain.

---

## 3. Structure du dépôt

```text
.
├── backend/
│   ├── src/
│   ├── package.json
│   ├── Dockerfile
│   └── .env.example
├── contracts/
│   ├── BKNToken.sol
│   └── hardhat-deploy/
├── docs/
│   ├── LEGAL/
│   ├── PAYMENT_FIXES.md
│   └── PUBLISHING.md
├── mobile/
│   ├── assets/
│   ├── lib/
│   ├── test/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── linux/
│   ├── macos/
│   ├── windows/
│   └── .env.example
├── scripts/
├── supabase/
│   ├── schema.sql
│   └── sql/
└── docker-compose.yml
```

---

## 4. Technologies utilisées

- **Flutter / Dart**
- **Supabase**
- **PostgreSQL**
- **Node.js / Express**
- **Stripe**
- **Docker / Docker Compose**
- **Solidity / Hardhat**
- **Ethers.js**
- **Base Sepolia**
- **SharedPreferences / Flutter Secure Storage**

---

## 5. Mise en place du projet

### 5.1. Prérequis
Assurez-vous d’avoir installé :

- Flutter ;
- Node.js et npm ;
- Docker Desktop ;
- un projet Supabase ;
- un compte Stripe en mode test ;
- facultatif : un environnement EVM de test pour l’extension blockchain.

---

### 5.2. Configuration Supabase

Exécuter le schéma principal dans l’éditeur SQL Supabase :

```sql
supabase/schema.sql
```

Si nécessaire, exécuter aussi les scripts complémentaires :

```sql
supabase/sql/live_fix_payment_and_wallets.sql
supabase/sql/onchain_setup.sql
```

Ces scripts permettent notamment :

- de créer les tables `profiles`, `wallets`, `transactions` ;
- d’activer les politiques RLS ;
- de créer le trigger d’initialisation automatique à l’inscription ;
- de créer les fonctions RPC `user_id_by_email(...)` et `transfer_bkn(...)` ;
- d’ajouter la partie on-chain si utilisée.

---

### 5.3. Configuration du backend

Créer un fichier `.env` dans `backend/` à partir de `.env.example`.

Exemple :

```env
STRIPE_SECRET_KEY=YOUR_STRIPE_SECRET_KEY
STRIPE_WEBHOOK_SECRET=YOUR_STRIPE_WEBHOOK_SECRET
STRIPE_SUCCESS_URL=http://localhost:4000/success
STRIPE_CANCEL_URL=http://localhost:4000/cancel

SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_SERVICE_ROLE_KEY=YOUR_SUPABASE_SERVICE_ROLE_KEY

CREDIT_ON_STATUS=true
ALLOWED_ORIGINS=*
RATE_LIMIT_MAX=120
PORT=4000
EVM_RATE_LIMIT_PER_MIN=10
INITIAL_WALLET_BKN=1500
PUBLIC_BASE_URL=http://localhost:4000

EVM_RPC_URL=https://sepolia.base.org
EVM_CHAIN=base-sepolia
BKN_TOKEN_ADDRESS=YOUR_BKN_TOKEN_ADDRESS
EVM_SIGNER_PRIVATE_KEY=YOUR_TESTNET_PRIVATE_KEY
```

### Important
Ne jamais publier :
- de vraies clés Stripe ;
- la clé `service_role` Supabase ;
- des clés privées EVM ;
- des secrets de webhook.

---

### 5.4. Configuration du mobile

Le client Flutter utilise soit `--dart-define`, soit un fichier de configuration selon l’environnement.

Exemple :

```env
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY

STRIPE_PUBLISHABLE_KEY=YOUR_STRIPE_PUBLISHABLE_KEY
STRIPE_BACKEND_BASE_URL=http://127.0.0.1:4000

EVM_RPC_URL=https://sepolia.base.org
EVM_CHAIN=base-sepolia
BKN_TOKEN_ADDRESS=YOUR_BKN_TOKEN_ADDRESS
EVM_BACKEND_BASE_URL=http://127.0.0.1:4000
```

---

## 6. Lancement du backend

Depuis la racine du projet :

```bash
docker compose up --build
```

Ou manuellement depuis `backend/` :

```bash
npm install
npm start
```

Le backend est normalement exposé sur :

```text
http://localhost:4000
```

Pour Android Emulator, l’adresse côté mobile est souvent :

```text
http://10.0.2.2:4000
```

---

## 7. Lancement de l’application Flutter

Depuis `mobile/` :

```bash
flutter pub get
flutter run
```

Exemple avec `--dart-define` :

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY \
  --dart-define=STRIPE_PUBLISHABLE_KEY=YOUR_STRIPE_PUBLISHABLE_KEY \
  --dart-define=STRIPE_BACKEND_BASE_URL=http://10.0.2.2:4000
```

---

## 8. Flux métier principal

### Inscription
- création du compte via Supabase Auth ;
- trigger `handle_new_user()` ;
- création automatique du profil ;
- création automatique du wallet avec solde initial.

### Transfert BKN
- résolution du destinataire ;
- appel de la fonction RPC `transfer_bkn(...)` ;
- débit/crédit atomique ;
- écriture des transactions miroir ;
- mise à jour de l’historique et du solde.

### Achat Stripe
- création d’une session Checkout ;
- paiement via Stripe ;
- retour vers l’application ;
- vérification via `/checkout-status` ;
- crédit du wallet ;
- insertion d’une transaction de type `BUY`.

---

## 9. Correctif important du projet

Le projet a intégré un correctif majeur lié au flux de paiement Stripe.

### Problème observé
Dans certains cas, un paiement pouvait être validé chez Stripe sans que le wallet soit effectivement crédité.

### Correctifs apportés
- vérification explicite du statut de session ;
- crédit idempotent ;
- pages `/success` et `/cancel` cohérentes ;
- reconstruction automatique de wallets/profils manquants ;
- script SQL de remise en état des données.

Voir :

```text
docs/PAYMENT_FIXES.md
supabase/sql/live_fix_payment_and_wallets.sql
```

---

## 10. Partie blockchain

Le projet inclut une extension blockchain ERC-20 de démonstration.

### Ce que fait cette partie
- configuration d’un réseau EVM de test ;
- contrat ERC-20 BKN ;
- endpoint backend pour relayer un transfert on-chain ;
- stockage possible de traces de transactions on-chain.

### Limite importante
Cette partie doit être présentée comme une **extension expérimentale**.  
Elle n’est pas conçue comme une fonctionnalité de production finalisée.

---

## 11. Rapport du projet

Le rapport technique du projet peut être ajouté à la racine du dépôt ou dans un dossier dédié, selon le choix de remise.

Exemple de nom de fichier :

```text
UAPay_rapport_technique.pdf
```

---

## 12. Remarques finales

UAPay est un prototype académique avancé de portefeuille numérique.  
Le projet met en œuvre une architecture complète mêlant :

- application mobile ;
- backend ;
- base de données sécurisée ;
- paiement Stripe ;
- extension blockchain.

Le point central du projet est la fiabilisation du flux de paiement et du crédit du wallet, avec une logique distribuée cohérente entre mobile, backend, Stripe et Supabase.
