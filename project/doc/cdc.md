# Cahier des Charges — Application de Transfert d'Argent (Fiat & BKN)

**Projet** : Mobile App L3 — Martinique 2026
**Application** : `firstapp` (Flutter)
**Backend** : Laravel 12 REST API
**Répertoire** : `project/firstapp/`

---

## 1. Contexte et objectifs

### 1.1 Contexte

L'application s'inscrit dans le cadre du cours de développement mobile de L3 (Martinique, 2026). Elle simule un portefeuille numérique permettant des paiements en monnaie fiat (EUR) et en monnaie locale **BKN** (Bô Kay Nou), une monnaie fictive à vocation régionale caribéenne.

### 1.2 Objectifs

- Permettre à un utilisateur de gérer un portefeuille numérique depuis son mobile.
- Réaliser des transferts d'argent entre utilisateurs (pair-à-pair).
- Recharger le portefeuille via un paiement par carte bancaire (Stripe).
- Supporter deux devises : l'euro (EUR) et la monnaie locale BKN.
- Offrir un parcours QR Code pour simplifier les paiements en face-à-face.

---

## 2. Périmètre fonctionnel

### 2.1 Fonctionnalités incluses (V1 — existant)

| ID   | Fonctionnalité                         | Statut     |
|------|----------------------------------------|------------|
| F01  | Inscription (nom, email, mot de passe) | Implémenté |
| F02  | Connexion / Déconnexion                | Implémenté |
| F03  | Affichage du solde du portefeuille     | Implémenté |
| F04  | Transfert par email                    | Implémenté |
| F05  | Recharge via Stripe (carte bancaire)   | Implémenté |
| F06  | Génération d'un QR Code "recevoir"     | Implémenté |
| F07  | Scanner un QR Code pour payer          | Implémenté |
| F08  | Historique des 20 dernières transactions | Implémenté |

### 2.2 Fonctionnalités à développer (V2 — évolutions)

| ID   | Fonctionnalité                                        | Priorité |
|------|-------------------------------------------------------|----------|
| F09  | Support de la devise BKN (affichage, conversion)      | Haute    |
| F10  | Conversion EUR ↔ BKN (taux de change configurable)    | Haute    |
| F11  | Choix de la devise lors d'un transfert                | Haute    |
| F12  | Recharge en BKN (depuis EUR ou depuis un point relais)| Moyenne  |
| F13  | Notifications push (transfert reçu, recharge réussie) | Moyenne  |
| F14  | Profil utilisateur (modifier nom, photo)              | Basse    |
| F15  | Limite de transaction configurable par l'admin        | Basse    |

---

## 3. Acteurs

| Acteur          | Description                                                   |
|-----------------|---------------------------------------------------------------|
| Utilisateur     | Possède un compte, un portefeuille, effectue des opérations   |
| Système Stripe  | Tiers de confiance pour les paiements par carte bancaire      |
| Administrateur  | Gère les utilisateurs et la configuration (hors scope V1)     |

---

## 4. Cas d'utilisation

### UC01 — S'inscrire
1. L'utilisateur saisit son nom complet, email et mot de passe (min. 8 caractères).
2. Le système crée un compte et un portefeuille vide (solde = 0).
3. Un token d'authentification est retourné et stocké localement.
4. L'utilisateur est redirigé vers le tableau de bord.

### UC02 — Se connecter
1. L'utilisateur saisit son email et mot de passe.
2. Le système valide les identifiants et retourne un token (session unique).
3. L'utilisateur est redirigé vers le tableau de bord.

### UC03 — Consulter son portefeuille
1. L'utilisateur accède à l'écran principal.
2. Le solde en EUR (et BKN en V2) s'affiche.
3. Les 20 dernières transactions sont listées avec type, montant, nom et date.

### UC04 — Transférer de l'argent
1. L'utilisateur saisit l'email du destinataire et le montant.
2. Une boîte de confirmation affiche le récapitulatif.
3. Le système vérifie : solde suffisant, destinataire existant, pas d'auto-transfert.
4. Les deux portefeuilles sont mis à jour atomiquement.
5. Deux transactions miroirs sont créées (`transfer_out` / `transfer_in`).

### UC05 — Recharger via Stripe
1. L'utilisateur saisit un montant (min. 1€).
2. Le backend crée un PaymentIntent Stripe.
3. La feuille de paiement native s'affiche (iOS/Android uniquement).
4. Après paiement confirmé, le wallet est crédité et une transaction `topup` est enregistrée.

