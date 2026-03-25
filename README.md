# mobileapp-2026 — NodEX (portefeuille crypto)

Dépôt : [github.com/roor-killa/mobileapp-2026](https://github.com/roor-killa/mobileapp-2026) — branche de travail courante : **`meranville`**

Application **NodEX** : portefeuille crypto (Flutter), backend **Laravel**, auth **Appwrite**, assistant **Groq** (Llama 3.1 8B), virements EUR, carte virtuelle.

> Ancien exemple **FirstApp** (transferts) : si présent dans le dépôt, voir `project/firstapp/` et sa doc éventuelle dans l’historique Git.

## Arborescence utile

| Dossier | Rôle |
|--------|------|
| `project/crypto-wallet/flutter_app/` | Application Flutter (`pubspec.yaml` ici) |
| `project/crypto-wallet/backend-laravel/` | API Laravel (`/api/...`) |
| `project/crypto-wallet/run_iphone.sh` | Script lancement avec URL API (optionnel) |
| `project/crypto-wallet/flutter_app/run_ios_sim.sh` | Lance le simulateur iPhone automatiquement |

---

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) (stable)
- [PHP](https://www.php.net/) 8.2+ et [Composer](https://getcomposer.org/)
- Xcode + **Simulator** (pour iOS) — ou Android Studio
- Compte [Appwrite](https://appwrite.io/) (déjà configuré dans `flutter_app` / `backend-laravel` selon ton `.env`)
- Clé [Groq](https://console.groq.com/keys) pour l’assistant IA (dans le `.env` Laravel ou dans l’app, voir ci‑dessous)

---

## 1. Configuration backend (une fois)

```bash
cd project/crypto-wallet/backend-laravel
cp .env.example .env
php artisan key:generate
composer install
```

Édite **`.env`** (ne le commite jamais : il est ignoré par Git) :

- Base de données (`DB_*` ou SQLite par défaut selon l’exemple)
- **`GROQ_API_KEY=`** ta clé Groq
- **`GROQ_MODEL=llama-3.1-8b-instant`** (optionnel, défaut Laravel)

Migrations :

```bash
php artisan migrate
```

---

## 2. Lancer le serveur Laravel

Toujours dans `backend-laravel` :

```bash
php artisan serve --host=0.0.0.0
```

Par défaut l’URL est souvent **http://127.0.0.1:8000**.  
Si tu utilises le port **8089** :

```bash
php artisan serve --host=0.0.0.0 --port=8089
```

L’API est accessible sous **`http://<hôte>:<port>/api`** (ex. `http://127.0.0.1:8000/api`).

---

## 3. Lancer l’app Flutter

Ouvre un **second** terminal :

```bash
cd project/crypto-wallet/flutter_app
flutter pub get
```

**Simulateur iPhone** (depuis le même dossier) :

```bash
./run_ios_sim.sh
```

Avec une URL d’API explicite (téléphone réel ou autre machine : remplace par l’IP de ton Mac) :

```bash
./run_ios_sim.sh --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Ou manuellement :

```bash
flutter devices
flutter run -d <ID_DU_SIMULATEUR_OU_TELEPHONE>
```

Sans ligne de commande : dans l’app, **Réglages → Serveur & assistant** — colle l’URL de l’API (finissant par `/api`) et optionnellement une **clé Groq** pour l’assistant si le serveur ne répond pas.

---

## 4. Git : enregistrer et envoyer sur GitHub

Depuis la **racine du dépôt** (là où se trouve ce `README.md`) :

```bash
git status
git add .
git commit -m "Description courte de tes changements"
git push origin meranville
```

(Sur d’autres branches : `git push origin main` ou le nom de ta branche.)

**Dépôt distant :**

```text
https://github.com/roor-killa/mobileapp-2026.git
```

Pour vérifier ou ajouter le remote :

```bash
git remote -v
git remote add origin https://github.com/roor-killa/mobileapp-2026.git   # seulement si absent
```

### Ne jamais commiter

- `backend-laravel/.env` (secrets, clés)
- Fichiers contenant des **clés API** ou mots de passe
- Dossiers `build/`, `.dart_tool/` (déjà dans `.gitignore`)

---

## Dépannage rapide

| Problème | Piste |
|----------|--------|
| `No pubspec.yaml` | Tu n’es pas dans `project/crypto-wallet/flutter_app` |
| `flutter run -d ..` | `..` n’est pas un appareil : utilise `flutter devices` ou `./run_ios_sim.sh` |
| App ne joint pas l’API | Même Wi‑Fi ; URL `http://IP_DU_MAC:PORT/api` dans Réglages ou `--dart-define` |
| Assistant silencieux | `GROQ_API_KEY` dans `.env` Laravel **ou** clé Groq dans Réglages |
| Message `native_assets` / `SdkRoot` au hot reload | Avertissement Flutter iOS souvent bénin ; refaire un `flutter run` complet si besoin |

---

## Ressources

- [Documentation Flutter](https://docs.flutter.dev/)
- [Laravel](https://laravel.com/docs)
- [Groq — modèles](https://console.groq.com/docs/models)
