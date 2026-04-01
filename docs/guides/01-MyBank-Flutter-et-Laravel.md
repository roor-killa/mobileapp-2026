# Guide débutant — MyBank (Flutter + Laravel)

**Objectif** : faire tourner l’application bancaire **MyBank** sur ton PC : connexion, comptes, transactions, virements.

## Ce que c’est

- **Flutter** (`project/firstapp`) : l’interface sur téléphone émulé, Chrome, ou Windows.
- **Laravel** (`infrastructure/back-laravel`) : le serveur qui stocke utilisateurs, comptes, virements (API REST).

Les deux doivent tourner **en même temps**.

---

## Étape 1 — Outils à installer

1. **Flutter** (SDK + Android Studio ou au moins les outils ligne de commande).
2. **PHP 8.2+** et **Composer** (pour Laravel).
3. Sur **Windows**, pour éviter une erreur de plugins Flutter : active le **mode développeur** (`Paramètres` → `Pour les développeurs` → Mode développeur) *ou* lance le terminal en administrateur.

---

## Étape 2 — Préparer le backend (une fois)

Ouvre un terminal :

```powershell
cd c:\Users\titou\mobileapp-2026\infrastructure\back-laravel
composer install
```

Si le dossier `vendor` n’existait pas, cette commande le crée (indispensable).

Puis, **la première fois seulement** :

```powershell
copy .env.example .env
php artisan key:generate
```

Crée la base SQLite si besoin :

```powershell
powershell -NoProfile -Command "if (!(Test-Path database/database.sqlite)) { New-Item -ItemType File -Path database/database.sqlite | Out-Null }"
```

Remplis la base avec les comptes de démo :

```powershell
php artisan migrate:fresh --seed
```

---

## Étape 3 — Démarrer l’API

Toujours dans `infrastructure\back-laravel` :

```powershell
php artisan serve --host=127.0.0.1 --port=8000
```

Laisse cette fenêtre ouverte. L’API est sur `http://127.0.0.1:8000/api`.

---

## Étape 4 — Lancer l’app Flutter

**Nouveau** terminal :

```powershell
cd c:\Users\titou\mobileapp-2026\project\firstapp
flutter pub get
flutter run
```

Choisis un appareil (émulateur Android, Chrome, etc.).

- Sur **Chrome / Web**, l’app utilise en général `http://127.0.0.1:8000/api`.
- Sur **émulateur Android**, elle utilise souvent `http://10.0.2.2:8000/api` (c’est l’équivalent du « localhost » de ton PC vu depuis l’émulateur).

---

## Étape 5 — Utiliser les fonctionnalités dans l’app

### Connexion

1. Ouvre l’app → écran de connexion.
2. Utilise par exemple :
   - Email : `jean.dupont@example.com`
   - Mot de passe : `password123`  
   (d’autres comptes existent : Marie, Pierre, Sophie — même mot de passe.)

### Tableau de bord

- Tu vois le **solde total** et la liste des **comptes** (chèque, épargne, etc.).
- Tu peux **masquer / afficher** le solde si l’UI le propose.

### Détail d’un compte

- **Tape** sur un compte pour voir le **détail** et l’**historique des transactions**.

### Faire un virement

1. Va dans l’écran **Virement** (ou équivalent dans le menu).
2. Choisis le **compte source** (ex. compte chèques).
3. Choisis un **bénéficiaire** (ex. un compte de Marie Martin).
4. Entre un **montant** (ex. `10.00`).
5. **Valide** et vérifie sur le tableau de bord que les **soldes** et l’**historique** ont changé.

### Si « impossible de contacter le serveur »

- Vérifie que `php artisan serve` tourne toujours sur le port **8000**.
- Vérifie qu’aucun autre programme n’utilise déjà le port 8000.

### Remettre les données à zéro

Dans `infrastructure\back-laravel` :

```powershell
php artisan migrate:fresh --seed
```

---

## Raccourci Windows

À la racine du dépôt, le script `scripts\run_web.ps1` peut lancer le backend et Flutter dans Chrome (voir le README racine).
