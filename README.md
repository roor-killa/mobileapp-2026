# BKN Wallet — Néobanque Flutter & API Laravel

BKN Wallet est une application mobile financière hybride développée dans le cadre d'un projet académique. Elle combine la gestion de monnaie fiat, l'investissement en cryptomonnaie et un assistant financier propulsé par l'intelligence artificielle.

L'architecture repose sur une séparation stricte entre une application mobile cliente (Flutter) et une API conteneurisée (Laravel 11 / PostgreSQL / Docker).

---

## Fonctionnalités

- **Authentification sécurisée** — Inscription et connexion gérées via tokens Laravel Sanctum.
- **Tableau de bord** — Affichage en temps réel du solde principal (EUR) et du portefeuille crypto (BKN).
- **Pockets (sous-comptes)** — Création de budgets personnalisés (ex : Vacances, Loyer) avec transferts instantanés depuis le compte principal.
- **Marché BKN** — Simulateur d'achat et de vente de la cryptomonnaie interne, avec mise à jour immédiate des soldes.
- **Assistant IA "Agent-BKN"** — Chatbot intégré propulsé par Google Gemini. Un système de prompt dynamique côté backend transmet à l'IA le contexte complet de l'utilisateur (soldes, liste des Pockets), lui permettant d'agir comme un conseiller financier personnalisé.
- **Profil & Sécurité** — Modification sécurisée du mot de passe via des modales interactives, support du Dark Mode natif.

---

## Stack technique

| Couche | Technologie |
|---|---|
| Frontend | Flutter (Dart) |
| Backend | Laravel 11 (PHP) |
| Base de données | PostgreSQL |
| Infrastructure | Docker, Docker Compose, Nginx, PHP-FPM |
| Intelligence artificielle | Google Generative AI (Gemini Flash) |

---

## Prérequis

Avant de lancer le projet, assurez-vous d'avoir installé :

1. **Docker Desktop** — doit être actif sur votre machine.
2. **Flutter SDK** — avec un émulateur Android ou un appareil physique configuré.
3. **Une clé API Google Gemini** — générée depuis [Google AI Studio](https://aistudio.google.com).

---

## 1. Lancement du backend (API Laravel via Docker)

L'environnement serveur est entièrement isolé dans Docker. Aucune installation locale de PHP ou de base de données n'est nécessaire.

```bash
# 1. Se placer dans le dossier backend
cd flutter_bank_app

# 2. Créer le fichier de configuration
cp .env.example .env
```

Ouvrez ensuite le fichier `.env` et ajoutez votre clé API Google à la fin :

```env
GEMINI_API_KEY=votre_cle_api_google_ici
```

```bash
# 3. Démarrer les conteneurs en arrière-plan
docker compose up -d

# 4. Générer la clé applicative et initialiser la base de données
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate:fresh
```

L'API est désormais disponible sur `http://localhost`.

---

## 2. Lancement de l'application mobile (Flutter)

```bash
# 1. Se placer dans le dossier frontend
cd firstapp

# 2. Installer les dépendances
flutter pub get
```

**Configuration réseau** — Ouvrez `lib/services/api_service.dart` :

- **Émulateur Android** : l'URL `http://10.0.2.2/api` est préconfigurée, aucune modification nécessaire.
- **Appareil physique** : remplacez la variable `ipWifiPC` par l'adresse IPv4 locale de votre ordinateur (ex : `192.168.1.X`). Le smartphone et l'ordinateur doivent être sur le même réseau Wi-Fi.

```bash
# 3. Lancer l'application
flutter run
```

---

## Scénario de test recommandé

Pour évaluer l'ensemble des fonctionnalités dans l'ordre :

1. **Inscription** — Créez un compte (ex : *prof@bkn.com* / *password123*).
2. **Dashboard** — Vérifiez l'affichage du solde. Un solde initial peut être injecté directement en base de données si besoin.
3. **Pockets** — Créez un sous-compte "Épargne" et transférez-y une somme depuis le solde principal.
4. **Marché** — Achetez des jetons BKN et constatez la déduction immédiate sur votre solde en euros.
5. **Assistant IA** — Posez la question : *"Combien me reste-t-il sur mon compte Épargne ?"*. L'IA répondra précisément grâce à l'injection dynamique du contexte utilisateur.
6. **Paramètres** — Ouvrez le menu via l'avatar en haut à gauche et testez la modification du mot de passe.

---

## Dépannage

**L'IA refuse de répondre (erreur `User location is not supported`)**

Google AI Studio applique des restrictions géographiques strictes, notamment depuis certains pays européens. Si l'API Gemini retourne cette erreur, l'utilisation d'un VPN localisé aux États-Unis sur la machine hôte résout généralement le problème. Le mécanisme d'injection de contexte fonctionne correctement ; seule la disponibilité géographique de l'API est en cause.

**Erreur réseau côté Flutter**

Vérifiez que Docker Desktop est bien actif. En cas de test sur appareil physique, confirmez que le smartphone et l'ordinateur partagent bien le même réseau Wi-Fi.

**Réinitialiser la base de données**

```bash
docker compose exec app php artisan migrate:fresh
```
