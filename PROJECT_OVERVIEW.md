### MyBank — Application bancaire mobile + APIs

Application de **banque personnelle** complète, composée d’une app Flutter et de plusieurs backends (Laravel + Node), avec scripts pour tout lancer facilement sous Windows.

---

## Vue d’ensemble

- **App mobile Flutter**: gestion de comptes bancaires (chèque / épargne), historique des transactions, virements.
- **Backend principal (Laravel)**: API REST sécurisée (auth token, comptes, transactions, virements).
- **API de transfert (Node/Express)**: micro-service simplifié de transferts d’argent.
- **Scripts PowerShell**: démarrage guidé du backend et de l’app (web et émulateur Android).

---

## Architecture & dossiers

- **Backend Laravel**: `infrastructure/back-laravel`  
  - Authentification (Laravel Sanctum / tokens)
  - Gestion des utilisateurs, comptes & transactions
  - Migrations + seeds de données de test
  - Exposé sur `http://127.0.0.1:8000/api`

- **API de transfert Node**: `infrastructure/transfer-api`  
  - Simple API Express (`server.js`)
  - `npm run start` pour lancer sur un port (ex: `http://127.0.0.1:3000`)

- **App Flutter (MyBank)**: `project/firstapp`  
  - Cible Android + Web (Chrome)
  - App de type “banque en ligne” avec écrans :
    - Connexion
    - Dashboard comptes
    - Détail d’un compte & historique
    - Écran de virement

- **Scripts d’aide (Windows / PowerShell)**: `scripts`  
  - `run_web.ps1`: lance le backend Laravel + l’app Flutter dans Chrome.
  - `run_emulator.ps1`: lance le backend Laravel, démarre un émulateur Android puis l’app Flutter dessus.

---

## Fonctionnalités principales

- **Authentification**  
  - Connexion par email + mot de passe.
  - Tokens API (Laravel) pour sécuriser les requêtes.

- **Comptes bancaires**  
  - Plusieurs comptes par utilisateur (chèque, épargne…)
  - Solde actuel par compte
  - Solde global sur le dashboard

- **Historique des transactions**  
  - Liste des opérations (crédit, débit)
  - Détail par compte

- **Virement vers un bénéficiaire**  
  - Sélection du compte source
  - Sélection d’un bénéficiaire (autre compte)
  - Saisie du montant + confirmation
  - Mise à jour immédiate des soldes et de l’historique

- **Données de test pré-remplies**  
  - Plusieurs utilisateurs seedés (Jean Dupont, Marie Martin, etc.)
  - Mot de passe unique de test: `password123`

---

## Pile technologique

- **Frontend**: Flutter (Dart) – Android + Web
- **Backend principal**: PHP 8.2+, Laravel
- **Micro-service transfert**: Node.js, Express
- **Base de données**: SQLite (dev local Laravel)
- **Scripts**: PowerShell (Windows)

---

## Sécurité de l’application bancaire*

- **Authentification par tokens Laravel**  
  - Connexion via l’API Laravel avec **email + mot de passe**.  
  - Génération de **tokens d’accès** (type Sanctum / API token) utilisés ensuite dans le header `Authorization: Bearer ...` pour toutes les requêtes sensibles (consultation de comptes, virements, etc.).

- **Gestion sécurisée des mots de passe**  
  - Les mots de passe sont **hashés** côté Laravel (mécanisme standard du framework, type bcrypt/argon2).  
  - L’app Flutter ne stocke pas les mots de passe, seulement le **token** après connexion.
