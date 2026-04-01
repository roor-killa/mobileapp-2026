-- Patch for projects that created the tables manually but missed some columns
-- used by the Flutter app.

-- Add missing column 'status' on transactions (OK / NOK)
alter table if exists public.transactions
  add column if not exists status text not null default 'OK';

-- Add missing column 'counterparty' (email or user id) for transfers
alter table if exists public.transactions
  add column if not exists counterparty text;

-- If you created 'note' instead, keep it (app ignores it).