### UC06 — Recevoir via QR Code
1. L'utilisateur saisit le montant qu'il souhaite recevoir.
2. Un QR Code est généré contenant `{email, amount}` en JSON.
3. Le payeur scanne ce QR Code depuis son propre appareil (UC07).

### UC07 — Payer via QR Code
1. L'utilisateur ouvre le scanner caméra.
2. Il scanne le QR Code du destinataire.
3. Une boîte de confirmation affiche l'email et le montant détectés.
4. Après validation, le transfert est exécuté (cf. UC04).

---

## 5. Spécifications techniques

### 5.1 Stack technologique

| Composant       | Technologie                        |
|-----------------|------------------------------------|
| Mobile frontend | Flutter (Dart)                     |
| Web frontend    | Flutter Web (Chrome)               |
| Backend API     | Laravel 12 (PHP 8.x)               |
| Base de données | PostgreSQL 16                      |
| Paiement        | Stripe (PaymentSheet, mode test)   |
| Auth            | Laravel Sanctum (token Bearer)     |
| QR Code gen.    | `qr_flutter ^4.1.0`                |
| QR Code scan    | `mobile_scanner ^5.0.0`            |
| Stockage sécurisé | `flutter_secure_storage ^9.0.0`  |
| HTTP client     | `http ^1.2.0`                      |

### 5.2 Architecture Flutter

Pattern MVC-like en 3 couches :

```
lib/
├── config.dart          # URL de base de l'API (centralisée)
├── main.dart            # Point d'entrée + AuthGate
├── models/              # Classes de données (fromJson)
│   ├── user.dart
│   ├── wallet.dart
│   ├── transaction.dart
│   └── transfer_response.dart
├── services/            # Appels HTTP
│   ├── auth_service.dart
│   └── api_service.dart
└── screens/             # Vues StatefulWidget
    ├── login_screen.dart
    ├── register_screen.dart
    ├── wallet_screen.dart
    ├── transfer_screen.dart
    ├── topup_screen.dart
    ├── receive_screen.dart
    └── scan_pay_screen.dart
```

### 5.3 API REST (Laravel)

**Routes publiques :**

| Méthode | Route            | Description         |
|---------|------------------|---------------------|
| POST    | `/api/register`  | Inscription         |
| POST    | `/api/login`     | Connexion           |

**Routes protégées (Bearer token) :**

| Méthode | Route                           | Description                   |
|---------|---------------------------------|-------------------------------|
| POST    | `/api/logout`                   | Déconnexion                   |
| GET     | `/api/user`                     | Profil utilisateur courant    |
| GET     | `/api/wallet`                   | Solde du portefeuille         |
| POST    | `/api/wallet/transfer`          | Transférer vers un email      |
| GET     | `/api/wallet/transactions`      | Historique (20 dernières)     |
| POST    | `/api/wallet/topup/create-intent` | Créer un PaymentIntent Stripe |
| POST    | `/api/wallet/topup/confirm`     | Confirmer la recharge         |

### 5.4 Modèle de données

**Table `users`** : `id`, `name`, `email`, `password`, timestamps
**Table `wallets`** : `id`, `user_id` (FK), `balance` (decimal), timestamps
**Table `transactions`** : `id`, `wallet_id` (FK), `type`, `amount`, `status`, `related_wallet_id`, `stripe_payment_intent_id`, timestamps

**Types de transactions :**
- `topup` — Recharge par carte
- `transfer_out` — Transfert envoyé
- `transfer_in` — Transfert reçu

### 5.5 Sécurité

