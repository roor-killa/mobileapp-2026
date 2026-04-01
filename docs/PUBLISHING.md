# UAPay — Publishing checklist (production)

This repo contains:
- Flutter app (`mobileapp_prjtst_bkn/`)
- Node + Stripe backend (`backend/`)
- Supabase schema (`supabase/schema.sql`)

## 1) Supabase (production basics)
In Supabase Dashboard:
1. **Auth > URL Configuration**
   - Set **Site URL** to your production website / app link handler.
   - Add **Redirect URLs** for password reset + email confirmation deep links.
2. **Auth > Providers**
   - Keep Email enabled.
   - For app-store publishing, enable **Confirm email** (recommended).
3. Run the SQL schema:
   - SQL Editor → run `supabase/schema.sql`

## 2) Stripe (production basics)
- Create a Stripe account and switch to Live mode when ready.
- Set webhooks:
  - Endpoint: `https://<your-backend-domain>/stripe-webhook`
  - Events: `checkout.session.completed`
- Configure backend env:
  - `STRIPE_SECRET_KEY`
  - `STRIPE_WEBHOOK_SECRET`

## 3) Backend hardening (already included)
- `helmet` security headers
- Global rate limiting (`RATE_LIMIT_MAX`)
- CORS allowlist (`ALLOWED_ORIGINS`)

## 4) Flutter app store notes
- Replace Supabase keys in `lib/config.dart`
- On real phone, point `stripeBackendBaseUrl` to your HTTPS backend domain.
- Add your app icon + splash (Flutter launcher icons) before release builds.

## 5) Recommended next steps
- Add crash reporting (Sentry or Firebase Crashlytics).
- Add email deep-link handling for password recovery.
- Add stronger input validation & user-friendly error messages.


## Deep links (email confirmation & reset)
- App scheme configured: `uapay://auth`
- In Supabase Auth settings:
  - Site URL: set to your domain (if any)
  - Redirect URLs: add `uapay://auth`
- On Android/iOS, the project is pre-configured with this scheme.

## App icons & splash
Run:
- `flutter pub run flutter_launcher_icons`
- `flutter pub run flutter_native_splash:create`

## Android release signing
1. Generate a keystore (`keytool`)
2. Copy `android/key.properties.example` to `android/key.properties` and fill values.
3. Build: `flutter build appbundle`


## On-chain (optional demo / testnet)
Backend env to document if you use the EVM demo endpoint:
- `PORT`
- `EVM_RATE_LIMIT_PER_MIN`

Flutter `--dart-define` values to document for release/dev builds:
- `STRIPE_PUBLISHABLE_KEY`
- `STRIPE_BACKEND_BASE_URL`
- `EVM_RPC_URL`
- `EVM_CHAIN`
- `BKN_TOKEN_ADDRESS`
- `EVM_BACKEND_BASE_URL`

Hardhat deploy env:
- `RPC_URL`
- `PRIVATE_KEY`
