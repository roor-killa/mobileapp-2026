#  **Application Mobile \- Gestion des Étudiants**

Projet réalisé dans le cadre du cours de L3 Informatique.  
 Application Flutter connectée à une API Laravel avec base de données MySQL.

##  **Structure du projet**

mobileapp-2026/  
├── mobile/          → Application Flutter (frontend)  
└── backend-api/     → API Laravel (backend)

##  **Prérequis**

Avant de lancer le projet, assurez-vous d'avoir installé :

* [Laragon](https://laragon.org/download/) (Apache \+ MySQL)  
* [Composer](https://getcomposer.org/) (gestionnaire de dépendances PHP)  
* Flutter SDK ✅ (déjà installé)  
* Android Studio ✅ (déjà installé)

##  **Lancement du projet (dans l'ordre)**

### **1️. Démarrer Laragon**

* Ouvrir **Laragon**  
* Cliquer sur **"Start All"** pour démarrer Apache et MySQL

### **2️. Configurer la base de données**

* Ouvrir **HeidiSQL** (inclus dans Laragon) ou **phpMyAdmin**  
* Créer une base de données nommée : `backend_api`  
* Importer le fichier SQL si fourni, sinon passer à l'étape suivante

**3️. Configurer le backend Laravel**

Ouvrir un terminal dans le dossier `backend-api/` :

cd backend-api

Installer les dépendances PHP :

composer install

Copier le fichier d'environnement :

cp .env.example .env

Ouvrir le fichier `.env` et vérifier ces lignes :

DB\_CONNECTION=mysql  
DB\_HOST=127.0.0.1  
DB\_PORT=3306  
DB\_DATABASE=backend\_api  
DB\_USERNAME=root  
DB\_PASSWORD=

Générer la clé de l'application :

php artisan key:generate

Créer les tables de la base de données :

php artisan migrate

Lancer le serveur Laravel (PHP 8.4 \- ne pas utiliser `php artisan serve`) :

php \-S 127.0.0.1:80 \-t public

✅ Le backend est maintenant accessible sur `http://127.0.0.1/backend-api/public/api`

**4️. Lancer l'émulateur Android**

* Ouvrir **Android Studio**  
* Aller dans **Device Manager**  
* Démarrer un émulateur Android (API 30 ou supérieur recommandé)

### **5\. Lancer l'application Flutter**

Ouvrir un terminal dans le dossier `mobile/` :

cd mobile

Installer les dépendances Flutter :

flutter pub get

Lancer l'application sur l'émulateur :

flutter run \-d emulator-5554

Si l'émulateur a un ID différent, utilisez `flutter devices` pour trouver le bon ID.

##  **Compte de test**

Un compte professeur est disponible pour tester l'application :

| Champ | Valeur |
| ----- | ----- |
| Email | prof@gmail.com |
| Mot de passe | password |

##  **Fonctionnalités**

* Connexion / Inscription professeur  
* Liste des étudiants (ajout, modification, suppression)  
* Gestion des notes par matière (max 3 notes par matière)  
* Un professeur peut enseigner max 2 matières  
* Affichage de la moyenne par matière (vert ≥ 10, rouge \< 10\)

##  **Auteur**

Projet développé par **ALIBO CORENTIN** \- L3 Informatique 2026

