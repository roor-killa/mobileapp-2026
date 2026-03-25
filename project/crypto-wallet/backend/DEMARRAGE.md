# Démarrer le backend NodEX

## Chemin correct

**Important** : Toutes les commandes doivent être lancées **depuis le dossier `backend`**.

### Depuis la racine du projet ("projet 1")

```bash
cd project/crypto-wallet/backend
npm run start:dev
```

### Depuis n'importe où (chemin absolu)

```bash
cd "/Users/meranville/mobileapp-2026/projet 1/project/crypto-wallet/backend"
npm run start:dev
```

### Si vous êtes déjà dans `backend`

Ne faites **pas** `cd project/crypto-wallet/backend` (ce chemin n'existe pas depuis `backend`).
Lancez directement :

```bash
npm run start:dev
```

---

## Base de données (Neon)

Le fichier `.env` est déjà configuré avec **Neon** (PostgreSQL cloud).  
Aucun PostgreSQL local n'est nécessaire.

- Si vous voyez `Can't reach database server at localhost:5432` → vous avez lancé la commande depuis le mauvais dossier (un autre `.env` est chargé).

---

## Commandes utiles

| Commande | Description |
|----------|-------------|
| `npm run start:dev` | Démarrer le serveur (port 3000) |
| `npx prisma generate` | Régénérer le client Prisma |
| `npx prisma migrate dev` | Appliquer les migrations |
| `./scripts/test-virement-api.sh` | Tester l'API virements |
