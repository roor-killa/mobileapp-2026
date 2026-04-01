<<<<<<< Updated upstream
# mobileapp-2026
Création application mobile L3 2026

Sujet : 
Créer une application mobile qui référence toutes les entreprises de Martinique
=======
# 🔐 Guide Général — Gestionnaire de Mots de Passe
> Application mobile Flutter & Firebase  
> À destination des étudiants et enseignants — Licence 3 Informatique • 2025/2026

---

## 📋 Table des matières

1. [Le problème que l'app résout](#1--le-problème-que-lapp-résout)
2. [La solution — présentation de l'app](#2--la-solution--présentation-de-lapp)
3. [Les fonctionnalités](#3--les-fonctionnalités)
4. [Comment ça marche ?](#4--comment-ça-marche-)
5. [Les technologies utilisées](#5--les-technologies-utilisées)
6. [En résumé](#6--en-résumé)
7. [Et ensuite ?](#7--et-ensuite-)

---

## 1. 🤔 Le problème que l'app résout

> **Combien de mots de passe utilisez-vous chaque jour ?**

Dans notre vie numérique quotidienne, nous avons des dizaines de comptes à gérer : emails, réseaux sociaux, banque, applications scolaires, plateformes de streaming... Cela crée trois problèmes majeurs :

### 😰 Trop à retenir
Emails, réseaux sociaux, banque, apps... des dizaines de comptes ! Il est humainement impossible de mémoriser un mot de passe différent et complexe pour chacun.

### 🔓 Mots de passe faibles
Face à cette surcharge, on finit par réutiliser toujours les mêmes mots de passe par facilité. C'est pratique, mais très dangereux.

### 😱 Risque de piratage
Un seul mot de passe volé peut compromettre **tous** vos comptes si vous utilisez le même partout. Une seule fuite de données et c'est toute votre vie numérique qui est exposée.

---

➡️ **Notre solution** : une application mobile qui centralise et sécurise tous vos mots de passe en un seul endroit.

---

## 2. 💡 La solution — présentation de l'app

**Notre application** est un gestionnaire de mots de passe sécurisé, stocké dans le cloud et accessible depuis votre smartphone.

Elle vous permet de tout centraliser en un seul endroit :

```
┌─────────────────────────┐
│        Mon App          │
├─────────────────────────┤
│  Gmail        ••••••••  │
│  Netflix      ••••••••  │
│  Banque       ••••••••  │
├─────────────────────────┤
│    🏠       🔑       ⚙️  │
└─────────────────────────┘
```

### Ce que l'app fait pour vous

| Fonctionnalité | Description |
|---|---|
| ✅ Connexion sécurisée | Accès protégé par votre compte personnel |
| ✅ Stockage cloud Firebase | Données sauvegardées en temps réel |
| ✅ Notifications push | Alertes même quand l'app est fermée |
| ✅ Interface simple | Navigation claire et intuitive |

---

## 3. ⚙️ Les fonctionnalités

### 🔑 Connexion
Créez votre compte et connectez-vous en toute sécurité avec votre adresse email et votre mot de passe principal.

> Mot de passe oublié ? Pas de panique — un email de réinitialisation vous est automatiquement envoyé.

---

### 🗂️ Mes mots de passe
Stockez tous vos identifiants (site, login, mot de passe) en un seul endroit, accessible n'importe où et n'importe quand depuis votre smartphone.

**Comment ajouter un mot de passe :**
1. Appuyez sur le bouton **"+"**
2. Renseignez le nom du service, l'identifiant et le mot de passe
3. Appuyez sur **"Enregistrer"**
4. C'est tout ! Il apparaît immédiatement dans votre liste.

---

### ☁️ Stockage Cloud
Toutes vos données sont sauvegardées **en temps réel** sur **Firebase Firestore**, une base de données Google sécurisée.

Cela signifie que :
- Vos données ne sont **jamais perdues**, même si votre téléphone tombe en panne
- Elles sont **accessibles** dès que vous vous reconnectez, y compris sur un nouvel appareil
- Elles sont **isolées** : personne d'autre ne peut voir vos mots de passe

---

### 🔔 Notifications
Recevez des alertes sur votre téléphone **même quand l'app est fermée**, grâce à Firebase Cloud Messaging (FCM).

| État de l'app | Ce que vous voyez |
|---|---|
| App **ouverte** | Notification traitée en temps réel dans l'app |
| App **en arrière-plan** | Bandeau de notification en haut de l'écran |
| App **fermée** | Notification dans le centre de notifications Android |

---

## 4. 🔧 Comment ça marche ?

Le fonctionnement de l'application repose sur **3 étapes simples** :

```
  📱 Votre App          🔥 Firebase          🔔 Notification
  ─────────────    ▶    ───────────    ▶    ──────────────────
  Flutter sur           Auth +               Reçue sur
  Android               Firestore + FCM      le téléphone

  1. Vous saisissez     2. Firebase stocke   3. Vous recevez
     vos données           et sécurise          une alerte
```

> 💡 **Tout fonctionne en temps réel — pas besoin de rafraîchir !**

### Détail du parcours

**Étape 1 — Vous saisissez vos données**  
Vous entrez un nouveau mot de passe dans l'application sur votre téléphone Android. L'app Flutter envoie cette information au serveur Firebase.

**Étape 2 — Firebase stocke et sécurise**  
Firebase Firestore enregistre vos données de manière sécurisée dans le cloud Google. Firebase Auth vérifie que seul vous pouvez accéder à vos informations. FCM se tient prêt à vous envoyer des alertes.

**Étape 3 — Vous recevez une alerte**  
Si une notification est envoyée depuis la console Firebase, elle arrive directement sur votre téléphone, où que vous soyez, même si l'application est fermée.

---

## 5. 🛠️ Les technologies utilisées

| Emoji | Technologie | Rôle dans l'app |
|---|---|---|
| 🐦 | **Flutter** | Développement mobile cross-platform (iOS & Android depuis un seul code) |
| 🔥 | **Firebase** | Plateforme cloud de Google, backbone de l'application |
| 🔐 | **Auth** | Gestion de la connexion et sécurité des comptes utilisateurs |
| 📂 | **Firestore** | Stockage en temps réel des mots de passe dans le cloud |
| 🔔 | **FCM** | Firebase Cloud Messaging — envoi des notifications push |
| 🤖 | **Android Studio** | Émulateur Android utilisé pour tester l'application |

### Pourquoi Flutter ?
Flutter permet de développer **une seule application** qui fonctionne à la fois sur Android et iOS, ce qui représente un gain de temps considérable pour un projet académique.

### Pourquoi Firebase ?
Firebase est une solution tout-en-un de Google qui regroupe authentification, base de données et notifications dans un seul écosystème, facile à intégrer avec Flutter.

---

## 6. ✅ En résumé

> **Ce projet, c'est quoi ?**

Ce projet est une **application mobile complète** développée en moins d'un mois dans le cadre d'un projet de Licence 3 Informatique. Il démontre la mise en pratique de plusieurs compétences clés :

- ✅ **App Flutter complète** développée en moins d'un mois
- ✅ **Connexion sécurisée** + stockage cloud avec Firebase
- ✅ **Notifications push** fonctionnelles sur Android

### Ce que ce projet démontre

| Compétence | Mise en œuvre |
|---|---|
| Développement mobile | Application Flutter fonctionnelle multi-écrans |
| Intégration cloud | Firebase Auth + Firestore + FCM configurés et opérationnels |
| Architecture logicielle | Séparation models / screens / services |
| Sécurité | Authentification par compte, données isolées par utilisateur |
| Tests | Validation sur émulateur Android Studio (Pixel 6 — API 36) |

---

## 7. 🚀 Et ensuite ?

Ce projet est une base solide qui peut évoluer vers une application encore plus complète :

### Améliorations prévues

| Amélioration | Description |
|---|---|
| 🔒 **Chiffrement renforcé** | Chiffrer les mots de passe côté client avant de les envoyer à Firebase |
| 📲 **Authentification biométrique** | Se connecter avec son empreinte digitale ou Face ID |
| 🚀 **Publication sur le Play Store** | Rendre l'app accessible au grand public sur Android |
| 🔑 **Générateur de mots de passe** | Proposer des mots de passe forts générés automatiquement |
| 📤 **Export sécurisé** | Exporter ses données dans un fichier chiffré |

---

*Projet individuel — Licence 3 Informatique — 2025/2026*
>>>>>>> Stashed changes
