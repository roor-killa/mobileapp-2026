# mobileapp-2026 — Applications bancaires

Monorepo regroupant **deux applications bancaires** complètes développées autour du thème finance / banque numérique : **MyBank** (application mobile Flutter + API Laravel) et **SECONDAPP** (application web React premium avec facturation et blockchain de démonstration). Le tout est accompagné d'une infrastructure Docker, de scripts d'automatisation et d'une documentation complète en français.

---

## Table des matières

1. [Vue d'ensemble du projet](#vue-densemble-du-projet)
2. [Application 1 — MyBank](#application-1--mybank)
3. [Application 2 — SECONDAPP](#application-2--secondapp)
4. [Infrastructure](#infrastructure)
5. [Démarrage rapide](#démarrage-rapide)
6. [Comptes de test](#comptes-de-test)
7. [Scripts utiles](#scripts-utiles)
8. [Arborescence du dépôt](#arborescence-du-dépôt)
9. [Dépannage](#dépannage)
10. [Documentation additionnelle](#documentation-additionnelle)

---

## Vue d'ensemble du projet

```
mobileapp-2026/
│
├── Application 1 : MyBank          (Flutter + Laravel)
│   ├── project/firstapp/           → App mobile Flutter (Dart)
│   └── infrastructure/back-laravel/ → API REST PHP (Laravel 12)
│
├── Application 2 : SECONDAPP       (React + Vite + json-server)
│   └── SECONDAPP/                  → App web TypeScript / React 18
│
├── Application 3 : SecondApp Flutter (Flutter + json-server)
│   └── project/secondapp/          → App Flutter légère (données mock)
│
└── infrastructure/
    ├── infra/                       → Docker Compose (Postgres, Nginx)
    ├── front-next/                  → Front Next.js (infrastructure)
    └── transfer-api/                → Micro-service Node.js (démo)
```

Le projet a évolué dans le temps : une première version **MyBank** a été développée et présentée, puis une **refonte complète** a mené à la création de **SECONDAPP** — interface premium, module de facturation et blockchain de démonstration intégrés.

---

## Application 1 — MyBank

> Application bancaire mobile **cross-platform** avec une API REST complète et une base de données réelle.

### Stack technique

| Composant | Technologie | Version |
|-----------|-------------|---------|
| Frontend mobile | Flutter (Dart) | SDK stable |
| Framework API | Laravel | 12.x |
| Langage backend | PHP | 8.2+ |
| Authentification | Laravel Sanctum | 4.3 |
| Base de données (dev) | SQLite | — |
| Base de données (prod) | PostgreSQL | 16 |
| État (Flutter) | Provider | — |
| Stockage sécurisé | flutter_secure_storage | — |

### Fonctionnalités

- **Authentification** : inscription, connexion, déconnexion, réinitialisation de mot de passe
- **Comptes bancaires** : liste, détail, solde en temps réel (compte courant / épargne)
- **Transactions** : historique complet par compte, filtres, catégorisation
- **Virements** : entre comptes et vers des bénéficiaires, avec validation de solde
- **Demandes de paiement** : créer, accepter, refuser
- **Chatbot IA** : interface de support client intégrée
- **Profil utilisateur** : informations personnelles, avatar, paramètres de sécurité
- **Multi-plateforme** : Android, iOS, Web, Windows, Linux, macOS

### Architecture API

```
POST   /api/auth/register          Inscription
POST   /api/auth/login             Connexion → token Sanctum
POST   /api/auth/logout            Déconnexion
POST   /api/auth/forgot-password   Réinitialisation mot de passe
POST   /api/auth/change-password   Changement mot de passe

GET    /api/accounts               Liste des comptes
GET    /api/accounts/{id}          Détail d'un compte
POST   /api/accounts               Créer un compte
POST   /api/accounts/{id}/debit    Débiter
POST   /api/accounts/{id}/credit   Créditer
GET    /api/accounts/beneficiaries Liste des bénéficiaires

GET    /api/transactions           Historique global
POST   /api/transactions/transfer  Effectuer un virement
GET    /api/accounts/{id}/transactions  Transactions d'un compte

POST   /api/payment-requests       Créer une demande
GET    /api/payment-requests       Liste des demandes
PATCH  /api/payment-requests/{id}/accept  Accepter
PATCH  /api/payment-requests/{id}/decline Refuser

POST   /api/chat                   Chatbot IA
```

### Démarrage — MyBank

**Backend (Laravel)** — dossier `infrastructure\back-laravel` :

```powershell
composer install
copy .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve --host=127.0.0.1 --port=8000
```

**Frontend Flutter** — dossier `project\firstapp` :

```powershell
flutter pub get
flutter run                    # Mobile / Bureau
flutter run -d chrome          # Navigateur web
```

> L'API sera accessible sur `http://127.0.0.1:8000/api`  
> Sur émulateur Android, utiliser `http://10.0.2.2:8000/api`

---

## Application 2 — SECONDAPP

> Interface bancaire **web premium** avec module de facturation, crypto, et une blockchain de démonstration intégrée.

### Stack technique

| Composant | Technologie | Version |
|-----------|-------------|---------|
| Framework | React | 18.3.1 |
| Build tool | Vite | 6.4.1 |
| Langage | TypeScript | — |
| Style | Tailwind CSS | 4.1.12 |
| Composants UI | Radix UI (shadcn) | — |
| Composants Material | MUI + MUI Icons | 7.3.5 |
| Icônes | Lucide React | 0.487.0 |
| Animations | Motion | 12.x |
| Graphiques | Recharts | 2.15.2 |
| Routing | React Router | 7.13.0 |
| Formulaires | React Hook Form | 7.55.0 |
| Mock data | clue/json-server (Docker) | — |
| Persistance locale | localStorage | — |

### Fonctionnalités

#### Dashboard
- Solde du compte avec courbe d'évolution mensuelle
- Liste des transactions récentes (catégorie, montant, date)
- Insights financiers (taux d'épargne, alertes dépenses, croissance)

#### Module Bancaire
- **Virements** : formulaire de transfert entre comptes
- **Cartes** : visualisation et gestion des cartes de paiement
- **Investissements** : portefeuille avec graphiques en temps réel
- **Analytics** : tableau de bord analytique complet

#### Module Facturation (`/invoices`)
Système de facturation inspiré d'Odoo :
- Gestion des partenaires / clients (nom, TVA, adresse, contacts)
- Création, édition et suppression de factures
- Brouillons éditables avec lignes d'articles
- Calcul automatique de TVA et totaux
- Persistance **localStorage** (le JSON Docker est monté en lecture seule)

#### Crypto & Blockchain
- Interface de trading crypto avec graphiques
- Achats alimentant automatiquement le mempool NexBank Chain

#### NexBank Chain (`/blockchain`)
Blockchain de démonstration 100 % locale :

| Aspect | Détail |
|--------|--------|
| Hachage | SHA-256 |
| Consensus | Preuve de travail (Proof of Work) |
| Difficulté | Configurable (défaut : 2 zéros en tête) |
| Persistance | `localStorage` (clé `secondapp-nexbank-chain-v1`) |
| Blocs | Bloc genèse + chaîne validée par `previousHash` |
| Mempool | File d'attente de transactions avant minage |
| Validation | Vérification de l'intégrité complète de la chaîne |

**Flux :**  
`Ajouter transaction → Mempool → Miner un bloc → Hash PoW → Bloc validé → Chaîne`

**Code :** `SECONDAPP/src/app/services/nexbank-chain/`  
**UI :** `SECONDAPP/src/app/components/Blockchain.tsx`

#### Autres sections
- **Profil** : gestion du compte utilisateur
- **Sécurité** : paramètres de sécurité et 2FA (interface)
- **Apparence** : thème clair / sombre

### Routes disponibles

| Route | Description |
|-------|-------------|
| `/login` | Page de connexion |
| `/signup` | Inscription |
| `/` | Dashboard principal |
| `/transfers` | Virements |
| `/crypto` | Cryptomonnaies |
| `/investments` | Investissements |
| `/cards` | Cartes bancaires |
| `/analytics` | Analytiques |
| `/security` | Sécurité |
| `/profile` | Profil utilisateur |
| `/invoices` | Facturation |
| `/blockchain` | NexBank Chain |

### Données mock (Docker)

Structure du fichier `SECONDAPP/docker/db.json` :

```
dashboard
├── balanceData     → Évolution mensuelle du solde (Jan–Jun)
├── transactions    → Liste des transactions (catégorie, montant, date)
└── insights        → Informations financières et alertes

invoicing
├── partners        → Clients / partenaires (coordonnées, TVA)
└── invoices        → Factures (lignes, montants, statuts)
```

Le service Docker `clue/json-server` expose ces données sur le port **3001**.  
Le proxy Vite (`/json-api`) redirige les appels pour éviter les problèmes CORS.

### Démarrage — SECONDAPP

```powershell
cd SECONDAPP
npm install
npm run docker:up    # Lance json-server sur le port 3001
npm run dev          # Lance Vite → http://localhost:5173
```

Arrêt du container Docker :
```powershell
npm run docker:down
```

> **Sans Docker** : l'application démarre mais le dashboard et la liste des clients seront vides (pas de données serveur). La facturation reste utilisable via localStorage.

---

## Infrastructure

### Docker Compose — Stack complète (`infrastructure/infra/`)

Pour un déploiement complet en conteneurs :

```yaml
Services :
  db        → PostgreSQL 16      (port 5432)
  backend   → Laravel (PHP-FPM)  (port 8001)
  frontend  → Next.js            (port 3000)
  nginx     → Reverse proxy      (port 8000 ← point d'entrée)
```

```powershell
cd infrastructure\infra
docker compose up -d
# Accès : http://localhost:8000
```

### Micro-service Transfer API (`infrastructure/transfer-api/`)

Service Express.js minimal pour la démonstration des transferts :
- Dépendances : Express, CORS, UUID
- Indépendant du backend Laravel principal

---

## Démarrage rapide

### Démarrage en une ligne (avec scripts PowerShell)

```powershell
# MyBank (Laravel + Flutter Web)
.\scripts\run_web.ps1

# MyBank (Laravel + émulateur Android)
.\scripts\run_emulator.ps1
```

### Démarrage manuel — récapitulatif

| Application | Commandes | URL |
|-------------|-----------|-----|
| **MyBank — Backend** | `cd infrastructure\back-laravel` → `php artisan serve` | `http://127.0.0.1:8000` |
| **MyBank — Flutter** | `cd project\firstapp` → `flutter run -d chrome` | `http://localhost:port` |
| **SECONDAPP** | `cd SECONDAPP` → `npm run docker:up && npm run dev` | `http://localhost:5173` |
| **SecondApp Flutter** | `cd project\secondapp` → `flutter run` | (nécessite json-server actif) |

---

## Comptes de test

> Après `php artisan migrate:fresh --seed` dans `infrastructure\back-laravel`

Mot de passe universel : **`password123`**

| Email | Nom |
|-------|-----|
| `jean.dupont@example.com` | Jean Dupont |
| `marie.martin@example.com` | Marie Martin |
| `pierre.bernard@example.com` | Pierre Bernard |
| `sophie.lefebvre@example.com` | Sophie Lefebvre |

### Scénario de test MyBank

1. Lancer le backend (port 8000) + l'app Flutter
2. Se connecter avec `jean.dupont@example.com`
3. Vérifier le dashboard, le détail de compte, l'historique
4. Effectuer un virement vers Marie Martin
5. Vérifier les soldes mis à jour des deux côtés

---

## Scripts utiles

Dossier `scripts\` — à exécuter depuis la racine du dépôt :

| Script | Rôle |
|--------|------|
| `run_web.ps1` | Démarre Laravel + Flutter Web (Chrome) |
| `run_emulator.ps1` | Démarre Laravel + émulateur Android + Flutter |
| `reset_db.ps1` | Réinitialise la base de données Laravel |
| `test_transfer.ps1` | Teste l'API de transfert |

---

## Arborescence du dépôt

```
mobileapp-2026/
├── README.md                        ← ce fichier
├── PROJECT_OVERVIEW.md              ← synthèse architecture / sécurité
├── docs/
│   ├── ARBRE-DU-DEPOT.md            ← arbre complet des dossiers
│   └── guides/
│       ├── LIRE-MOI-GUIDES.md       ← index des tutoriels
│       ├── 01-MyBank-Flutter-et-Laravel.md
│       ├── 02-SECONDAPP-Web-bancaire-et-facturation.md
│       └── 03-SecondApp-Flutter-json-server.md
├── scripts/                         ← automatisation PowerShell
├── project/
│   ├── firstapp/                    ← MyBank Flutter (app principale)
│   └── secondapp/                   ← Flutter + json-server (mock)
├── SECONDAPP/                       ← Application web React (refonte)
│   ├── README.md                    ← documentation SECONDAPP
│   ├── src/
│   │   └── app/
│   │       ├── components/          ← 20+ composants React
│   │       └── services/
│   │           └── nexbank-chain/   ← moteur blockchain
│   └── docker/
│       └── db.json                  ← données mock
├── infrastructure/
│   ├── back-laravel/                ← API REST MyBank (PHP)
│   ├── front-next/                  ← Front Next.js (infra)
│   ├── infra/                       ← Docker Compose (Postgres, Nginx)
│   └── transfer-api/                ← Micro-service Node.js
└── firstapp/                        ← doublon / version ancienne
```

---

## Dépannage

| Problème | Solution |
|----------|----------|
| Flutter ne joint pas l'API | Vérifier que Laravel tourne sur le port 8000 ; sur émulateur Android utiliser `10.0.2.2` à la place de `127.0.0.1` |
| `vendor/autoload.php` manquant | Exécuter `composer install` dans `infrastructure\back-laravel` |
| SECONDAPP sans données | Vérifier que Docker tourne (`npm run docker:up`) ; sinon `docker compose restart` puis rafraîchir le navigateur |
| Symlinks Flutter sous Windows | Activer le mode développeur Windows ou lancer le terminal en administrateur |
| Port 8000 déjà utilisé | Changer le port : `php artisan serve --port=8001` et mettre à jour l'URL dans la config Flutter |
| Port 3001 déjà utilisé | Modifier `docker-compose.yml` dans `SECONDAPP` et `vite.config.ts` (proxy) |

---

## Documentation additionnelle

| Document | Chemin | Description |
|----------|--------|-------------|
| Vue projet complète | [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) | Architecture, sécurité, stack détaillée |
| Arbre des fichiers | [docs/ARBRE-DU-DEPOT.md](docs/ARBRE-DU-DEPOT.md) | Arborescence complète commentée |
| Guide débutant MyBank | [docs/guides/01-MyBank-Flutter-et-Laravel.md](docs/guides/01-MyBank-Flutter-et-Laravel.md) | Setup pas à pas MyBank |
| Guide débutant SECONDAPP | [docs/guides/02-SECONDAPP-Web-bancaire-et-facturation.md](docs/guides/02-SECONDAPP-Web-bancaire-et-facturation.md) | Setup pas à pas SECONDAPP |
| Guide Flutter mock | [docs/guides/03-SecondApp-Flutter-json-server.md](docs/guides/03-SecondApp-Flutter-json-server.md) | Flutter + json-server |
| README SECONDAPP | [SECONDAPP/README.md](SECONDAPP/README.md) | Documentation détaillée SECONDAPP |
| Rapport d'utilisation | [SECONDAPP/docs/RAPPORT-UTILISATION-DETAILLE.md](SECONDAPP/docs/RAPPORT-UTILISATION-DETAILLE.md) | Rapport fonctionnel SECONDAPP |

---

*Dépôt : **mobileapp-2026** — Projet bancaire multi-applications, Flutter + React + Laravel*
