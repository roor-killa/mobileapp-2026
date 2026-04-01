-- ================================
-- UAPay — On-chain upgrade scaffold
-- ================================
-- Run this in Supabase SQL editor.

-- 1) Fix email -> user id lookup (for chatbot & transfer by email)
create or replace function public.user_id_by_email(p_email text)
returns uuid
language sql
security definer
set search_path = public, auth
as $$
  select id
  from auth.users
  where lower(email) = lower(p_email)
  limit 1;
$$;

revoke all on function public.user_id_by_email(text) from public;
grant execute on function public.user_id_by_email(text) to anon, authenticated;

-- 2) Add wallet address per user
alter table public.profiles
add column if not exists wallet_address text;

-- basic EVM address check (optional)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'wallet_address_format_check'
  ) THEN
    ALTER TABLE public.profiles
    ADD CONSTRAINT wallet_address_format_check
    CHECK (wallet_address is null or wallet_address ~* '^0x[a-f0-9]{40}$');
  END IF;
END $$;

-- 3) Store on-chain tx hashes
create table if not exists public.onchain_transactions (
  id uuid primary key default gen_random_uuid(),
  from_user_id uuid references public.profiles(id) on delete set null,
  to_user_id uuid references public.profiles(id) on delete set null,
  from_wallet text,
  to_wallet text,
  amount numeric not null,
  chain text not null,
  token_address text not null,
  tx_hash text not null,
  status text not null default 'PENDING',
  created_at timestamptz not null default now()
);

create index if not exists onchain_tx_from_idx on public.onchain_transactions(from_user_id);
create index if not exists onchain_tx_to_idx on public.onchain_transactions(to_user_id);
create index if not exists onchain_tx_hash_idx on public.onchain_transactions(tx_hash);
