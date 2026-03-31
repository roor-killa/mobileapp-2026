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

  Backend (Laravel)                                                                                                                                                      
                                                                                                                                                                         
  ┌──────────────────────────┬───────────────────────────────────────────────────────────────────────────────────────┐
  │         Fichier          │                                      Changement                                       │                                                   
  ├──────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤
  │ Migration wallets        │ Ajout colonne balance_bkn (decimal, défaut 0)                                         │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤
  │ Migration exchange_rates │ Nouvelle table + taux initial 1 EUR = 10 BKN                                          │                                                   
  ├──────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤                                                   
  │ Migration transactions   │ Ajout colonne currency (EUR/BKN, défaut EUR)                                          │                                                   
  ├──────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤                                                   
  │ Wallet.php               │ balance_bkn ajouté au fillable                                                        │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤                                                   
  │ Transaction.php          │ currency ajouté au fillable                                                           │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤                                                   
  │ WalletController.php     │ show() retourne balance_bkn, transfer() gère la devise, + exchangeRate(), + convert() │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤                                                   
  │ routes/api.php           │ GET /wallet/exchange-rate et POST /wallet/convert                                     │
  └──────────────────────────┴───────────────────────────────────────────────────────────────────────────────────────┘                                                   
                                                            
  Flutter                                                                                                                                                                
                                                            
  ┌──────────────────────┬──────────────────────────────────────────────────────────────────────────────┐                                                                
  │       Fichier        │                                  Changement                                  │
  ├──────────────────────┼──────────────────────────────────────────────────────────────────────────────┤                                                                
  │ wallet.dart          │ Ajout balanceBkn                                                             │
  ├──────────────────────┼──────────────────────────────────────────────────────────────────────────────┤
  │ transaction.dart     │ Ajout currency                                                               │                                                                
  ├──────────────────────┼──────────────────────────────────────────────────────────────────────────────┤
  │ api_service.dart     │ transfer() avec param currency, + getExchangeRate(), + convert()             │                                                                
  ├──────────────────────┼──────────────────────────────────────────────────────────────────────────────┤                                                                
  │ wallet_screen.dart   │ Affichage dual solde (EUR + BKN), bouton Convertir EUR ↔ BKN                 │
  ├──────────────────────┼──────────────────────────────────────────────────────────────────────────────┤                                                                
  │ transfer_screen.dart │ Toggle EUR/BKN pour choisir la devise                                        │
  ├──────────────────────┼──────────────────────────────────────────────────────────────────────────────┤                                                                
  │ receive_screen.dart  │ Toggle EUR/BKN, currency embarqué dans le QR JSON                            │
  ├──────────────────────┼──────────────────────────────────────────────────────────────────────────────┤                                                                
  │ scan_pay_screen.dart │ Parse le champ currency du QR Code                                           │
  ├──────────────────────┼──────────────────────────────────────────────────────────────────────────────┤                                                                
  │ convert_screen.dart  │ Nouvel écran : aperçu du montant converti, swap de devise, affichage du taux

  ## FireBase ##
   1. Créer le projet Firebase                                                                                                                                            
                                                                                                                                                                         
  1. Va sur console.firebase.google.com                                                                                                                                  
  2. Ajouter un projet → nom : mobileapp-bkn → Continuer                                                                                                                 
  3. Désactive Google Analytics (pas nécessaire) → Créer le projet                                                                                                       
                                                                                                                                                                         
  ---                                                                                                                                                                    
  2. Ajouter l'app iOS                                                                                                                                                   
                                                            
  1. Dans le projet Firebase → Ajouter une application → icône iOS
  2. Bundle ID : com.example.firstapp (vérifie dans Xcode ou dans project/firstapp/ios/Runner.xcodeproj)                                                                 
  3. Télécharger GoogleService-Info.plist                                                                                                                                
  4. Le placer dans project/firstapp/ios/Runner/                                                                                                                         
                                                                                                                                                                         
  ---                                                                                                                                                                    
  3. Ajouter l'app Android                                  
                          
  1. Ajouter une application → icône Android
  2. Package : com.example.firstapp                                                                                                                                      
  3. Télécharger google-services.json
  4. Le placer dans project/firstapp/android/app/                                                                                                                        
                                                                                                                                                                         
  ---
  4. Clé privée pour le backend Laravel                                                                                                                                  
                                                            
  1. Dans Firebase → Paramètres du projet (roue dentée) → onglet Comptes de service
  2. Cliquer Générer une nouvelle clé privée → télécharger le JSON                                                                                                       
  3. Le renommer firebase-service-account.json                                                                                                                           
  4. Le placer dans infrastructure/back-laravel/storage/app/    