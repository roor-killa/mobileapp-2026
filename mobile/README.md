# **ScolarApp — Application Mobile de Gestion Scolaire**

Projet réalisé dans le cadre du cours de L3 Informatique.  
Application Flutter connectée à une API Laravel avec base de données MySQL, inspirée de Pronote.

---

## **Structure du projet**

```
mobileapp-2026/
├── mobile/          → Application Flutter (frontend)
└── backend-api/     → API Laravel (backend) — dossier Laragon : C:\laragon\www\backend-api
```

---

## **Prérequis**

Avant de lancer le projet, assurez-vous d'avoir installé :

* [Laragon](https://laragon.org/download/) (Apache + MySQL)
* [Composer](https://getcomposer.org/) (gestionnaire de dépendances PHP)
* Flutter SDK ✅ (déjà installé)
* Android Studio ✅ (déjà installé)

> ⚠️ **Important** : Le backend Laravel doit être placé dans `C:\laragon\www\backend-api` pour que Laragon le serve correctement sur `http://localhost/backend-api/public/api`

---

## **Lancement du projet (dans l'ordre)**

### **1. Démarrer Laragon**

* Ouvrir **Laragon**
* Cliquer sur **"Start All"** pour démarrer Apache et MySQL

### **2. Configurer la base de données**

* Ouvrir **HeidiSQL** (inclus dans Laragon) ou **phpMyAdmin**
* Créer une base de données nommée : `backend_api`

### **3. Configurer le backend Laravel**

Ouvrir un terminal dans le dossier `C:\laragon\www\backend-api` :

```bash
cd C:\laragon\www\backend-api
composer install
cp .env.example .env
```

Ouvrir le fichier `.env` et vérifier ces lignes :

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=backend_api
DB_USERNAME=root
DB_PASSWORD=
```

Générer la clé et migrer la base de données :

```bash
php artisan key:generate
php artisan migrate
php artisan db:seed
```

### **4. Lancer l'émulateur Android**

* Ouvrir **Android Studio**
* Aller dans **Device Manager**
* Démarrer un émulateur Android (API 21 ou supérieur recommandé)

### **5. Lancer l'application Flutter**

```bash
cd mobile
flutter pub get
flutter run -d emulator-5554
```

Si l'émulateur a un ID différent, utilisez `flutter devices` pour trouver le bon ID.

---

## **Comptes de test**

### Professeurs
| Nom | Email | Mot de passe |
|-----|-------|--------------|
| Pierre Dupont | prof@gmail.com | password |
| Sophie Durand | sophie@school.com | sophie123 |
| Emmanuel Macron | macron@gmail.com | test123 |

### Administrateur
| Email | Mot de passe |
|-------|--------------|
| admin@gmail.com | admin123 |

### Étudiants (mot de passe = prénom en minuscule + 123)
| Nom | Email | Mot de passe |
|-----|-------|--------------|
| Lucas Martin | lucas@school.com | lucas123 |
| Emma Bernard | emma@school.com | emma123 |
| Noah Dubois | noah@school.com | noah123 |
| Léa Thomas | lea@school.com | lea123 |
| Hugo Petit | hugo@school.com | hugo123 |
| Chloé Robert | chloe@school.com | chloe123 |
| Antoine Richard | antoine@school.com | antoine123 |

---

## **Fonctionnalités**

### Espace Professeur (violet)
* Connexion / Inscription avec mot de passe oublié
* Liste des étudiants avec classe (ajout, modification, suppression)
* Gestion des notes par matière (max 3 notes par matière)
* Affichage de la moyenne par matière (vert ≥ 10, rouge < 10)
* Un professeur peut enseigner max 2 matières
* Emploi du temps personnel avec déclaration présence/absence
* Création et gestion des devoirs par classe
* Moyennes de classe par matière

### Espace Admin (rouge/sombre)
* Connexion administrateur avec mot de passe oublié
* Gestion des professeurs (ajout, suppression)
* Assignation des matières aux professeurs
* Gestion de l'emploi du temps par classe (ajout, suppression de créneaux)

### Espace Étudiant (vert)
* Connexion étudiant avec mot de passe oublié
* Tableau de bord avec notes par matière et moyenne générale
* Comparaison avec la moyenne de la classe
* Mention automatique (Très bien / Bien / Assez bien / Passable / Insuffisant)
* Emploi du temps de la classe par jour
* Devoirs à rendre avec date limite et code couleur (rouge = urgent)
* Notifications locales pour les nouveaux devoirs
* Chatbot IA (Assistant) pour poser des questions sur les notes

### Système de classes
* 3 classes disponibles : L1 Informatique, L2 Informatique, L3 Informatique
* Chaque étudiant est assigné à une classe
* Moyennes calculées par classe et par matière

---

## **Architecture technique**

* **Frontend** : Flutter (Dart) — `http://10.0.2.2/backend-api/public/api`
* **Backend** : Laravel 11 (PHP 8.4) — Architecture MVC
* **Base de données** : MySQL 8.4 (via Laragon)
* **Notifications** : flutter_local_notifications
* **Chatbot** : API Anthropic (claude-sonnet)
* **Sécurité** : Mots de passe hashés avec bcrypt

---

## **Sécurité**

* Mots de passe hashés avec bcrypt — jamais stockés en clair
* Le champ password est caché dans toutes les réponses JSON
* Séparation des rôles : admin / professeur / étudiant
* Réinitialisation de mot de passe avec génération d'un mot de passe temporaire

---

## **Auteur**

Projet développé par **ALIBO CORENTIN** — L3 Informatique 2026