- Authentification par token (Sanctum) — session unique (revoke à la reconnexion).
- Stockage du token sur l'appareil via `flutter_secure_storage`.
- Transactions DB atomiques (rollback en cas d'erreur).
- Vérification du `user_id` dans les métadonnées Stripe avant de créditer.
- Validation côté serveur de toutes les entrées (montant > 0.01, email existant, etc.).

---

## 6. Spécifications de la monnaie BKN (V2)

### 6.1 Définition

Le **BKN** (Bô NuméKay Nou) est la monnaie locale fictive du projet. Elle est utilisée pour des échanges communautaires à l'échelle caribéenne.

### 6.2 Taux de change

- Taux initial : **1 EUR = 10 BKN** (configurable dans le backend).
- Stocké en base de données pour permettre une mise à jour sans redéploiement.

### 6.3 Portefeuille dual-devise

Chaque utilisateur aura deux soldes :
- `balance_eur` — Solde en euros
- `balance_bkn` — Solde en BKN

### 6.4 Conversion

- L'utilisateur peut convertir EUR → BKN et BKN → EUR depuis son portefeuille.
- Les frais de conversion sont de 0 % en V2 (à définir en V3).

### 6.5 Transferts en BKN

- Lors d'un transfert, l'utilisateur choisit la devise (EUR ou BKN).
- Le QR Code embarque la devise choisie : `{email, amount, currency}`.

---

## 7. Interfaces utilisateur

### 7.1 Écrans existants

| Écran              | Route Flutter         | Fonctionnalités                                      |
|--------------------|-----------------------|------------------------------------------------------|
| Connexion          | `LoginScreen`         | Formulaire email/mdp, lien vers inscription          |
| Inscription        | `RegisterScreen`      | Formulaire nom/email/mdp, lien vers connexion        |
| Tableau de bord    | `WalletScreen`        | Solde, 4 boutons d'action, historique transactions   |
| Transfert          | `TransferScreen`      | Saisie email + montant, confirmation, résultat       |
| Recharge           | `TopUpScreen`         | Saisie montant, Stripe PaymentSheet, feedback        |
| Recevoir (QR)      | `ReceiveScreen`       | Saisie montant, affichage QR code                    |
| Scanner (QR)       | `ScanPayScreen`       | Caméra, détection QR, confirmation, paiement         |

### 7.2 Composants UI notables

- Carte de solde (fond coloré, montant en grand).
- Grille 2×2 de boutons d'action colorés.
- Liste de transactions avec icône, nom, montant coloré (vert/rouge), date.
- Indicateurs de chargement sur toutes les actions asynchrones.
- Overlay de traitement lors du scan QR.
- Bouton torche sur l'écran scanner.

---

## 8. Contraintes et règles métier

| Règle | Description |
|-------|-------------|
| RG01  | Le montant d'un transfert doit être supérieur à 0,01 € (ou BKN). |
| RG02  | Un utilisateur ne peut pas se transférer à lui-même. |
| RG03  | Un transfert est impossible si le solde est insuffisant. |
| RG04  | La recharge Stripe est disponible uniquement sur Android et iOS (pas web). |
| RG05  | Le montant minimum de recharge Stripe est de 1 €. |
| RG06  | L'historique affiche les 20 dernières transactions. |
| RG07  | Un seul token actif par utilisateur (déconnexion des sessions précédentes à la connexion). |
| RG08  | Le QR Code expire côté UX si l'utilisateur quitte l'écran (pas de persistence). |

---

## 9. Exigences non fonctionnelles

| Critère         | Exigence                                                    |
|-----------------|-------------------------------------------------------------|
| Performance     | Réponse API < 2 s en conditions normales                    |
| Disponibilité   | Déploiement Docker Compose (backend + DB + Nginx)           |
| Portabilité     | Android, iOS, Chrome (web)                                  |
| Maintenabilité  | Code organisé en couches (model / service / screen)         |
| Sécurité        | Token Bearer, stockage sécurisé, transactions atomiques     |
| Tests           | Tests PHPUnit côté Laravel (`composer run test`)            |

---

## 10. Environnement de développement

| Composant     | URL / Port                             |
|---------------|----------------------------------------|
| Laravel (direct)  | `http://localhost:8001/api`         |
| Laravel (Nginx)   | `http://localhost:8000/api`         |
| Next.js           | `http://localhost:3000`                |
| PostgreSQL        | `localhost:5432`                       |
| Flutter Web       | `http://localhost:8001/api` (config.dart) |
| Flutter Android (émulateur Docker) | `http://<LAN_IP>:8001/api` |

**Fichier de configuration central** : `project/firstapp/lib/config.dart`
Modifier `_androidUrl` pour pointer vers l'IP LAN du Mac lors des tests sur émulateur.

---

## 11. Livrables attendus

| Livrable                         | Description                                              |
|----------------------------------|----------------------------------------------------------|
| Application Flutter fonctionnelle | Toutes les fonctionnalités V1 opérationnelles            |
| Backend Laravel déployé          | API REST documentée et testée                            |
| Base de données migrée           | Schéma à jour via `php artisan migrate`                  |
| Support BKN (V2)                 | Affichage dual-devise, conversion, transferts en BKN     |
| Documentation technique          | Ce CDC + commentaires dans le code                       |

---

*Document généré le 10/03/2026 — à maintenir à jour au fil des itérations.*
