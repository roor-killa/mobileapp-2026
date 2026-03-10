#  **Application Mobile - Gestion des Étudiants (Pronote)**

Projet réalisé dans le cadre du cours de L3 Informatique.  
Application Flutter connectée à une API Laravel avec base de données MySQL.

---

##  **Structure du projet**

```
mobileapp-2026/
├── mobile/          → Application Flutter (frontend)
└── backend-api/     → API Laravel (backend) — dossier Laragon : C:\laragon\www\backend-api
```

---

##  **Prérequis**

Avant de lancer le projet, assurez-vous d'avoir installé :

* [Laragon](https://laragon.org/download/) (Apache + MySQL)
* [Composer](https://getcomposer.org/) (gestionnaire de dépendances PHP)
* Flutter SDK ✅ (déjà installé)
* Android Studio ✅ (déjà installé)

> ⚠️ **Important** : Le backend Laravel doit être placé dans `C:\laragon\www\backend-api` pour que Laragon le serve correctement sur `http://localhost/backend-api/public/api`

---

##  **Lancement du projet (dans l'ordre)**

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
```

Installer les dépendances PHP :

```bash
composer install
```

Copier le fichier d'environnement :

```bash
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

Générer la clé de l'application :

```bash
php artisan key:generate
```

Créer les tables de la base de données :

```bash
php artisan migrate
```

Remplir la base avec les données de test :

```bash
php artisan db:seed
```

### **4. Lancer l'émulateur Android**

* Ouvrir **Android Studio**
* Aller dans **Device Manager**
* Démarrer un émulateur Android (API 30 ou supérieur recommandé)

### **5. Lancer l'application Flutter**

Ouvrir un terminal dans le dossier `mobile/` :

```bash
cd mobile
flutter pub get
flutter run -d emulator-5554
```

Si l'émulateur a un ID différent, utilisez `flutter devices` pour trouver le bon ID.

---

##  **Comptes de test**

### Professeur
| Champ | Valeur |
|-------|--------|
| Email | prof@gmail.com |
| Mot de passe | password |

### Admin
| Champ | Valeur |
|-------|--------|
| Email | admin@school.com |
| Mot de passe | admin123 |

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

##  **Fonctionnalités**

### Espace Professeur (violet)
* Connexion / Inscription professeur
* Liste des étudiants (ajout, modification, suppression)
* Gestion des notes par matière (max 3 notes par matière)
* Un professeur peut enseigner max 2 matières
* Affichage de la moyenne par matière (vert ≥ 10, rouge < 10)

### Espace Admin (rouge/sombre)
* Connexion administrateur
* Gestion des professeurs (ajout, suppression)
* Assignation des matières aux professeurs

### Espace Étudiant (vert)
* Connexion étudiant
* Tableau de bord avec notes par matière
* Moyenne générale avec mention
* Chatbot IA (Assistant) pour poser des questions sur les notes et le règlement scolaire
* Gestion des absences (bientôt disponible)

---

##  **Architecture technique**

* **Frontend** : Flutter (Dart) — `http://10.0.2.2/backend-api/public/api`
* **Backend** : Laravel 11 (PHP 8.4)
* **Base de données** : MySQL 8.4 (via Laragon)
* **Chatbot** : API Anthropic (claude-sonnet)

---

##  **Auteur**

Projet développé par **ALIBO CORENTIN** — L3 Informatique 2026