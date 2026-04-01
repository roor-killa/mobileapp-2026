# UAPay — Supabase (base + auth + Stripe)

Ce projet utilise **Supabase** pour :

- l’authentification email / mot de passe ;
- la base de données (`profiles`, `wallets`, `transactions`) ;
- les fonctions SQL / RPC ;
- l’intégration côté données avec Stripe.

## 1) Renseigner les clés côté application

Utilise les variables d’environnement de `mobile/.env.example` ou les `--dart-define` suivants :

- `SUPABASE_URL=https://TON-PROJET.supabase.co`
- `SUPABASE_ANON_KEY=TON_SUPABASE_ANON_KEY`

> Ne mets jamais la `service_role_key` dans l’application Flutter.

## 2) Créer la base de données

Dans Supabase Dashboard → **SQL Editor** → **New query**, colle puis exécute :

- `supabase/sql/001_schema.sql`

## 3) Déployer les fonctions / services Stripe si tu utilises Supabase côté paiement

Si tu testes encore l’ancienne approche avec fonctions Supabase, l’erreur **404 Requested function was not found** signifie que la fonction n’est pas déployée.

### A) Installer Supabase CLI

- Windows (Scoop) : `scoop install supabase`
- ou via npm : `npm i -g supabase`

### B) Se connecter puis lier le projet

Depuis le dossier `mobile/` :

```bash
supabase login
supabase link --project-ref TON_PROJECT_REF
```

### C) Ajouter les secrets Stripe

```bash
supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_xxx
```

### D) Déployer les fonctions

```bash
supabase functions deploy create-checkout-session
supabase functions deploy stripe-webhook
```

## 4) Configurer le webhook Stripe (mode test)

Dans Stripe Dashboard → **Developers → Webhooks → Add endpoint** :

- Endpoint URL : `https://TON-PROJET.supabase.co/functions/v1/stripe-webhook`
- Event : `checkout.session.completed`

Copie ensuite le `Signing secret` (`whsec_...`) dans le secret `STRIPE_WEBHOOK_SECRET`.

## 5) Vérifier que tout fonctionne

### Vérifier un wallet

```sql
select * from public.wallets where user_id = 'TON_UUID';
```

### Vérifier les fonctions

Dans Supabase Dashboard → **Edge Functions** ou **Functions**, vérifie la présence de :

- `create-checkout-session`
- `stripe-webhook`

## 6) Remarque importante

Dans la version actuelle du projet, le flux principal de paiement passe surtout par le **backend Express** du dépôt racine. Cette note est conservée comme documentation utile si tu veux tester ou comparer une intégration Supabase Functions.
