# Rapport de projet — NodEX (portefeuille crypto)

**Auteur :** meranville  
**Dépôt :** [mobileapp-2026](https://github.com/roor-killa/mobileapp-2026) — branche **`meranville`**  
**Chemin du projet dans le dépôt :** `project/crypto-wallet/`  
**Date du rapport :** mars 2026  

---

## 1. Résumé

J’ai développé **NodEX**, une application mobile de type **portefeuille crypto** avec des fonctions financières (soldes, envoi, historique, virements en euros, carte virtuelle côté API), une **authentification** gérée par **Appwrite**, un **assistant conversationnel** via **Groq**, et des paiements intégrés avec **Stripe** (SDK Flutter). Le tout s’appuie sur une **API REST Laravel** exposée sous `/api`. Ce document présente le travail réalisé, ce qui manque pour une **mise à disposition du grand public**, et les **sources** qui m’ont aidé.

---

## 2. Contexte et objectifs

- **Contexte :** projet mobile dans le cadre du cours / dépôt partagé L3 (application mobile 2026).  
- **Objectif initial :** disposer d’une application utilisable en **local** (simulateur ou téléphone) connectée à un **backend** documenté.  
- **Périmètre :** prototype avancé / **preuve de concept** orientée fintech, **pas** un produit bancaire agréé.

---

## 3. Description de la solution

### 3.1 Vue d’ensemble

| Couche | Technologie | Rôle |
|--------|-------------|------|
| Mobile | **Flutter** (Dart) | Interface, navigation, appels HTTP, intégration Appwrite / Stripe |
| Backend | **Laravel** (PHP) | API JSON, virements, chat Groq, données carte / portefeuilles côté serveur |
| Auth | **Appwrite** | Inscription, connexion, JWT / session selon configuration |
| IA | **Groq** | Complétions pour l’assistant (modèle type Llama 3.1 instantané) |
| Paiements | **Stripe** | Intégration côté app (clé publique, flux prévus dans le projet) |

### 3.2 Arborescence utile

- `flutter_app/` — code source Flutter (`pubspec.yaml`, `lib/`, scripts `run_ios_sim.sh`).  
- `backend-laravel/` — API Laravel (`routes/api.php`, contrôleurs, migrations, `.env.example`).  
- Documentation complémentaire dans le dépôt : `README.md` (racine), `STRIPE_SETUP.md`, `MIGRATION_VIREMENTS.md`, `VIREMENTS_AUDIT.md`, etc., selon ce qui est présent sur la branche.

### 3.3 API Laravel (extrait fonctionnel)

D’après `routes/api.php` :

- `GET /api/health` — contrôle de disponibilité.  
- `GET /api/card` — carte (côté utilisateur résolu par middleware).  
- `GET /api/wallets` — portefeuilles.  
- `POST /api/chat/groq` — message vers l’assistant Groq.  
- Préfixe `virements` : `balance`, `me`, `history`, `send`.  
- **Note technique :** une route `GET /api/debug/auth` existe pour le débogage du JWT ; elle est **à retirer** avant toute mise en production (voir section 5).

### 3.4 Application Flutter (aperçu des écrans / modules)

Parmi les écrans et flux : tableau de bord, portefeuilles, recevoir / envoyer, swap, achat, historique, virement bancaire, réglages (serveur API, assistant IA, sécurité, mot de passe, notifications), chat, écran « Ondes », thème sombre / dégradés (fichiers `app_theme.dart`, `panache_theme.dart`).

### 3.5 Dépendances Flutter principales (extrait `pubspec.yaml`)

`http`, `provider`, `appwrite`, `flutter_stripe`, `flutter_secure_storage`, `local_auth`, `shared_preferences`, `crypto`, `qr_flutter`, `animations`, `cupertino_icons`.

---

## 4. Méthode et mise en œuvre

1. Mise en place du backend Laravel (`.env`, Composer, migrations, `php artisan serve`).  
2. Développement de l’app Flutter et connexion à l’API (`API_BASE_URL` via `--dart-define` ou réglages in-app).  
3. Configuration Appwrite et variables sensibles **hors dépôt** (fichier `.env` ignoré par Git).  
4. Tests manuels sur simulateur iOS / appareil réel (réseau local, URL du Mac).  
5. Versionnement Git et push sur la branche **`meranville`**.

---

## 5. Ce qui manque pour un déploiement « grand public »

Ce projet est adapté au **développement et à la démonstration**. Pour une **publication large** (stores, utilisateurs inconnus, charge réelle), il faudrait notamment :

### 5.1 Produit et conformité

- **Statut légal :** services de paiement, crypto et « banking » sont **réglementés** (ex. Europe : DSP2, AML, licences selon l’activité). Un prototype étudiant **ne remplace pas** un cadre juridique ni un établissement agréé.  
- **CGU / politique de confidentialité / RGPD :** textes validés, base légale du traitement des données, droits utilisateurs, DPO si nécessaire.  
- **Mentions « démo / non régulé »** si l’app reste un projet pédagogique accessible publiquement.

### 5.2 Sécurité

- Supprimer **`/api/debug/auth`** et tout endpoint de debug en production.  
- **HTTPS** obligatoire partout (API, Appwrite, callbacks).  
- Secrets uniquement en variables d’environnement **serveur** ; rotation des clés ; principe du moindre privilège.  
- Revue des en-têtes CORS, limitation du débit (**rate limiting**), protection CSRF où pertinent (API stateless + JWT : valider signature et expiration).  
- Audit de sécurité (OWASP Mobile / API) et tests d’intrusion pour un vrai lancement.

### 5.3 Infrastructure

- Hébergement **géré** (serveur, base de données, sauvegardes, monitoring, logs centralisés).  
- **CI/CD** (tests automatiques, build signé iOS/Android).  
- **Scalabilité** (file d’attente pour tâches longues, cache si besoin).

### 5.4 Qualité et maintenance

- **Tests automatisés** (unitaires, intégration API, tests widget Flutter).  
- Gestion des **versions**, changelog, canal de **support** utilisateur.  
- **Accessibilité** (a11y) et **internationalisation** (i18n) si public multilingue.

### 5.5 Stores (Apple App Store, Google Play)

- Comptes développeur payants, fiches conformes aux guidelines, captures d’écran, politique de confidentialité hébergée en URL publique.  
- Déclaration des **achats intégrés** / Stripe selon les règles de chaque store.  
- Build **signé**, provisioning iOS, Android App Bundle.

### 5.6 Opérations financières réelles

- Compte **Stripe** (ou autre PSP) en mode **live**, webhooks sécurisés, conformité **PCI** (ne jamais stocker PAN en clair).  
- KYC / lutte contre la fraude si encaissement ou comptes utilisateurs réels.

En résumé : le travail actuel constitue une **base technique solide pour un projet universitaire** ; le passage au **grand public** implique juridique, sécurité, exploitation et qualité logicielle bien au-delà du périmètre d’un cours.

---

## 6. Difficultés rencontrées (exemples types)

- Faire coïncider l’**URL de l’API** entre simulateur, téléphone physique et machine hébergeant Laravel (adresse IP locale, pare-feu).  
- Gérer l’**authentification** (JWT Appwrite) côté Laravel et côté Flutter de manière cohérente.  
- Comprendre la **structure du dépôt** (Flutter dans un sous-dossier, pas à la racine).  
- Configurer **Stripe** et **Appwrite** sans commiter de secrets (`.env`, `.gitignore`).

*(À adapter avec mes propres anecdotes pour l’oral.)*

---

## 7. Conclusion

NodEX regroupe une **application Flutter**, une **API Laravel**, **Appwrite**, **Groq** et **Stripe** dans une expérience de portefeuille et de services associés. Le rendu est **démontrable en local** et documenté dans le `README.md` du dépôt. Pour une **diffusion publique**, il reste indispensable de traiter **légal**, **sécurité**, **hébergement**, **stores** et **exploitation** comme un produit à part entière.

---

## 8. Sources, documentation et ressources utilisées

Les liens ci-dessous sont les **sources officielles ou principales** qui m’ont aidé (documentation, outils, apprentissage). Les URL sont données en entier pour faciliter la vérification.

### 8.1 Frameworks et langages

| Ressource | URL |
|-----------|-----|
| Flutter — documentation | https://docs.flutter.dev/ |
| Dart — langage | https://dart.dev/ |
| Laravel — documentation | https://laravel.com/docs |
| PHP | https://www.php.net/docs.php |
| Composer (PHP) | https://getcomposer.org/doc/ |

### 8.2 Services et SDK utilisés dans le projet

| Ressource | URL |
|-----------|-----|
| Appwrite — documentation | https://appwrite.io/docs |
| Stripe — documentation développeurs | https://stripe.com/docs |
| Stripe — Flutter SDK (flutter_stripe) | https://pub.dev/packages/flutter_stripe |
| Groq — console / clés API | https://console.groq.com/ |
| Groq — documentation modèles API | https://console.groq.com/docs/models |

### 8.3 Packages Flutter (référence pub.dev)

| Package | URL |
|---------|-----|
| provider | https://pub.dev/packages/provider |
| http | https://pub.dev/packages/http |
| appwrite (SDK Dart) | https://pub.dev/packages/appwrite |
| flutter_secure_storage | https://pub.dev/packages/flutter_secure_storage |
| local_auth | https://pub.dev/packages/local_auth |
| shared_preferences | https://pub.dev/packages/shared_preferences |
| qr_flutter | https://pub.dev/packages/qr_flutter |
| animations | https://pub.dev/packages/animations |
| flutter_lints | https://pub.dev/packages/flutter_lints |

### 8.4 UI / design

| Ressource | URL |
|-----------|-----|
| Material Design 3 | https://m3.material.io/ |
| Panache (thème Flutter, référence historique dans le code) | https://github.com/rxlabz/panache |

### 8.5 Outils, versionnement, présentation

| Ressource | URL |
|-----------|-----|
| Git — documentation | https://git-scm.com/doc |
| GitHub | https://github.com/ |
| Gamma (présentations assistées par IA, si utilisé) | https://gamma.app/ |

### 8.6 Sécurité et bonnes pratiques (références générales)

| Ressource | URL |
|-----------|-----|
| OWASP Mobile Top 10 | https://owasp.org/www-project-mobile-top-10/ |
| CNIL — RGPD (information grand public) | https://www.cnil.fr/fr/rgpd-de-quoi-parle-t-on |

### 8.7 Dépôt du cours / du projet

| Ressource | URL |
|-----------|-----|
| Dépôt GitHub mobileapp-2026 | https://github.com/roor-killa/mobileapp-2026 |

---

## 9. Déclaration d’honnêteté académique

Je déclare que ce rapport décrit mon travail et que les sources externes sont citées dans la section 8. Les extraits de code tiers respectent les licences des projets concernés.

---

*Fin du rapport — fichier : `project/crypto-wallet/RAPPORT_RENDU_NODEX.md`*
