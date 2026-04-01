# Docker (optionnel)

Ce dossier sert à illustrer un environnement local simple avec **PostgreSQL** et **Adminer**.

## Démarrer

```bash
cd mobile/docker
docker compose up -d
```

Services exposés :

- PostgreSQL : `localhost:5432`
- Adminer : `http://localhost:8080`

## Identifiants Adminer

- System : `PostgreSQL`
- Server : `db` (depuis le réseau Docker) ou `localhost` (depuis le PC)
- Username : `uapay`
- Password : `uapay`
- Database : `uapay`

## Schéma

Les scripts SQL du dossier `docker/initdb/` sont exécutés automatiquement au premier démarrage.

> Cette base Docker est indépendante de Supabase Cloud. Elle sert surtout à la démonstration locale.
