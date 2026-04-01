# UAPay payment and wallet fixes

## Main issues found

1. `backend/.env.example` had `CREDIT_ON_STATUS=false`.
   - Result: a Stripe payment could succeed but the wallet stayed unchanged whenever the webhook was not configured or not received.

2. Missing wallet rows were not healed consistently.
   - Result: some accounts could fail on balance loading or get a wrong balance after the first credit.

3. The backend CORS logic did not treat `ALLOWED_ORIGINS=*` as a real wildcard.
   - Result: browser/web builds could be blocked even though the config looked permissive.

4. The Stripe success/cancel redirects relied on placeholder/fallback URLs.
   - Result: the checkout return flow was fragile.

## What was changed

### Flutter app
- `mobile/lib/services/supabase_service.dart`
  - creates the wallet row on signup if it is missing
  - recreates a missing wallet automatically when reading the balance
  - recreates a missing profile automatically when needed
  - shows a clearer backend-unreachable error for real-phone testing

### Backend
- `backend/src/index.js`
  - enables real wildcard handling for `ALLOWED_ORIGINS=*`
  - adds `/success` and `/cancel` landing pages for Stripe Checkout
  - defaults Stripe fallback crediting to enabled unless explicitly disabled
  - restores missing wallets with the correct initial balance (`1500`)
  - returns `new_balance` after wallet crediting

### Supabase SQL
- `supabase/sql/live_fix_payment_and_wallets.sql`
  - backfills missing `profiles` and `wallets`
  - recreates the signup trigger
  - recreates `user_id_by_email` and `transfer_bkn`
  - re-applies the RLS policies used by the mobile app

## What to run now

1. Open Supabase SQL Editor.
2. Run `supabase/sql/live_fix_payment_and_wallets.sql`.
3. Restart the backend:
   - `docker compose down`
   - `docker compose up --build`
4. Test again from the app.

## Real phone note

If you test from a physical phone, `localhost` or `10.0.2.2` will not point to your PC.
Use:

```bash
flutter run --dart-define=STRIPE_BACKEND_BASE_URL=http://YOUR_PC_IP:4000
```
