# NodEX — Résumé

Application portefeuille crypto (ETH, SOL, ALGO) : app Flutter + API NestJS + auth Appwrite.

---

## Structure du projet

```
crypto-wallet/
├── backend/          API NestJS (Node.js)
├── flutter_app/      App mobile / web Flutter (NodEX)
├── prisma/           (dans backend/) Schéma et migrations base
└── RESUME.md         ce fichier
```

- **backend** : API REST sur `http://localhost:3000`
- **flutter_app** : interface utilisateur (connexion Appwrite, wallets, transferts)

---

## Application Flutter (NodEX)

- **Écrans** : Connexion / Inscription, Accueil (solde total + actifs), Wallets, Envoyer, Réglages
- **Auth** : Appwrite (email / mot de passe). Le JWT Appwrite est envoyé à l’API pour les appels protégés
- **Config** :
  - `lib/config/appwrite_config.dart` : endpoint + projectId Appwrite
  - `lib/config/api_config.dart` : URL du backend (`localhost:3000` par défaut ; à adapter pour téléphone physique)

Lancer l’app :
- Chrome : `cd flutter_app && flutter run -d chrome`
- iOS : `flutter run -d ios`

---

## API (backend NestJS)

Base URL : `http://localhost:3000`

| Méthode | Route | Auth | Description |
|--------|--------|------|-------------|
| GET | `/health` | Non | Santé du serveur |
| GET | `/wallets` | JWT Appwrite | Liste des wallets (ETH, SOL, ALGO) + soldes |
| GET | `/wallets/:id/transactions` | JWT Appwrite | Historique d’un wallet |
| GET | `/prices` | Non | Prix EUR (BTC, ETH, SOL, ALGO, USDC) depuis cache |
| POST | `/transfers` | JWT Appwrite | Envoi de crypto (body : fromWalletId, toAddress, amount, tokenSymbol, clientKeyShare) |

**Auth** : les routes protégées attendent l’en-tête `Authorization: Bearer <JWT Appwrite>`. À la première requête avec un JWT valide, l’API crée l’utilisateur en base (si besoin) et ses wallets ETH, SOL, ALGO.

Lancer l’API : `cd backend && npm run start:dev`

---

## Base de données (Supabase PostgreSQL)

- **Prisma** : schéma dans `backend/prisma/schema.prisma`
- **Tables** : User (id, email, passwordHash, name, appwriteId), Wallet (userId, chain, address, keyShareServer), Transaction, PriceCache
- **Connexion** : `DATABASE_URL` dans `backend/.env` (utiliser l’URL **pooler** Supabase, ex. port 6543)

---

## Variables d’environnement (backend/.env)

| Variable | Rôle |
|----------|------|
| `DATABASE_URL` | Connexion PostgreSQL (Supabase pooler recommandé) |
| `JWT_SECRET` | Clé pour JWT backend (register/login classiques) |
| `APPWRITE_ENDPOINT / APPWRITE_PROJECT_ID` | Secret JWT Appwrite (Settings → API) pour valider le token de l’app |
| `ALCHEMY_ETH_URL` | RPC Ethereum (soldes ETH) |
| `SOLANA_RPC_URL` | RPC Solana (soldes SOL) |
| `COINGECKO_API_URL` | API prix (pas de clé nécessaire en gratuit) |

Algorand (ALGO) utilise par défaut le TestNet public ; optionnel : `ALGO_ALGOD_SERVER`, `ALGO_ALGOD_PORT`, `ALGO_ALGOD_TOKEN`.

---

## Chaînes supportées

| Symbole | Réseau | Librairie / service |
|---------|--------|----------------------|
| ETH | Ethereum | ethers.js |
| SOL | Solana | @solana/web3.js |
| ALGO | Algorand | algosdk (AlgoKit) |

Prix : CoinGecko (BTC, ETH, SOL, ALGO, USDC).

---

## Configuration Appwrite (Flutter)

Dans `lib/config/appwrite_config.dart` : renseignez `endpoint` et `projectId` depuis votre Appwrite Console (Settings).

## Fichiers supprimés (nettoyage)

- `flutter_app/lib/services/auth_service.dart` : ancien auth backend
- `auth_service_supabase.dart`, `auth_service_pocketbase.dart` : remplacés par Appwrite
- `PRIVY_SETUP.md`, `NEON_SETUP.md`, `ARCHITECTURE.md`, `API_KEYS.md`, `SUPABASE_SETUP.md` : contenu regroupé ici ou obsolète

Le dossier `mobile/` (ancienne app Expo) peut être supprimé à la main si présent : `rm -rf mobile`.
