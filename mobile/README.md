# ScolarApp — Application Mobile de Gestion Scolaire

> Application mobile inspirée de Pronote, développée en Flutter (frontend) et Laravel (backend).  
> Projet réalisé dans le cadre du cours de L3 Informatique — ALIBO CORENTIN — 2026

---

## Table des matières

1. [Présentation](#présentation)
2. [Installation et lancement](#installation-et-lancement)
3. [Guide d'utilisation — Espace Professeur](#espace-professeur)
4. [Guide d'utilisation — Espace Administrateur](#espace-administrateur)
5. [Guide d'utilisation — Espace Étudiant](#espace-étudiant)
6. [Comptes de test](#comptes-de-test)
7. [Architecture technique](#architecture-technique)
8. [Sécurité](#sécurité)

---

## Présentation

ScolarApp est une application mobile Android qui centralise la gestion scolaire en trois espaces distincts :

- **Espace Professeur** (violet) — gérer les étudiants, les notes, l'emploi du temps et les devoirs
- **Espace Administrateur** (rouge/sombre) — gérer les professeurs et l'emploi du temps
- **Espace Étudiant** (vert) — consulter ses notes, son emploi du temps et ses devoirs

---

## Installation et lancement

### Prérequis

Assurez-vous d'avoir installé :

- [Laragon](https://laragon.org/download/) — serveur Apache + MySQL local
- [Composer](https://getcomposer.org/) — gestionnaire de dépendances PHP
- Flutter SDK
- Android Studio avec un émulateur Android (API 21 minimum)

> ⚠️ **Important** : Le dossier backend doit être placé dans `C:\laragon\www\backend-api`.  
> Laragon ne sert que les fichiers depuis son propre dossier `www`, pas depuis le bureau ou OneDrive.

### Étape 1 — Démarrer Laragon

Ouvrir Laragon et cliquer sur **Start All** pour démarrer Apache et MySQL.

### Étape 2 — Créer la base de données

Ouvrir HeidiSQL (inclus dans Laragon) et créer une base de données nommée `backend_api`.

### Étape 3 — Configurer le backend

```bash
cd C:\laragon\www\backend-api
composer install
cp .env.example .env
```

Ouvrir le fichier `.env` et vérifier ces lignes :

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=backend_api
DB_USERNAME=root
DB_PASSWORD=
```

Puis exécuter :

```bash
php artisan key:generate
php artisan migrate
php artisan db:seed
```

### Étape 4 — Lancer l'émulateur Android

Ouvrir Android Studio, aller dans **Device Manager** et démarrer un émulateur Android.

### Étape 5 — Lancer l'application Flutter

```bash
cd mobile
flutter pub get
flutter run
```

---

## Espace Professeur

L'espace professeur est accessible depuis l'écran d'accueil. Il utilise une identité visuelle violette.

### Connexion

Saisir l'email et le mot de passe du compte professeur puis appuyer sur **Se connecter**.  
En cas d'oubli du mot de passe, appuyer sur **Mot de passe oublié ?** et saisir l'email — un mot de passe temporaire sera généré et affiché à l'écran.

### Gérer les étudiants

Après connexion, la liste des étudiants s'affiche avec leur classe, email et initiales.

- **Ajouter un étudiant** : appuyer sur **+ Ajouter** en bas à droite, remplir le formulaire et sélectionner une classe. Le mot de passe par défaut de l'étudiant sera `prénomminuscule123` (ex: `lucas123`).
- **Modifier un étudiant** : appuyer sur l'icône crayon orange.
- **Supprimer un étudiant** : appuyer sur l'icône poubelle rouge.
- **Voir les notes** : appuyer sur **Voir les notes** sous le nom de l'étudiant.

### Gérer les notes

L'écran des notes affiche toutes les matières. Pour les matières enseignées par le professeur connecté, un bouton crayon permet de saisir ou modifier jusqu'à 3 notes. La moyenne est calculée automatiquement et affichée en vert si supérieure ou égale à 10, en rouge sinon.

### Emploi du temps

Appuyer sur l'icône **calendrier** dans la barre du haut. Les cours sont organisés par jour. Pour chaque cours, un bouton **Présence** permet de déclarer sa présence ou son absence avec un motif optionnel.

### Devoirs

Appuyer sur l'icône **presse-papiers** dans la barre du haut.

- **Créer un devoir** : appuyer sur **+ Nouveau devoir**, remplir le titre, la description, la matière, la classe et la date limite.
- **Supprimer un devoir** : appuyer sur l'icône poubelle rouge.

Les étudiants reçoivent une notification automatique lors de l'ajout d'un nouveau devoir.

### Moyennes de classe

Appuyer sur l'icône **graphique** dans la barre du haut pour consulter les moyennes par matière pour chaque classe.

---

## Espace Administrateur

L'espace administrateur est accessible depuis l'écran d'accueil en appuyant sur **Accès administrateur** en bas de page. Il utilise un thème sombre avec une identité rouge.

### Connexion

Saisir les identifiants administrateur. La fonctionnalité de mot de passe oublié est également disponible.

### Gérer les professeurs

Le tableau de bord affiche la liste des professeurs avec leurs matières assignées.

- **Créer un professeur** : appuyer sur **+ Nouveau professeur**, remplir le formulaire et sélectionner jusqu'à 2 matières.
- **Modifier les matières** : appuyer sur l'icône livre orange pour modifier les matières assignées.
- **Supprimer un professeur** : appuyer sur l'icône poubelle rouge et confirmer.

### Gérer l'emploi du temps

Appuyer sur l'icône **calendrier** dans la barre du haut.

- Sélectionner une classe dans le menu déroulant.
- Naviguer entre les jours de la semaine.
- **Ajouter un créneau** : appuyer sur **+ Ajouter un créneau**, choisir le jour, la matière, le professeur, les horaires et la salle.
- **Supprimer un créneau** : appuyer sur l'icône poubelle rouge du créneau concerné.

---

## Espace Étudiant

L'espace étudiant est accessible depuis l'écran d'accueil en appuyant sur **Espace étudiant**. Il utilise une identité visuelle verte.

### Connexion

Saisir l'email et le mot de passe du compte étudiant. La fonctionnalité de mot de passe oublié est disponible.

### Onglet Notes

Le tableau de bord affiche la moyenne générale avec la mention et la moyenne de la classe pour comparaison. Chaque matière affiche les trois notes, la moyenne individuelle et la moyenne de la classe.

| Moyenne | Mention |
|---------|---------|
| 16 et plus | Très bien |
| 14 à 15.99 | Bien |
| 12 à 13.99 | Assez bien |
| 10 à 11.99 | Passable |
| Moins de 10 | Insuffisant |

### Onglet Emploi du temps

L'emploi du temps de la classe est affiché par jour avec les horaires, le nom du professeur et la salle.

### Onglet Devoirs

La liste des devoirs à rendre est affichée avec la matière, le professeur, la description et la date limite. Code couleur d'urgence :

| Couleur | Signification |
|---------|--------------|
| Rouge | Moins de 2 jours restants |
| Orange | Moins de 5 jours restants |
| Vert | Plus de 5 jours restants |

Tirer vers le bas pour rafraîchir. Une notification s'affiche automatiquement lors de l'ajout d'un nouveau devoir.

### Onglet Assistant

Le chatbot IA permet de poser des questions sur ses notes, ses résultats ou le règlement scolaire. Des suggestions rapides sont disponibles au démarrage.

---

## Comptes de test

### Professeurs

| Nom | Email | Mot de passe | Matières |
|-----|-------|--------------|---------|
| Pierre Dupont | prof@gmail.com | password | Histoire, Anglais |
| Sophie Durand | sophie@school.com | sophie123 | Mathématiques, Français |
| Emmanuel Macron | macron@gmail.com | test123 | Mathématiques, Informatique |
| Poutine Vladimir | poutine@gmail.com | *(réinitialiser)* | Histoire, Sciences |
| Corentin Alibo | corentin@gmail.com | *(réinitialiser)* | Français, Histoire |

### Administrateur

| Email | Mot de passe |
|-------|--------------|
| admin@gmail.com | admin123 |

### Étudiants

| Nom | Email | Mot de passe | Classe |
|-----|-------|--------------|--------|
| Lucas Martin | lucas@school.com | lucas123 | L3 Informatique |
| Emma Bernard | emma@school.com | emma123 | L3 Informatique |
| Noah Dubois | noah@school.com | noah123 | L3 Informatique |
| Léa Thomas | lea@school.com | lea123 | L3 Informatique |
| Hugo Petit | hugo@school.com | hugo123 | L3 Informatique |
| Chloé Robert | chloe@school.com | chloe123 | L3 Informatique |
| Antoine Richard | antoine@school.com | antoine123 | L3 Informatique |

---

## Architecture technique

| Composant | Technologie | Rôle |
|-----------|-------------|------|
| Frontend | Flutter (Dart) | Interface mobile Android |
| Backend | Laravel 11 (PHP 8.4) | API REST — Architecture MVC |
| Base de données | MySQL 8.4 | Stockage des données |
| Serveur local | Laragon (Apache) | Hébergement du backend |
| Notifications | flutter_local_notifications | Alertes nouveaux devoirs |
| Chatbot | API Anthropic (Claude) | Assistant IA |
| Sécurité | Bcrypt (Laravel Hash) | Hashage des mots de passe |

L'émulateur Android communique avec le backend via `http://10.0.2.2/backend-api/public/api`.

---

## Sécurité

- Les mots de passe sont hashés avec bcrypt et ne sont jamais stockés en clair
- Le champ `password` est masqué dans toutes les réponses JSON de l'API
- Chaque rôle possède ses propres routes API distinctes
- La réinitialisation de mot de passe génère un code temporaire affiché une seule fois

---

## Auteur

Projet développé par **ALIBO CORENTIN** — L3 Informatique 2026  
Dépôt GitHub : [roor-killa/mobileapp-2026](https://github.com/roor-killa/mobileapp-2026) — branche `alibo`