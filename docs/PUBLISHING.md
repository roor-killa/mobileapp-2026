# UAPay — Checklist de publication (production)

Ce dépôt contient :

- l’application Flutter (`mobileapp_prjtst_bkn/`)
- le backend Node.js + Stripe (`backend/`)
- le schéma Supabase (`supabase/schema.sql`)

---

## 1) Supabase (bases pour la production)

Dans le tableau de bord Supabase :

### Auth > URL Configuration
- définir la **Site URL** vers votre site de production ou le gestionnaire de liens profonds de l’application ;
- ajouter les **Redirect URLs** pour :
  - la réinitialisation de mot de passe ;
  - la confirmation d’email.

### Auth > Providers
- laisser **Email** activé ;
- pour une publication sur store, activer **Confirm email** (recommandé).

### Exécuter le schéma SQL
Dans **SQL Editor**, exécuter :

```sql
supabase/schema.sql
```

---

## 2) Stripe (bases pour la production)

- créer un compte Stripe ;
- passer en **mode Live** lorsque l’application est prête.

### Webhooks
Configurer un endpoint webhook :

```text
https://<votre-domaine-backend>/stripe-webhook
```

Événement à écouter :

```text
checkout.session.completed
```

### Variables d’environnement backend
Configurer :

- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`

---

## 3) Renforcement du backend (déjà inclus)

Le backend intègre déjà :

- les en-têtes de sécurité via **helmet** ;
- une limitation globale du débit via `RATE_LIMIT_MAX` ;
- une liste d’origines autorisées CORS via `ALLOWED_ORIGINS`.

---

## 4) Notes pour la publication de l’application Flutter

- remplacer les clés Supabase dans `lib/config.dart` ;
- sur un téléphone réel, pointer `stripeBackendBaseUrl` vers le domaine HTTPS du backend ;
- ajouter l’icône de l’application et le splash screen avant les builds de release.

---

## 5) Étapes recommandées ensuite

- ajouter un système de crash reporting (**Sentry** ou **Firebase Crashlytics**) ;
- ajouter une meilleure gestion des deep links email pour la récupération de mot de passe ;
- renforcer la validation des saisies et améliorer les messages d’erreur côté utilisateur.

---

## 6) Deep links (confirmation email et réinitialisation)

Schéma de l’application configuré :

```text
uapay://auth
```

Dans les paramètres **Supabase Auth** :

- **Site URL** : définir votre domaine si vous en avez un ;
- **Redirect URLs** : ajouter :

```text
uapay://auth
```

Sur Android et iOS, le projet est déjà préconfiguré avec ce schéma.

---

## 7) Icônes d’application et splash screen

Exécuter :

```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

---

## 8) Signature Android release

- générer un keystore avec `keytool` ;
- copier `android/key.properties.example` vers `android/key.properties` puis compléter les valeurs ;
- générer le build release avec :

```bash
flutter build appbundle
```

---

## 9) Partie on-chain (démo optionnelle / testnet)

### Variables backend à documenter si l’endpoint EVM est utilisé

- `PORT`
- `EVM_RATE_LIMIT_PER_MIN`

### Variables Flutter `--dart-define` à documenter pour les builds dev/release

- `STRIPE_PUBLISHABLE_KEY`
- `STRIPE_BACKEND_BASE_URL`
- `EVM_RPC_URL`
- `EVM_CHAIN`
- `BKN_TOKEN_ADDRESS`
- `EVM_BACKEND_BASE_URL`

### Variables d’environnement Hardhat à documenter

- `RPC_URL`
- `PRIVATE_KEY`
