# Backend Laravel - Virements NodEX

Alternative à NestJS si celui-ci ne fonctionne pas. Utilise la **même base PostgreSQL (Neon)** que NestJS.

## Démarrer

```bash
cd project/crypto-wallet/backend-laravel
php artisan serve --port=8000
```

L'API sera disponible sur `http://localhost:8000`.

## Endpoints (préfixe /api)

| Méthode | Chemin | Description |
|---------|--------|-------------|
| GET | /api/health | Santé |
| GET | /api/virements/balance | Solde EUR |
| GET | /api/virements/me | Solde, IBAN, pseudonyme |
| GET | /api/virements/history | Historique |
| POST | /api/virements/send | Envoyer un virement |

## Utiliser avec Flutter

Dans `flutter_app/lib/config/api_config.dart`, mettre :

```dart
static const String _override = 'http://localhost:8000/api';
```

## Base de données

Utilise la même base Neon que NestJS (tables `User`, `VirementEur` créées par Prisma).
