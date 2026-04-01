# Crypto Forecast AI — Application Flutter + API FastAPI

Projet mobile : analyse crypto (CoinGecko), prédiction, banque (USD), bénéficiaires, wallet crypto (buy/sell + PnL), watchlist.

---

## 1) Prérequis

### Backend (FastAPI)
- Python 3.11+
- Environnement virtuel Python (venv)

### Frontend (Flutter)
- Flutter SDK installé (`flutter --version`)
- Android Studio / Android SDK + un émulateur Android (ou un device)

---

## 2) Structure du projet

```
mobileapp-2026-main/
├── server/                 # API FastAPI + SQLite wallet.db
│   ├── main.py
│   ├── app/                # modules (auth, db, models, schemas… selon version)
│   ├── wallet.db           # base SQLite (créée/maintenue localement)
│   └── scripts migrations  # migrate_*.py
└── project/
    └── crypto_forecast_ai/ # App Flutter
        ├── lib/
        └── pubspec.yaml
```

---

## 3) Lancer le serveur (FastAPI)

### 3.1 Aller dans le dossier serveur
```powershell
cd "C:\Users\travail\Documents\L3_informatique\Programation_Mobile\mobileapp-2026-main\server"
```

### 3.2 Activer l'environnement virtuel
```powershell
.\.venv\Scripts\Activate.ps1
```

### 3.3 Démarrer l'API
```powershell
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

### 3.4 Swagger (docs)
- Ouvre : `http://127.0.0.1:8000/docs`

---

## 4) Lancer l’application Flutter

### 4.1 Aller dans le projet Flutter
```powershell
cd "C:\Users\travail\Documents\L3_informatique\Programation_Mobile\mobileapp-2026-main\project\crypto_forecast_ai"
```

### 4.2 Installer les dépendances
```powershell
flutter pub get
```

### 4.3 Lancer sur Android (émulateur)
```powershell
flutter run
```

> BaseUrl :
> - Android Emulator : `http://10.0.2.2:8000`
> - Web : `http://127.0.0.1:8000`

---

## 5) Fonctionnalités

### 5.1 Authentification
- Inscription
- Connexion
- Profil (`/me`)
- (Optionnel) Refresh token (`/auth/refresh`) selon version du serveur

### 5.2 Marché (CoinGecko)
- Recherche crypto (saisie intelligente)
- Historique des prix (30/90/180/365 jours)
- Prédiction à horizon (3/7/14/30 jours)
- Graphique

### 5.3 Banque (USD)
- Solde USD
- Transactions
- Transfert entre utilisateurs
- Bénéficiaires : ajout / suppression / liste / utilisation

### 5.4 Wallet crypto
- Achat / vente (buy / sell)
- Positions (holdings)
- PnL par crypto : `+163` / `-163` (USD + %)
- (Optionnel) ordres simulés : limit / stop-loss / take-profit

### 5.5 Watchlist / Favoris
- Ajout ⭐ depuis la recherche
- Liste de coins suivis + prix + variation (si activé)

---

## 6) Migrations SQLite (important)

SQLite ne met pas à jour automatiquement les tables existantes.
Si tu as des erreurs du type :
- `sqlite3.OperationalError: no such column ...`

Alors il faut lancer les scripts de migration.

### 6.1 Migration bénéficiaires (exemple)
```powershell
cd "..\server"
.\.venv\Scripts\Activate.ps1
python migrate_beneficiaries.py
```

### 6.2 Autres migrations
Si ton projet fournit d’autres scripts `migrate_*.py` :
```powershell
python migrate_add_columns.py
python migrate_wallet_schema.py
```

> Astuce : après un gros changement, si tu es en mode “démo” et que tu peux perdre la DB,
> tu peux supprimer `wallet.db` pour repartir de zéro (⚠️ supprime comptes/transactions).

---

## 7) Problèmes courants & solutions

### 7.1 Login OK mais endpoints protégés en 401
Symptôme dans les logs :
- `POST /auth/login 200`
- puis `GET /me 401`, `GET /wallet 401`, `GET /bank/balance 401`

Cause : token invalide (payload `sub` mal formé).
Fix : vérifier la génération token côté serveur :
- `create_access_token(user.id)` (et pas un dict)

### 7.2 Solde affiché à 0$ dans l’app
Si la DB contient bien les soldes mais l’app affiche 0 :
- c’est souvent parce que les endpoints `GET /bank/balance` / `GET /wallet` sont en 401
- donc le token n’est pas utilisé/stocké correctement côté Flutter.

### 7.3 Inscription ne connecte pas automatiquement
Le endpoint `/auth/register` crée un utilisateur, mais ne renvoie pas de token.
Solution : après register, faire un `login()` automatique puis sauvegarder le token.

---

## 8) Endpoints (résumé)

### Auth
- `POST /auth/register`
- `POST /auth/login`
- `GET /me`
- (optionnel) `POST /auth/refresh`

### Bank
- `GET /bank/balance`
- `POST /bank/transfer`
- `GET /bank/transactions?limit=30`
- `GET /bank/beneficiaries`
- `POST /bank/beneficiaries`
- `DELETE /bank/beneficiaries/{id}`

### Market
- `GET /search?query=...`
- `GET /history/{coin_id}?days=...`
- `GET /predict/{coin_id}?horizon=...`
- `GET /prices?ids=btc,eth,...`

### Wallet
- `GET /wallet`
- `POST /trade/buy`
- `POST /trade/sell`

---

## 9) Captures à mettre dans le rapport

### API / Swagger
- `/docs` (liste endpoints)
- `POST /auth/login` (200 OK + token)
- `GET /me` (200 OK)
- `GET /bank/balance` (200 OK)
- `GET /wallet` (200 OK + holdings + pnl)

### App
- Login screen
- Analyse (Aperçu + graphique)
- MarketSearchScreen (saisie intelligente)
- Banque (solde + transactions)
- Bénéficiaires (liste + ajout + bouton “utiliser”)
- Wallet (positions + PnL)
- Achat crypto (saisie intelligente)

---

## 10) Auteur
- Noah Tally
- Licence Informatique / Projet Flutter + FastAPI
