# SECONDAPP — Application bancaire web

Interface bancaire **premium** développée avec React 18 et Vite, conçue à partir d'une maquette Figma. Elle intègre un module de **facturation** inspiré d'Odoo, un espace **crypto**, ainsi qu'une **blockchain de démonstration** — NexBank Chain — entièrement locale.

Les données sont servies par un conteneur Docker **json-server** (port 3001). La facturation et la blockchain persistent dans le **localStorage** du navigateur.

---

## Table des matières

1. [Stack technique](#stack-technique)
2. [Fonctionnalités](#fonctionnalités)
3. [Architecture](#architecture)
4. [Démarrage rapide](#démarrage-rapide)
5. [NexBank Chain — détail technique](#nexbank-chain--détail-technique)
6. [Module Facturation](#module-facturation)
7. [Données mock](#données-mock)
8. [Scripts disponibles](#scripts-disponibles)
9. [Génération du rapport PDF](#génération-du-rapport-pdf)
10. [Dépannage](#dépannage)

---

## Stack technique

| Catégorie | Bibliothèque / Outil | Version |
|-----------|---------------------|---------|
| Framework UI | React | 18.3.1 |
| Build tool | Vite | 6.4.1 |
| Langage | TypeScript | — |
| Styles | Tailwind CSS | 4.1.12 |
| Composants headless | Radix UI (shadcn) | — |
| Composants Material | MUI + MUI Icons | 7.3.5 |
| Icônes | Lucide React | 0.487.0 |
| Animations | Motion | 12.x |
| Graphiques | Recharts | 2.15.2 |
| Routing | React Router | 7.13.0 |
| Formulaires | React Hook Form | 7.55.0 |
| Dates | date-fns | 3.6.0 |
| Drag & Drop | react-dnd | 16.x |
| Notifications | Sonner | 2.x |
| Confettis | canvas-confetti | 1.9.4 |
| Mock API | clue/json-server (Docker) | — |
| Persistance locale | localStorage | — |

---

## Fonctionnalités

### Dashboard (`/`)
- Affichage du solde avec graphique d'évolution mensuelle (Recharts)
- Liste des transactions récentes avec catégories et icônes
- Insights financiers : taux d'épargne, alertes sur les dépenses, croissance des investissements

### Virements (`/transfers`)
- Formulaire de transfert entre comptes
- Sélection du bénéficiaire, saisie du montant et motif

### Cartes (`/cards`)
- Visualisation des cartes bancaires (carte principale + supplémentaires)
- Détails : numéro masqué, date d'expiration, titulaire

### Investissements (`/investments`)
- Portefeuille d'investissements avec répartition
- Graphiques de performance (Recharts)

### Analytics (`/analytics`)
- Tableau de bord analytique complet
- Répartition des dépenses par catégorie
- Tendances mensuelles

### Crypto (`/crypto`)
- Interface de trading avec graphiques en temps réel
- Achat de crypto → alimente automatiquement le mempool NexBank Chain

### Facturation (`/invoices`)
- Gestion des partenaires/clients
- Création et édition de factures (brouillons)
- Calcul automatique des totaux et de la TVA
- Persistance dans localStorage

### NexBank Chain (`/blockchain`)
- Blockchain éducative locale avec SHA-256 et Proof of Work
- Voir section [NexBank Chain — détail technique](#nexbank-chain--détail-technique)

### Profil (`/profile`)
- Informations utilisateur, avatar, préférences

### Sécurité (`/security`)
- Paramètres de sécurité, activation 2FA (interface)

---

## Architecture

```
SECONDAPP/
├── src/
│   └── app/
│       ├── App.tsx
│       ├── routes.tsx              ← 12 routes définies
│       ├── components/
│       │   ├── Dashboard.tsx
│       │   ├── Invoicing.tsx
│       │   ├── Blockchain.tsx
│       │   ├── Crypto.tsx
│       │   ├── Transfers.tsx
│       │   ├── Analytics.tsx
│       │   ├── Cards.tsx
│       │   ├── Investments.tsx
│       │   ├── Login.tsx / SignUp.tsx
│       │   ├── Profile.tsx / Security.tsx
│       │   ├── charts/             ← Composants Recharts
│       │   ├── effects/            ← GlowCard, HolographicCard, AnimatedBorder…
│       │   ├── modals/
│       │   ├── ui/                 ← Composants UI réutilisables (shadcn)
│       │   └── figma/              ← Composants issus de la maquette Figma
│       ├── contexts/               ← Contextes React (auth, thème…)
│       └── services/
│           ├── dashboardApi.ts
│           ├── invoicingApi.ts
│           ├── invoicingCalculations.ts
│           ├── invoicingPersistence.ts
│           └── nexbank-chain/
│               ├── engine.ts       ← Logique blockchain (SHA-256, PoW)
│               ├── storage.ts      ← Persistance localStorage
│               ├── types.ts        ← Types TypeScript
│               ├── walletSync.ts   ← Sync avec module Crypto
│               └── index.ts
├── docker/
│   └── db.json                     ← Données mock (dashboard + invoicing)
├── docs/
│   └── RAPPORT-UTILISATION-DETAILLE.md
├── guidelines/                     ← Charte graphique / design guidelines
├── scripts/
│   ├── build-report-html.mjs
│   └── build-report-pdf.mjs
├── docker-compose.yml              ← json-server sur port 3001
└── vite.config.ts                  ← Proxy /json-api → localhost:3001
```

**Flux de données :**

```
Navigateur (React)
    ↓ fetch /json-api/*
Proxy Vite
    ↓ http://127.0.0.1:3001
Docker json-server
    ↓ lecture
docker/db.json

localStorage
    ← Factures (brouillons et créations)
    ← NexBank Chain (blocs minés, mempool)
```

---

## Démarrage rapide

### Prérequis
- Node.js ≥ 18
- Docker Desktop (actif)

### Installation et lancement

```bash
# 1. Installer les dépendances
npm install

# 2. Démarrer json-server (Docker)
npm run docker:up

# 3. Lancer le serveur de développement
npm run dev
```

Ouvrir dans le navigateur : **http://localhost:5173**

### Arrêt

```bash
npm run docker:down   # Arrête le conteneur json-server
```

### Vérification du conteneur Docker

```bash
docker ps             # Doit afficher secondapp-db (port 3001)
docker compose logs   # Voir les logs de json-server
```

> **Sans Docker** : l'application démarre. Le dashboard et la liste des clients seront vides (aucune donnée serveur). La facturation (localStorage) et la blockchain restent entièrement fonctionnelles.

---

## NexBank Chain — détail technique

NexBank Chain est une **blockchain de démonstration pédagogique** entièrement locale (aucun réseau public, aucune cryptomonnaie réelle).

### Fonctionnement

| Concept | Implémentation |
|---------|----------------|
| Hachage | SHA-256 (Web Crypto API) |
| Consensus | Proof of Work (PoW) |
| Difficulté | N zéros hexadécimaux en tête du hash (défaut N=2) |
| Bloc genèse | Premier bloc fixe, racine de la chaîne |
| Validation | Vérification `previousHash` + hash PoW de chaque bloc |
| Mempool | File d'attente des transactions en attente de minage |
| Persistance | `localStorage` → clé `secondapp-nexbank-chain-v1` |

### Flux de traitement

```
1. Ajouter une transaction
       ↓
2. Transaction enregistrée dans le Mempool
       ↓
3. Cliquer "Miner un bloc"
       ↓
4. Calcul du nonce jusqu'à : hash.startsWith("0".repeat(N))
       ↓
5. Bloc créé et ajouté à la chaîne
       ↓
6. Mempool vidé
       ↓
7. "Vérifier la chaîne" → contrôle de l'intégrité complète
```

### Intégration avec le module Crypto

Lorsqu'un **achat de cryptomonnaie** est effectué depuis `/crypto`, une transaction de type `wallet` est automatiquement ajoutée au mempool — même si l'onglet `/blockchain` n'est pas ouvert (synchronisation via `walletSync.ts`).

### Fichiers source

| Fichier | Rôle |
|---------|------|
| `nexbank-chain/engine.ts` | Logique blockchain : minage, validation, gestion de la chaîne |
| `nexbank-chain/types.ts` | Types TypeScript : `Block`, `Transaction`, `Chain` |
| `nexbank-chain/storage.ts` | Lecture / écriture dans localStorage |
| `nexbank-chain/walletSync.ts` | Synchronisation avec le module Crypto |
| `components/Blockchain.tsx` | Interface utilisateur de la blockchain |

---

## Module Facturation

Le module de facturation (`/invoices`) est inspiré du fonctionnement d'**Odoo** :

### Partenaires / Clients
- Liste complète avec nom, numéro de TVA, adresse, email, téléphone
- Données initiales chargées depuis `docker/db.json` (`invoicing.partners`)

### Factures
- Création de nouvelles factures avec sélection du partenaire
- Lignes d'articles : description, quantité, prix unitaire, taux de TVA
- Calcul automatique : sous-total HT, montant TVA, total TTC
- Brouillons modifiables à tout moment
- **Persistance localStorage** : les factures créées ou modifiées sont sauvegardées localement (le fichier `db.json` Docker est monté en lecture seule)

### Limitations
- Les données de partenaires sont en lecture seule (Docker JSON)
- Les factures persistent uniquement dans le navigateur (localStorage)
- Pas de génération PDF de facture individuelle (impression navigateur possible)

---

## Données mock

Fichier : `docker/db.json`

```json
{
  "dashboard": {
    "balanceData": [...],      // Évolution mensuelle du solde (Jan-Jun)
    "transactions": [...],     // Transactions récentes
    "insights": [...]          // Alertes et insights financiers
  },
  "invoicing": {
    "partners": [...],         // Clients / partenaires
    "invoices": [...]          // Factures initiales
  }
}
```

Le proxy Vite (défini dans `vite.config.ts`) redirige les appels `/json-api/*` vers `http://127.0.0.1:3001` pour éviter les erreurs CORS en développement.

---

## Scripts disponibles

| Commande | Description |
|----------|-------------|
| `npm run dev` | Démarre le serveur de développement Vite |
| `npm run build` | Compile l'application pour la production |
| `npm run docker:up` | Démarre le conteneur json-server (`docker compose up -d`) |
| `npm run docker:down` | Arrête le conteneur json-server |
| `npm run report:html` | Génère `docs/RAPPORT-UTILISATION-DETAILLE.html` |
| `npm run report:pdf` | Génère `docs/RAPPORT-UTILISATION-DETAILLE.pdf` (via Chrome/Edge headless) |

---

## Génération du rapport PDF

Le rapport d'utilisation détaillé peut être exporté en PDF directement depuis la machine :

```bash
# Génération complète (HTML → PDF)
npm run report:pdf
```

Cela :
1. Convertit `docs/RAPPORT-UTILISATION-DETAILLE.md` en HTML
2. Ouvre Chrome ou Edge en mode headless
3. Exporte vers `docs/RAPPORT-UTILISATION-DETAILLE.pdf`

### En l'absence de Chrome/Edge détecté

Définir la variable d'environnement avant la commande :

```bash
# Windows PowerShell
$env:CHROME_PATH = "C:\Program Files\Google\Chrome\Application\chrome.exe"
npm run report:pdf

# ou avec Edge
$env:EDGE_PATH = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
npm run report:pdf
```

### Alternative manuelle

```bash
npm run report:html
# Puis ouvrir docs/RAPPORT-UTILISATION-DETAILLE.html dans le navigateur
# Ctrl+P → Enregistrer au format PDF
```

---

## Dépannage

| Problème | Cause probable | Solution |
|----------|----------------|----------|
| Dashboard vide | json-server arrêté | `npm run docker:up` puis rafraîchir |
| Port 3001 déjà utilisé | Autre service | Modifier `docker-compose.yml` + `vite.config.ts` |
| Factures perdues | Autre navigateur / nettoyage cache | Les données sont dans localStorage du navigateur courant |
| Blockchain vide au rechargement | localStorage nettoyé | Normal si cache effacé ; repartir de zéro |
| `npm install` échoue | Version Node trop ancienne | Utiliser Node.js ≥ 18 |
| Rapport PDF vide | Chrome/Edge non trouvé | Définir `CHROME_PATH` ou `EDGE_PATH` |

---

## Documentation associée

| Document | Description |
|----------|-------------|
| [../README.md](../README.md) | README principal du monorepo |
| [docs/RAPPORT-UTILISATION-DETAILLE.md](docs/RAPPORT-UTILISATION-DETAILLE.md) | Rapport fonctionnel complet |
| [../docs/guides/02-SECONDAPP-Web-bancaire-et-facturation.md](../docs/guides/02-SECONDAPP-Web-bancaire-et-facturation.md) | Guide débutant SECONDAPP |
| [../PROJECT_OVERVIEW.md](../PROJECT_OVERVIEW.md) | Vue d'ensemble architecture |

---

*SECONDAPP — Application bancaire web premium · React 18 + Vite + TypeScript · NexBank Chain · Facturation*
