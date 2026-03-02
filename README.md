# MyBank — App bancaire Flutter + API Laravel

Application mobile de banque (réaliste, fonctionnelle) avec:
- Authentification (Laravel Sanctum tokens)
- Comptes (chèque + épargne)
- Historique des transactions
- Virement vers un bénéficiaire (autres comptes) depuis l’app

## Structure du projet
- **Backend Laravel**: `infrastructure/back-laravel`
- **App Flutter (Android)**: `project/firstapp`

## Prérequis
- Flutter installé (Android SDK + émulateur)
- PHP 8.2+ et Composer

## Lancer le backend (Laravel)
Dans un terminal:

```bash
cd infrastructure/back-laravel
composer install
```

Créer le fichier `.env` (une seule fois), générer la clé et préparer SQLite:

```bash
copy .env.example .env
php artisan key:generate
```

Créer la base SQLite si elle n’existe pas:

```bash
powershell -NoProfile -Command "if (!(Test-Path database/database.sqlite)) { New-Item -ItemType File -Path database/database.sqlite | Out-Null }"
```

Recréer la base et injecter les données de test (recommandé pour repartir propre):

```bash
php artisan migrate:fresh --seed
```

Démarrer l’API:

```bash
php artisan serve --host=127.0.0.1 --port=8000
```

L’API tourne sur `http://127.0.0.1:8000/api`.

## Lancer l’application Flutter sur l’émulateur
Dans un autre terminal:

```bash
cd project/firstapp
flutter pub get
flutter run
```

### Important (Android Emulator)
L’app utilise `10.0.2.2` pour joindre le PC hôte depuis l’émulateur:
- config: `project/firstapp/lib/config/api_config.dart`
- base URL: `http://10.0.2.2:8000/api`

Si tu utilises un **téléphone réel**, il faudra remplacer `10.0.2.2` par l’IP locale de ton PC (ex: `http://192.168.x.x:8000/api`).

## Comptes de test (déjà seedés)
Mot de passe pour tous: `password123`

- Jean Dupont — `jean.dupont@example.com`
- Marie Martin — `marie.martin@example.com`
- Pierre Bernard — `pierre.bernard@example.com`
- Sophie Lefebvre — `sophie.lefebvre@example.com`

## Scénario de test (checklist)
1. Ouvrir l’app sur l’émulateur → écran de connexion.
2. Se connecter avec `jean.dupont@example.com` / `password123`.
3. Vérifier:
   - le tableau de bord affiche les comptes et le solde total
   - cliquer sur un compte ouvre le détail + transactions
4. Faire un virement:
   - Compte source: Compte Chèques
   - Bénéficiaire: Marie Martin (un de ses comptes)
   - Montant: 10.00
   - Confirmer
5. Revenir au dashboard et vérifier que l’historique et les soldes ont changé.

## Dépannage rapide
- **L’app ne contacte pas l’API**: vérifier que Laravel tourne (`php artisan serve`) et que le port `8000` est libre.
- **Reset complet des données**: `php artisan migrate:fresh --seed`
