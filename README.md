# mobileapp-2026 — Monorepo applications bancaires

Ce dépôt regroupe **plusieurs applications** autour d’un thème **banque / finance** : une app mobile **MyBank** (Flutter + Laravel), une **application web** refaite (**SECONDAPP**), une app Flutter légère branchée sur des **données mock Docker**, ainsi que des dossiers **infrastructure** (API, Docker, front Next.js).

Le projet a évolué dans le temps : une **première version** a pu être **présentée**, puis une **refonte** a mené à la création de **SECONDAPP** et à une organisation claire par dossiers.

---

## Démarrage rapide — où aller ?

| Tu veux… | Chemin important | Doc débutant |
|----------|------------------|--------------|
| **MyBank** (Flutter + API Laravel, virements réels côté API) | `project\firstapp` + `infrastructure\back-laravel` | [docs/guides/01-MyBank-Flutter-et-Laravel.md](docs/guides/01-MyBank-Flutter-et-Laravel.md) |
| **App web** bancaire + **facturation** (React, json-server) | `SECONDAPP` | [docs/guides/02-SECONDAPP-Web-bancaire-et-facturation.md](docs/guides/02-SECONDAPP-Web-bancaire-et-facturation.md) |
| **Flutter** + même JSON que le web (port 3001) | `project\secondapp` + Docker lancé depuis `SECONDAPP` | [docs/guides/03-SecondApp-Flutter-json-server.md](docs/guides/03-SecondApp-Flutter-json-server.md) |
| **Voir l’arborescence** du dépôt (arbre des dossiers) | [docs/ARBRE-DU-DEPOT.md](docs/ARBRE-DU-DEPOT.md) | — |
| **Index des guides** débutants | [docs/guides/LIRE-MOI-GUIDES.md](docs/guides/LIRE-MOI-GUIDES.md) | — |
| **Synthèse** longue (stack, sécu, scripts) | [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) | — |

**Chemin racine du dépôt (exemple Windows)** :  
`c:\Users\titou\mobileapp-2026`

---

## Structure des dossiers importants

```
mobileapp-2026/
├── README.md                 ← ce fichier
├── PROJECT_OVERVIEW.md       ← vue projet / sécurité / serveurs
├── docs/
│   ├── ARBRE-DU-DEPOT.md     ← arbre « généalogique » des dossiers
│   └── guides/               ← tutoriels pour débutants
├── scripts/                  ← PowerShell : run_web, run_emulator, etc.
├── project/
│   ├── firstapp/             ← MyBank Flutter (principal)
│   └── secondapp/            ← Flutter + json-server
├── SECONDAPP/                ← App web Vite/React (refonte + facturation Odoo-like)
├── infrastructure/
│   ├── back-laravel/         ← API MyBank (PHP)
│   ├── front-next/           ← Front Next.js (infra)
│   ├── infra/                ← docker-compose (Postgres, Nginx, …)
│   └── transfer-api/         ← API Node (démo transferts)
└── firstapp/                 ← ancien / doublon possible à la racine (vérifier avant usage)
```

*(Le détail des sous-dossiers est dans **docs/ARBRE-DU-DEPOT.md**.)*

---

## Applications en résumé

### 1. MyBank — `project\firstapp` + `infrastructure\back-laravel`

- **Flutter** : connexion, comptes, transactions, virements.
- **Laravel** : base SQLite (ou autre selon `.env`), tokens API, logique métier.
- **API** : `http://127.0.0.1:8000/api` en développement local.

### 2. SECONDAPP — `SECONDAPP\`

- **React + Vite** : interface type banque « premium » (base Figma/Make).
- **Docker** : `clue/json-server` sur le port **3001**, données dans `SECONDAPP\docker\db.json`.
- **Facturation** : écran dédié, brouillons éditables, création de factures, persistance **localStorage** pour les brouillons (fichier JSON monté en lecture seule).

### 3. SecondApp Flutter — `project\secondapp`

- Consomme **`GET /dashboard`** (même famille de données que le bloc `dashboard` du `db.json` de SECONDAPP).
- Utile pour montrer **Flutter + API mock** sans Laravel.

### 4. Infrastructure — `infrastructure\`

- **back-laravel** : cœur API MyBank.
- **infra** : composition Docker plus large (PostgreSQL, nginx, etc.) selon le `docker-compose.yml` du dossier.
- **transfer-api** : micro-service Node.
- **front-next** : front Next.js dans le même écosystème infra.

---

## Scripts utiles (Windows)

Dossier : **`scripts\`**

| Script | Rôle |
|--------|------|
| `run_web.ps1` | Démarre Laravel + Flutter **Chrome** (chemins relatifs au repo) |
| `run_emulator.ps1` | Démarre Laravel + **émulateur Android** + Flutter |
| `reset_db.ps1` | Réinitialisation base (selon implémentation) |
| `test_transfer.ps1` | Test lié aux transferts |

Ouvre PowerShell **à la racine** du repo ou adapte les chemins si tu lances les scripts depuis ailleurs.

---

## MyBank — commandes courantes (rappel)

**Backend** (`infrastructure\back-laravel`) :

```powershell
composer install
copy .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve --host=127.0.0.1 --port=8000
```

**Flutter** (`project\firstapp`) :

```powershell
flutter pub get
flutter run
```

**Comptes de test** (après seed) : mot de passe `password123` — ex. `jean.dupont@example.com`.

---

## SECONDAPP — commandes courantes (rappel)

```powershell
cd SECONDAPP
npm install
npm run docker:up
npm run dev
```

Puis ouvre l’URL affichée (souvent `http://localhost:5173`).

---

## Comptes de test (MyBank)

Mot de passe pour tous : **`password123`**

- `jean.dupont@example.com`
- `marie.martin@example.com`
- `pierre.bernard@example.com`
- `sophie.lefebvre@example.com`

---

## Scénario de test MyBank (checklist courte)

1. Backend Laravel sur le port **8000** + Flutter lancé.
2. Connexion avec Jean Dupont.
3. Vérifier dashboard, détail compte, historique.
4. Faire un **virement** vers un compte de Marie, vérifier soldes et historique.

*(Détail pas à pas : guide 01 dans `docs\guides\`.)*

---

## Dépannage rapide

- **Flutter ne joint pas l’API** : Laravel doit tourner ; port **8000** libre ; sur émulateur Android, URL hôte souvent **10.0.2.2**.
- **Erreur `vendor/autoload.php`** dans Laravel : exécute `composer install` dans `infrastructure\back-laravel`.
- **SECONDAPP sans données** : lance Docker dans `SECONDAPP` ; en cas de doute `docker compose restart` ; rafraîchis le navigateur.
- **Symlinks Flutter sous Windows** : mode développeur ou terminal administrateur.

---

## Documentation additionnelle

- **SECONDAPP** : `SECONDAPP\README.md` et rapport `SECONDAPP\docs\RAPPORT-UTILISATION-DETAILLE.md` (+ `npm run report:html` pour version imprimable).
- **Arbre des fichiers** : `docs\ARBRE-DU-DEPOT.md` (et commande `tree /F` pour une exportation complète).

---

*Dépôt : **mobileapp-2026** — dernière mise à jour structurée des chemins et guides : voir `docs\`.*
