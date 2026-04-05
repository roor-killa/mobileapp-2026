# CampusConnect — Rapport Technique du Projet

**Application mobile Flutter — Plateforme étudiante**
**Année universitaire 2025–2026**

---

## Table des matières

1. [Présentation du projet](#1-présentation-du-projet)
2. [Outils et technologies utilisés](#2-outils-et-technologies-utilisés)
3. [Architecture de l'application](#3-architecture-de-lapplication)
4. [Base de données Supabase](#4-base-de-données-supabase)
5. [Fonctionnalités détaillées](#5-fonctionnalités-détaillées)
6. [Structure du code](#6-structure-du-code)
7. [Sécurité et bonnes pratiques](#7-sécurité-et-bonnes-pratiques)
8. [Étapes de développement suivies](#8-étapes-de-développement-suivies)

---

## 1. Présentation du projet

**CampusConnect** est une application mobile développée en Flutter, destinée aux étudiants du campus. Elle permet de centraliser la vie étudiante autour de quatre grandes fonctionnalités : les annonces, les événements, la messagerie instantanée, et un assistant intelligent.

### Objectifs
- Faciliter la communication entre étudiants
- Partager des annonces (cours, covoiturage, logement, entraide)
- Organiser et rejoindre des événements campus
- Échanger en messagerie privée
- Disposer d'un assistant virtuel pour naviguer dans l'app

### Informations techniques
| Élément | Détail |
|---|---|
| Framework | Flutter 3.5+ |
| Langage | Dart |
| Backend | Supabase (PostgreSQL + Auth + Storage) |
| Pattern d'architecture | Provider + Repository |
| Localisation | Français (fr_FR) |
| Plateforme cible | Android / iOS / Windows |

---

## 2. Outils et technologies utilisés

### Framework principal
- **Flutter** — Framework UI cross-platform de Google (Dart)
- **Dart** — Langage de programmation fortement typé

### Backend — Supabase
| Service Supabase | Usage |
|---|---|
| **Supabase Auth** | Inscription/connexion par email + mot de passe, réinitialisation, gestion des sessions |
| **PostgreSQL** | Base de données relationnelle principale (tables, vues, triggers, fonctions) |
| **Supabase Realtime** | Abonnements WebSocket pour les mises à jour en temps réel |
| **Supabase Storage** | Stockage des photos de profil et de couverture (bucket `avatars`) |
| **Supabase RPC** | Fonctions SQL appelées depuis Flutter (`get_or_create_conversation`) |

### Dépendances Flutter (pubspec.yaml)

| Package | Version | Rôle |
|---|---|---|
| `supabase_flutter` | ^2.5.0 | Connexion et requêtes Supabase |
| `provider` | ^6.1.2 | Gestion d'état (ChangeNotifier) |
| `image_picker` | ^1.1.2 | Sélection de photos depuis la galerie |
| `cached_network_image` | ^3.3.1 | Chargement optimisé des images réseau |
| `intl` | ^0.19.0 | Internationalisation et formatage des dates (fr_FR) |
| `timeago` | ^3.7.0 | Affichage des dates relatives ("il y a 2 minutes") |
| `shared_preferences` | ^2.3.2 | Persistance locale (préférence thème clair/sombre) |
| `google_fonts` | ^8.0.2 | Police personnalisée (Outfit) |
| `cupertino_icons` | ^1.0.8 | Icônes iOS |
| `flutter_launcher_icons` | ^0.14.3 | Génération de l'icône de l'app |

### Outils de développement
- **VS Code** avec extension Flutter/Dart
- **Android Studio / Emulateur Android** (API 36 — Android 16)
- **Supabase Dashboard** — Interface de gestion de la BDD et des politiques RLS
- **Git** — Contrôle de version

---

## 3. Architecture de l'application

### Schéma général

```
lib/
├── main.dart                    ← Point d'entrée, routage auth (_AuthGate)
├── models/                      ← Modèles de données (DTOs)
│   ├── user_model.dart
│   ├── announcement_model.dart
│   ├── event_model.dart
│   ├── message_model.dart
│   └── conversation_model.dart
├── providers/                   ← État global (ChangeNotifier)
│   ├── auth_provider.dart
│   └── theme_provider.dart
├── services/                    ← Couche d'accès aux données (Supabase)
│   ├── auth_service.dart
│   ├── announcement_service.dart
│   ├── event_service.dart
│   ├── message_service.dart
│   └── chatbot_service.dart
├── screens/                     ← Écrans de l'application
│   ├── splash/
│   ├── auth/
│   ├── home/
│   ├── announcements/
│   ├── events/
│   ├── messages/
│   ├── profile/
│   └── chatbot/
├── widgets/                     ← Composants UI réutilisables
└── utils/                       ← Thème, constantes, configuration
```

### Flux de données

```
Interface utilisateur (Screens)
        ↕  context.read / context.watch
Providers (AuthProvider, ThemeProvider)
        ↕  méthodes async
Services (AuthService, AnnouncementService, ...)
        ↕  Supabase SDK (HTTP + WebSocket)
Backend Supabase (PostgreSQL + Auth + Storage)
```

### Gestion de la navigation (main.dart)

Au démarrage, un widget `_AuthGate` observe l'état de `AuthProvider` et affiche dynamiquement l'écran approprié avec une transition en fondu animée (`AnimatedSwitcher`) :

- **Chargement** → `SplashScreen`
- **Non connecté** → `LoginScreen`
- **Connecté** → `HomeScreen`

---

## 4. Base de données Supabase

### Tables principales

| Table | Colonnes clés | Description |
|---|---|---|
| `users` | id, nom, email, bio, filiere, photo_url, cover_photo_url, date_inscription | Profils utilisateurs |
| `announcements` | id, titre, description, categorie, user_id, date_publication | Annonces étudiantes |
| `announcement_favoris` | id, announcement_id, user_id | Favoris des annonces |
| `events` | id, titre, description, lieu, date, organisateur_id | Événements campus |
| `event_participants` | id, event_id, user_id | Participants aux événements |
| `conversations` | id, dernier_message, dernier_message_date, dernier_message_expediteur_id | Conversations privées |
| `conversation_participants` | id, conversation_id, user_id | Participants d'une conversation |
| `messages` | id, conversation_id, expediteur_id, contenu, timestamp, lu | Messages échangés |

### Vues SQL (Views)

| Vue | Description |
|---|---|
| `announcements_full` | Annonces enrichies avec le nom et la photo de l'auteur, et le nombre de favoris |
| `events_full` | Événements enrichis avec les informations de l'organisateur et le nombre de participants |
| `conversations_with_other` | Conversations affichant l'autre participant (nom, photo) — définie avec `security_invoker` |

### Fonctions et triggers SQL

| Nom | Type | Rôle |
|---|---|---|
| `handle_new_user()` | Trigger AFTER INSERT sur `auth.users` | Crée automatiquement un profil dans `public.users` à chaque inscription |
| `update_conversation_last_message()` | Trigger AFTER INSERT sur `messages` | Met à jour `dernier_message` dans `conversations` à chaque nouveau message |
| `get_or_create_conversation(user1_id, user2_id)` | Fonction RPC | Retourne l'ID d'une conversation existante entre deux utilisateurs, ou en crée une nouvelle |
| `count_event_participants(evt_id)` | Fonction SQL | Retourne le nombre de participants à un événement |
| `user_in_conversation(conv_id, u_id)` | Fonction SQL | Vérifie si un utilisateur est membre d'une conversation |

### Row Level Security (RLS)

Toutes les tables ont le RLS activé. Les politiques permettent :
- Les utilisateurs lisent/modifient uniquement leurs propres données
- Les annonces et événements sont lisibles par tous les utilisateurs authentifiés
- Les messages ne sont accessibles qu'aux participants de la conversation

---

## 5. Fonctionnalités détaillées

### 5.1 Authentification

- **Inscription** : Email, mot de passe (min. 6 caractères), nom complet
- **Connexion** : Email + mot de passe avec messages d'erreur en français
- **Mot de passe oublié** : Envoi d'un lien de réinitialisation par email
- **Persistance de session** : La session Supabase est maintenue localement — l'utilisateur reste connecté après fermeture de l'app
- **Création automatique du profil** : Un trigger SQL crée l'entrée dans `public.users` dès l'inscription ; un fallback Flutter via `upsert` gère les cas où le trigger est en retard

### 5.2 Annonces

Les annonces couvrent 5 catégories avec code couleur :

| Catégorie | Couleur | Icône |
|---|---|---|
| Cours | Bleu | school |
| Covoiturage | Vert | directions_car |
| Logement | Orange | home |
| Entraide | Violet | handshake |
| Autre | Gris | more_horiz |

**Fonctionnalités :**
- Flux en temps réel via PostgreSQL Realtime
- Filtrage par catégorie
- Recherche textuelle
- Ajouter/retirer des favoris
- Créer une annonce (utilisateurs authentifiés)
- Supprimer ses propres annonces
- Contacter l'auteur directement depuis le détail

### 5.3 Événements

- Création d'événements avec titre, description, lieu, date/heure
- Validation de la date (pas dans le passé)
- Rejoindre / quitter un événement
- Compteur de participants en temps réel
- Affichage distinctif pour les événements passés (grisé + badge "Passé")
- Suppression possible par l'organisateur uniquement

### 5.4 Messagerie instantanée

- **Conversations privées** entre deux utilisateurs
- Création automatique de conversation via la fonction RPC `get_or_create_conversation`
- Accès depuis la recherche d'utilisateurs ou depuis une annonce ("Contacter")
- Messages en temps réel (Stream Supabase)
- Dernier message et date affichés dans la liste des conversations
- Horodatage relatif en français ("il y a 5 minutes")
- Défilement automatique vers le dernier message

### 5.5 Profil utilisateur

- Photo de profil circulaire avec initiales en fallback
- Photo de couverture (bandeau)
- Bio et filière/formation
- Onglet "Posts" : annonces publiées par l'utilisateur
- Onglet "À propos" : email, date d'inscription
- Compteurs abonnés/abonnements
- Modification du profil avec upload de photos (compression automatique)
- Basculement thème clair/sombre persisté localement
- Déconnexion

### 5.6 Assistant Chatbot

- Accessible depuis un bouton flottant animé disponible sur tous les écrans
- Réponses basées sur des règles par correspondance de mots-clés (en français)
- Peut suggérer une navigation directe vers une autre section de l'app
- Simulation d'un délai de frappe pour un rendu naturel

### 5.7 Écran de démarrage (Splash)

- Image de fond aléatoire parmi les photos du dossier `assets/images/splash/`
- Animation du logo (fondu + zoom)
- Indicateur de chargement
- Transition animée vers l'écran suivant (`AnimatedSwitcher`)

---

## 6. Structure du code

### Modèles de données

Chaque modèle implémente :
- `fromJson(Map<String, dynamic>)` — désérialisation depuis Supabase
- `toMap()` — sérialisation pour les insertions
- `copyWith()` — création d'une copie modifiée (immutabilité)

### Services (couche données)

Les services retournent des `Stream<List<Model>>` pour les données temps réel, ou des `Future<void>` pour les opérations d'écriture. Chaque service gère :
- L'abonnement au canal Realtime Supabase
- La fermeture propre du canal à la destruction du widget (`StreamController.onCancel`)

### Providers (état global)

`AuthProvider` :
- Écoute `authStateChanges` de Supabase
- Gère les états `loading`, `user`, `error`
- Mappe les erreurs d'authentification en messages français lisibles

`ThemeProvider` :
- Charge la préférence thème depuis `SharedPreferences`
- Expose `lightTheme` et `darkTheme` (Material 3)

### Widgets réutilisables

| Widget | Description |
|---|---|
| `GlassCard` | Carte avec effet glassmorphisme (flou + transparence) |
| `UserAvatar` | Avatar circulaire avec photo réseau ou initiales en fallback |
| `AnnouncementCard` | Carte d'annonce avec badge catégorie, favoris, suppression |
| `EventCard` | Carte événement avec bouton rejoindre/quitter et badge "Passé" |
| `ChatBubble` | Bulle de message différenciée expéditeur/destinataire |

---

## 7. Sécurité et bonnes pratiques

### Corrections de sécurité appliquées

Plusieurs audits de sécurité Supabase ont été traités durant le développement :

| Problème | Solution |
|---|---|
| **Vue avec SECURITY DEFINER** (`conversations_with_other`) | Recréée avec `security_invoker = true` pour que le RLS de l'utilisateur s'applique |
| **Fonctions sans `search_path` fixe** | Toutes les fonctions SQL recréées avec `SET search_path = ''` |
| **RLS manquant sur les tables** | Politiques INSERT/SELECT/UPDATE/DELETE créées pour toutes les tables |
| **Trigger `handle_new_user` sans search_path** | Recréé avec `SET search_path = ''` et `SECURITY DEFINER` |
| **Erreur "violates row level security"** | Ajout des politiques RLS manquantes + configuration du bucket storage |

### Bonnes pratiques appliquées

- Toutes les références dans les fonctions SQL sont préfixées `public.`
- Les données utilisateur ne sont accessibles que via `auth.uid() = user_id`
- Les photos sont stockées dans des sous-dossiers par `userId` (`userId/avatar.jpg`)
- Les erreurs sont capturées et exposées à l'utilisateur en français (pas de messages génériques silencieux)
- Session persistée automatiquement par `supabase_flutter`

---

## 8. Étapes de développement suivies

### Phase 1 — Mise en place du projet
1. Création du projet Flutter (`flutter create campusconnect`)
2. Configuration de `pubspec.yaml` avec toutes les dépendances
3. Initialisation Supabase dans `main.dart`
4. Création des tables PostgreSQL dans le Dashboard Supabase
5. Configuration du thème (light/dark) avec Material 3 et la police Outfit

### Phase 2 — Authentification
6. Implémentation de `AuthService` (signUp, signIn, signOut)
7. Création du trigger `handle_new_user()` pour la création automatique de profil
8. Développement de `AuthProvider` avec écoute des états Supabase
9. Écrans `LoginScreen` et `RegisterScreen` avec animations
10. Écran `SplashScreen` avec image aléatoire
11. Correction de la persistance de session (fallback `upsert` dans `getCurrentUserModel`)

### Phase 3 — Fonctionnalités principales
12. Système d'annonces complet (CRUD + favoris + temps réel)
13. Système d'événements (CRUD + participation + temps réel)
14. Messagerie privée (conversations + messages + RPC SQL)
15. Profil utilisateur avec upload de photos vers Supabase Storage

### Phase 4 — Navigation et UX
16. `HomeScreen` avec bottom navigation bar (4 onglets)
17. FAB contextuel (selon l'onglet actif)
18. Chatbot assistant avec règles de navigation
19. Vue `conversations_with_other` pour la liste des conversations
20. Animations de transition (FadeTransition, SlideTransition, ScaleTransition)

### Phase 5 — Sécurité et corrections
21. Correction de l'erreur RLS "new row violates row level security policy"
22. Ajout des politiques RLS sur toutes les tables et le bucket storage
23. Recréation de la vue `conversations_with_other` avec `security_invoker`
24. Pinning du `search_path` sur toutes les fonctions SQL (`SET search_path = ''`)
25. Correction des messages d'erreur silencieux dans `updateProfile`

### Phase 6 — Finalisation
26. Transitions animées Splash → Login/Home via `AnimatedSwitcher`
27. Fond de l'écran de connexion avec images du campus (Martinique/Guadeloupe)
28. Analyse statique (`flutter analyze`) — 0 erreur

---

## Statistiques du projet

| Métrique | Valeur |
|---|---|
| Nombre d'écrans | 13 |
| Nombre de services | 5 |
| Nombre de modèles | 5 |
| Nombre de providers | 2 |
| Nombre de widgets réutilisables | 5 |
| Dépendances principales | 10 |
| Tables Supabase | 8 |
| Vues SQL | 3 |
| Fonctions/Triggers SQL | 5 |
| Lignes de code (estimé) | ~4 000 |

---

*Document généré le 1er avril 2026 — CampusConnect v1.0*
