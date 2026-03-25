# Migration des virements NodEX

Les virements entre comptes passent par la base de données PostgreSQL (Neon).

## Configuration actuelle

Le backend utilise **Neon** (base PostgreSQL cloud) — pas besoin de PostgreSQL local.

## 1. Démarrer le backend

```bash
cd backend
npm run start:dev
```

## 2. Lancer l'app Flutter

```bash
cd flutter_app
flutter run -d web-server --web-port=8089
```

## Utilisation des virements

- **Vers un compte NodEX** : entrez l'email du destinataire → virement instantané via la base de données
- **Vers un IBAN externe** : entrez nom + IBAN → simulation (démo)
