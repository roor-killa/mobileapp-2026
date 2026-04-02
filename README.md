# Mon projet : NodEX (portefeuille crypto) — branche `meranville`

**À l’attention de mon professeur —** je documente ici mon travail pour le rendu. Je vous remercie par avance pour la relecture.

Je présente **NodEX** dans le cadre du dépôt [mobileapp-2026](https://github.com/roor-killa/mobileapp-2026). **Mon code est sur la branche Git `meranville`** : sur GitHub, il faut choisir cette branche dans le menu déroulant (ce n’est pas toujours la branche affichée par défaut), sinon vous ne verrez pas mon dossier à jour.

**Lien du dépôt :** [https://github.com/roor-killa/mobileapp-2026.git](https://github.com/roor-killa/mobileapp-2026.git)

---

## Ce que je vous invite à consulter en priorité (rapport + oral)

Pour **juger l’ensemble du projet** (architecture, API, code expliqué ligne par ligne, captures d’écran, sitographie, annexes), **je vous demande de lire mon rapport de rendu** :

| Fichier | Rôle |
|:--------|:-----|
| [`project/crypto-wallet/RAPPORT_RENDU_NODEX.md`](project/crypto-wallet/RAPPORT_RENDU_NODEX.md) | Version Markdown (lisible sur GitHub, sommaire cliquable). |
| [`project/crypto-wallet/RAPPORT_RENDU_NODEX.pdf`](project/crypto-wallet/RAPPORT_RENDU_NODEX.pdf) | Version PDF (impression ou correction). |
| [`project/crypto-wallet/docs/NodEX.pptx`](project/crypto-wallet/docs/NodEX.pptx) | **Présentation PowerPoint** NodEX (oral / Gamma / cours). |

Si vous régénérez le PDF après une modification du `.md` : `cd project/crypto-wallet && ./genere-rapport-pdf.sh`.

---

## Comment mon application fonctionne (résumé pour vous)

Voici **comment j’ai conçu le flux**, de façon synthétique :

1. **J’ai un backend Laravel** que je lance en local avec `php artisan serve` : il expose une **API** sous `/api` (portefeuilles, virements, carte virtuelle, assistant Groq, etc.).  
2. **J’utilise Appwrite** pour la **connexion et l’inscription** : l’application obtient un **JWT** que mon API Laravel lit pour identifier l’utilisateur.  
3. **Mon application Flutter** affiche les écrans et envoie des requêtes HTTP vers l’URL de cette API (chez moi : souvent `http://127.0.0.1:8000/api` ; depuis un téléphone sur le même réseau, l’adresse IP de mon ordinateur).  
4. **J’affiche les prix des cryptos** grâce à l’**API CoinGecko** (appelée depuis l’app).  
5. **J’ai intégré Stripe** pour les paiements côté application ; **Groq** sert à l’assistant conversationnel (idéalement via Laravel pour ne pas exposer ma clé API dans l’app).

Les **commandes pour reproduire** l’environnement chez vous sont dans les sections **plus bas**. Le **détail technique** (fichiers, contrôleurs, sécurité) est dans **mon rapport**, que je vous prie de consulter pour la correction.

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

**Important :** je **ne commite jamais** le fichier `.env` : il est dans `.gitignore` pour ne pas publier mes clés sur GitHub. **Si vous voulez exécuter le projet chez vous**, vous pouvez partir de **`.env.example`** et créer un `.env` local avec vos propres paramètres.

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

*Je reste disponible si vous avez des questions sur mon implémentation ou sur la façon dont j’ai structuré le dépôt.*
