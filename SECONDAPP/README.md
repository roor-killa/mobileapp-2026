# SECONDAPP — Application bancaire web (Vite + React)

Deuxième version du projet, refaite **depuis zéro** après une première mouture déjà présentée : orientation **interface premium** (base Figma), données mock via **Docker** + **json-server**, et module **facturation** inspiré d’Odoo.

## En bref

| Élément | Détail |
|--------|--------|
| Stack | React 18, Vite 6, TypeScript, Tailwind 4, Radix/shadcn, Recharts, Motion |
| Données | `docker/db.json` servi par `clue/json-server` sur le port **3001** |
| Front | `npm run dev` → souvent **http://localhost:5173** |
| Sans Docker | L’app démarre ; **dashboard** et **clients** viennent du JSON : affichage vide côté données si le conteneur est arrêté |
| Facturation | Route `/invoices` ; brouillons **éditables** + **création** ; sauvegarde **localStorage** (le fichier JSON Docker est en lecture seule) |
| **NexBank Chain** (blockchain démo) | Route **`/blockchain`** ; chaîne locale (pas de réseau public), **SHA-256**, **preuve de travail** (difficulté configurable), **mempool**, bloc **genèse**, validation d’intégrité ; persistance **`localStorage`** (`secondapp-nexbank-chain-v1`) ; les **achats crypto** enregistrent une transaction `wallet` dans le mempool |

### NexBank Chain — détail technique

- **Code** : `src/app/services/nexbank-chain/` (`types`, `engine`, `storage`, `walletSync`) ; UI : `src/app/components/Blockchain.tsx`.
- **Flux** : ajouter des transactions → elles vont dans la file d’attente → **Miner un bloc** calcule un nonce jusqu’à ce que le hash commence par *N* zéros hex (défaut *N* = 2) → **Vérifier la chaîne** contrôle genèse, enchaînement `previousHash`, hash des blocs et PoW.
- **Intégration** : navigation **Blocks** dans la barre du bas ; depuis **Crypto**, un lien vers la chaîne ; après un achat, le mempool se met à jour (y compris si l’onglet Blockchain est déjà ouvert).

## Démarrage rapide

```bash
npm install
npm run docker:up    # ou : docker compose up -d
npm run dev
```

- API mock : `http://localhost:3001` (le navigateur passe par le **proxy Vite** `/json-api` pour éviter le CORS).
- Arrêt Docker : `npm run docker:down`

## Rapport détaillé

Le **rapport d’utilisation** complet est dans **`docs/RAPPORT-UTILISATION-DETAILLE.md`**.

**Obtenir un PDF** (sur ta machine) :

```bash
npm run report:pdf
```

Cela régénère le **HTML** depuis le Markdown puis produit **`docs/RAPPORT-UTILISATION-DETAILLE.pdf`** via Chrome ou Edge (headless). Sans navigateur détecté, définis `CHROME_PATH` ou `EDGE_PATH`.

Alternative manuelle : `npm run report:html`, puis ouvre **`docs/RAPPORT-UTILISATION-DETAILLE.html`** → **Ctrl+P** → **Enregistrer au format PDF**.

## Liens utiles

- Maquette d’origine (bundle Figma) : voir lien dans l’historique du dépôt / métadonnées du projet Make.
- Données : `docker/db.json` (`dashboard` + `invoicing.partners` / `invoicing.invoices`).
