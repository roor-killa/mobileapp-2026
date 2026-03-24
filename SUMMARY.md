# Résumé des actions effectuées — mobileapp-2026

## Vue d'ensemble

Projet de développement mobile L3 (Martinique, 2026). Application de type wallet/transfert d'argent, avec un frontend Flutter, une API REST Laravel et une infrastructure Docker.

---

## Historique des développements

### Initialisation du projet
- Création de `firstapp` et `secondapp` (templates Flutter)
- Ajout du cours CM1 (`cm1_Intro_Ecosysteme.md`)
- Mise en place de l'infrastructure Docker + Nginx (`infrastructure/infra/`)

### Fonctionnalité de transfert (IHM)
- Création de l'écran de transfert (`transfer_screen.dart`)
- Ajout du modèle `TransferResponse` et du service `ApiService` avec simulation d'API
- Intégration du package `http` pour les appels réseau

### Système de wallet complet
- Ajout de l'authentification Sanctum (login / register / logout / stockage du token)
  - `auth_service.dart` — service d'authentification
- Création de l'écran principal wallet (`wallet_screen.dart`) : affichage du solde, historique des transactions, actions (recharger, transférer)
- Intégration **Stripe** pour les paiements (top-up) via `flutter_stripe`
- Ajout de `pubspec.yaml` : dépendances `flutter_stripe`, `shared_preferences`

### Fixes compatibilité web & réseau
- Ajout du script `Stripe.js` dans `web/index.html`
- Initialisation Stripe conditionnelle selon la plateforme (web vs mobile)
- URL API dynamique selon la plateforme dans `main.dart`
- Centralisation de l'URL API dans `lib/config.dart` pour faciliter les changements d'IP LAN (résolution du problème émulateur Android ↔ Docker sur macOS)

### Améliorations de l'affichage et de l'UX
- **Fix solde** : cast `decimal` correct côté Laravel + gestion d'erreur sur le top-up
- **Historique** : affichage du nom du destinataire/expéditeur (nécessitait une modification du `WalletController` Laravel)
- **Historique** : date au format `JJ/MM/AAAA`, puis enrichi avec l'heure (`JJ/MM/AAAA HH:MM`)
- **UI** : historique défilant + dialog de confirmation avant transfert

### Paiement par QR Code
- Génération d'un QR Code pour recevoir un paiement (`receive_screen.dart`)
- Scanner QR Code pour payer (`scan_pay_screen.dart`)
- Ajout des dépendances `qr_flutter` et `mobile_scanner`
- Fix bouton QR grisé : fallback sur email récupéré via l'API (`/api/user`) quand l'info n'est pas disponible localement

### Redesign Revolut-style
- Refonte visuelle complète de l'application sur le thème sombre inspiré de Revolut
- Mise à jour de tous les écrans principaux : wallet, transfert, top-up, historique, QR Code
- Ajout du support macOS (Podfile, xcodeproj)

---

## Stack technique

| Composant | Technologie |
|---|---|
| Frontend mobile | Flutter (Dart) |
| Backend API | Laravel 12 (PHP) |
| Base de données | PostgreSQL 16 |
| Auth | Laravel Sanctum |
| Paiement | Stripe |
| QR Code | `qr_flutter` + `mobile_scanner` |
| Infrastructure | Docker Compose + Nginx |
| Frontend web | Next.js 16 (non intégré) |

---

## Fichiers clés

- `project/firstapp/lib/config.dart` — URL de base de l'API (à modifier selon le réseau)
- `project/firstapp/lib/services/auth_service.dart` — Authentification
- `project/firstapp/lib/services/api_service.dart` — Appels API (wallet, transactions, Stripe)
- `project/firstapp/lib/screens/wallet_screen.dart` — Écran principal
- `infrastructure/back-laravel/app/Http/Controllers/WalletController.php` — Logique wallet côté serveur
- `infrastructure/back-laravel/routes/api.php` — Routes API
