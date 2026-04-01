# mobileapp-2026
Création application mobile L3 2026

# MiniBank App

MiniBank App est une mini application bancaire fictive réalisée dans le cadre d’un projet étudiant, avec **Flutter** pour l’application mobile et **Laravel + MySQL** pour l’API backend.

## Structure du projet

mobileapp-2026/
├─ project/              # application Flutter
├─ backend/              # API Laravel
├─ docker-compose.yml    # MySQL avec Docker
└─ README.md

## Fonctionnalités principales

* création de compte
* connexion / déconnexion
* auto-login avec token
* affichage du profil
* affichage du wallet / solde
* dépôt
* retrait
* virement entre utilisateurs
* historique des opérations
* assistant MiniBank (assistant local côté backend)
* portefeuille crypto simulé
* achat crypto
* vente crypto

## Prérequis

Avant de lancer le projet, vérifier que les outils suivants sont installés :

* Flutter
* PHP / Composer
* Docker Desktop
* Android Studio
* un émulateur Android

## Remarque importante

Ce projet est prévu pour être testé sur émulateur Android.
L’application Flutter est configurée pour communiquer avec le backend avec l’adresse suivante :
10.0.2.2
Cette adresse est nécessaire car l’application s’exécute dans l’émulateur Android.

## Ordre de lancement

### 1. Démarrer MySQL avec Docker

Depuis la racine du projet :

docker compose up -d

### 2. Démarrer le backend Laravel

Ouvrir un terminal dans `backend/` puis lancer :

php artisan migrate
php artisan serve

### 3. Démarrer l’émulateur Android

Lancer un émulateur depuis Android Studio.

### 4. Démarrer l’application Flutter

Ouvrir un terminal dans `project/` puis lancer :

flutter pub get
flutter run

## Fonctionnalités à tester

Une fois l’application lancée, il est possible de tester :

* la création de compte
* la connexion
* l’affichage du profil et du solde
* le dépôt
* le retrait
* le virement entre utilisateurs
* l’historique des opérations
* l’assistant MiniBank
* l’achat et la vente de crypto simulée
* la déconnexion
