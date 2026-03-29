# Mon projet : NodEX (portefeuille crypto) — branche `meranville`

Je présente ici **mon travail** dans le cadre du dépôt [mobileapp-2026](https://github.com/roor-killa/mobileapp-2026). Mon code se trouve sur la branche Git **`meranville`** (ce n’est pas forcément la branche par défaut sur GitHub : il faut la sélectionner dans le menu des branches pour voir mes fichiers).

**Lien du dépôt :** [https://github.com/roor-killa/mobileapp-2026.git](https://github.com/roor-killa/mobileapp-2026.git)

---

## Ce que j’ai réalisé

J’ai développé **NodEX**, une application de **portefeuille crypto** avec les éléments suivants :

- une **application mobile** en **Flutter** (interface utilisateur, écrans, navigation) ;
- un **backend** en **Laravel** (API REST sous `/api/...`) ;
- l’**authentification** via **Appwrite** ;
- un **assistant conversationnel** branché sur **Groq** (modèle type Llama 3.1 8B) ;
- des fonctionnalités autour des **virements en euros** et d’une **carte virtuelle** (selon l’état du code dans le dépôt).

Mon objectif était d’avoir une appli utilisable en local (simulateur ou téléphone) qui dialogue avec mon API Laravel, avec une base propre pour la suite du cours ou du projet.

---

## Où se trouve mon code dans le dépôt

| Emplacement | Rôle |
|-------------|------|
| `project/crypto-wallet/flutter_app/` | Mon appli Flutter — le fichier `pubspec.yaml` est **dans ce dossier** (pas à la racine du dépôt). |
| `project/crypto-wallet/backend-laravel/` | Mon API Laravel. |
| `project/crypto-wallet/run_iphone.sh` | Script que j’utilise pour lancer sur iPhone avec une URL d’API en option. |
| `project/crypto-wallet/flutter_app/run_ios_sim.sh` | Script que j’utilise pour ouvrir le simulateur iPhone et lancer Flutter. |

J’ai aussi laissé un court `README.md` dans `project/crypto-wallet/` qui renvoie vers ce fichier pour les consignes complètes.

> **Note :** d’autres dossiers peuvent exister à la racine du dépôt (autres projets ou consignes du cours). **Mon livrable principal pour NodEX est sous `project/crypto-wallet/`.**

---

## Technologies que j’utilise

- **Flutter** — application multi-plateforme (iOS, Android, etc.).
- **Laravel (PHP)** — serveur d’API, migrations base de données.
- **Appwrite** — comptes utilisateurs / auth (configurée via fichiers d’environnement).
- **Groq** — clé API pour l’assistant IA (côté Laravel et/ou réglages dans l’app).

---

## Ce dont j’ai besoin sur ma machine (prérequis)

- [Flutter](https://docs.flutter.dev/get-started/install) (canal stable), avec `flutter doctor` sans erreurs bloquantes.
- [PHP](https://www.php.net/) 8.2 ou plus et [Composer](https://getcomposer.org/).
- Pour iOS : **Xcode** et le **Simulateur** ; pour Android : **Android Studio** (ou équivalent).
- Un compte [Appwrite](https://appwrite.io/) et les identifiants que j’ai mis dans mes fichiers de config (voir `.env.example`).
- Une clé [Groq](https://console.groq.com/keys) si je veux tester l’assistant.

---

## Comment j’installe et je lance le backend Laravel (une première fois)

Dans un terminal, depuis la racine du dépôt cloné :

```bash
cd project/crypto-wallet/backend-laravel
cp .env.example .env
php artisan key:generate
composer install
php artisan migrate
```

Ensuite j’édite le fichier **`.env`** (copié depuis l’exemple) pour y mettre :

- les paramètres de **base de données** (`DB_*`, ou SQLite si c’est ce que j’ai choisi dans l’exemple) ;
- les variables **Appwrite** attendues par le projet (comme indiqué dans `.env.example`) ;
- **`GROQ_API_KEY=`** ma clé Groq ;
- éventuellement **`GROQ_MODEL=llama-3.1-8b-instant`** (ou le modèle prévu dans l’exemple).

**Important :** je **ne commite jamais** le fichier `.env` : il est dans `.gitignore` pour ne pas publier mes mots de passe et clés sur GitHub. Pour corriger ou noter, le professeur peut partir de **`.env.example`** et recréer un `.env` local.

Pour démarrer le serveur :

```bash
php artisan serve --host=0.0.0.0
```

Souvent l’URL est **http://127.0.0.1:8000**. Si j’utilise le port **8089** :

```bash
php artisan serve --host=0.0.0.0 --port=8089
```

L’API est disponible sous **`http://<adresse>:<port>/api`** (exemple : `http://127.0.0.1:8000/api`).

---

## Comment j’installe et je lance l’application Flutter

J’ouvre un **deuxième** terminal :

```bash
cd project/crypto-wallet/flutter_app
flutter pub get
```

Pour le simulateur iPhone, depuis ce même dossier :

```bash
./run_ios_sim.sh
```

Si je teste sur un **téléphone réel** ou une autre machine sur le réseau, je dois remplacer `127.0.0.1` par **l’adresse IP de l’ordinateur qui tourne Laravel** :

```bash
./run_ios_sim.sh --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Sinon, sans script :

```bash
flutter devices
flutter run -d <identifiant_de_mon_appareil>
```

Dans l’application, j’ai aussi un menu du type **Réglages → Serveur & assistant** où je peux coller l’URL de l’API (qui doit finir par `/api`) et, si besoin, une clé Groq pour l’assistant.

---

## Comment j’enregistre mes modifications sur GitHub

Depuis la **racine** du dépôt (là où se trouve ce `README.md`) :

```bash
git status
git add .
git commit -m "Court message décrivant ce que j’ai changé"
git push origin meranville
```

Le dépôt distant que j’utilise :

```text
https://github.com/roor-killa/mobileapp-2026.git
```

Pour vérifier :

```bash
git remote -v
```

---

## Ce que je m’interdis de mettre sur Git (sécurité)

- le fichier **`backend-laravel/.env`** et toute copie avec de vrais secrets ;
- des fichiers contenant des **clés API** ou mots de passe en clair ;
- les dossiers de build Flutter (`build/`, `.dart_tool/`, etc.) — déjà exclus par `.gitignore`.

---

## Problèmes que j’ai pu rencontrer (références rapides)

| Symptôme | Ce que je vérifie |
|----------|-------------------|
| Message du type « No pubspec.yaml » | Je ne suis pas dans le bon dossier : il faut être dans `project/crypto-wallet/flutter_app`. |
| L’app ne joint pas l’API | Même Wi-Fi ; URL du type `http://IP_DE_MON_MAC:PORT/api` dans les réglages de l’app ou en `--dart-define`. |
| L’assistant ne répond pas | `GROQ_API_KEY` dans le `.env` Laravel **ou** clé saisie dans les réglages de l’app. |
| Avertissements `native_assets` / `SdkRoot` au rechargement | Souvent bénin sous Flutter iOS ; je relance un `flutter run` complet si ça bloque. |

---

## Liens utiles que j’ai consultés

- [Documentation Flutter](https://docs.flutter.dev/)
- [Documentation Laravel](https://laravel.com/docs)
- [Groq — modèles](https://console.groq.com/docs/models)
- [Appwrite](https://appwrite.io/docs)

---

*README rédigé à la première personne pour présenter mon projet au correcteur — branche **`meranville`**, projet **NodEX** sous `project/crypto-wallet/`.*
