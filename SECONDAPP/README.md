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
npm run report:html
```

Puis ouvre **`docs/RAPPORT-UTILISATION-DETAILLE.html`** dans le navigateur → **Ctrl+P** (Imprimer) → **Enregistrer au format PDF**.

## Liens utiles

- Maquette d’origine (bundle Figma) : voir lien dans l’historique du dépôt / métadonnées du projet Make.
- Données : `docker/db.json` (`dashboard` + `invoicing.partners` / `invoicing.invoices`).
