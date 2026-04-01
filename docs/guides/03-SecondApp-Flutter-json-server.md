# Guide débutant — SecondApp Flutter + json-server

**Objectif** : lancer la petite application Flutter dans **`project\secondapp`**, qui affiche des données (graphique simple, transactions…) lues sur le même type d’API que SECONDAPP (json-server sur le port **3001**).

**Important** : les données sont servies par Docker depuis le dossier **`SECONDAPP`** (fichier `docker\db.json`), pas depuis `project\secondapp` seul.

---

## Étape 1 — Prérequis

- **Flutter** installé (`flutter doctor` sans erreur bloquante).
- **Docker Desktop** démarré.

---

## Étape 2 — Démarrer json-server (Docker)

Dans un terminal :

```powershell
cd c:\Users\titou\mobileapp-2026\SECONDAPP
npm run docker:up
```

Attends quelques secondes que le conteneur soit « Running ».

---

## Étape 3 — Lancer l’app Flutter

**Nouveau** terminal :

```powershell
cd c:\Users\titou\mobileapp-2026\project\secondapp
flutter pub get
flutter run
```

Choisis **Chrome**, **Windows**, ou un **émulateur Android**.

- **Web / Windows** : l’app appelle en général `http://127.0.0.1:3001`.
- **Émulateur Android** : l’app utilise `http://10.0.2.2:3001` (localhost du PC vu depuis l’émulateur).

Sur un **vrai téléphone**, il faudrait passer l’IP de ton PC en `dart-define` (voir commentaire dans le code ou demander à un encadrant).

---

## Étape 4 — Ce que tu dois voir

### Avec Docker qui tourne

- Un **écran d’accueil** avec titre du type **SecondApp**.
- Des **barres** (données du graphique), une liste de **transactions** et d’**insights** venant de `GET /dashboard` (contenu `dashboard` dans `db.json`).

### Sans Docker (ou port 3001 fermé)

- Un message du type **Aucune donnée** avec une indication pour lancer `docker compose` dans **SECONDAPP**.
- L’app **ne plante pas** : elle reste utilisable, simplement sans contenu.

---

## Étape 5 — Bouton Actualiser

- Utilise **Actualiser** dans la barre d’app pour **relancer** la requête après avoir démarré Docker.

---

## Fichiers utiles (pour comprendre)

| Fichier | Rôle |
|---------|------|
| `project\secondapp\lib\main.dart` | Point d’entrée, thème |
| `project\secondapp\lib\config\api_config.dart` | URL de l’API selon la plateforme |
| `project\secondapp\lib\services\dashboard_api.dart` | Appel HTTP `/dashboard` |
| `project\secondapp\lib\screens\home_screen.dart` | Liste, graphique, état vide |
| `SECONDAPP\docker\db.json` | Données affichées |

---

## Différence avec SECONDAPP (web)

| | `project\secondapp` (Flutter) | `SECONDAPP` (React) |
|--|------------------------------|---------------------|
| Technologie | Dart / Flutter | React / Vite |
| Données | `/dashboard` direct ou IP adaptée | Proxy `/json-api` + même JSON |
| Facturation Odoo | Non (seulement bloc dashboard) | Oui (`/invoices`) |

Les deux peuvent coexister : un terminal Docker + un terminal Flutter + un terminal `npm run dev` pour le web.
