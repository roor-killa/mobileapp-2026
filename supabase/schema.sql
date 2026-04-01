-- =====================================================
-- UAPay (Supabase Postgres) — Publish-ready schema
--
-- What this file provides:
--   - profiles / wallets / transactions tables
--   - RLS policies (so the Flutter client can read/write its own rows)
--   - trigger to create profile+wallet automatically on signup
--   - RPC helpers:
--       * user_id_by_email(p_email)
--       * transfer_bkn(p_to, p_amount) -> json {success,message,new_balance}
--
-- IMPORTANT
--   Run this whole file once in Supabase SQL Editor.
-- =====================================================

-- 1) profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nom text not null default '',
  prenom text not null default '',
  telephone text not null default '',
  wallet_address text null,
  created_at timestamptz default now()
);

-- 2) wallets
create table if not exists public.wallets (
  user_id uuid primary key references auth.users(id) on delete cascade,
  balance_bkn numeric not null default 1500,
  updated_at timestamptz default now()
);

-- 3) transactions
create table if not exists public.transactions (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('BUY','SELL','TRANSFER_IN','TRANSFER_OUT')),
  amount_bkn numeric not null check (amount_bkn > 0),
  counterparty uuid null,
  status text not null default 'OK' check (status in ('OK','NOK')),
  note text null,
  created_at timestamptz default now()
);

-- =====================================================
-- RLS
-- =====================================================
alter table public.profiles enable row level security;
alter table public.wallets enable row level security;
alter table public.transactions enable row level security;

-- PROFILES
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
for select using (auth.uid() = id);

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
for insert with check (auth.uid() = id);

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
for update using (auth.uid() = id);

-- WALLETS
drop policy if exists wallets_select_own on public.wallets;
create policy wallets_select_own on public.wallets
for select using (auth.uid() = user_id);

drop policy if exists wallets_insert_own on public.wallets;
create policy wallets_insert_own on public.wallets
for insert with check (auth.uid() = user_id);

drop policy if exists wallets_update_own on public.wallets;
create policy wallets_update_own on public.wallets
for update using (auth.uid() = user_id);

-- TRANSACTIONS
drop policy if exists tx_select_own on public.transactions;
create policy tx_select_own on public.transactions
for select using (auth.uid() = user_id);

drop policy if exists tx_insert_own on public.transactions;
create policy tx_insert_own on public.transactions
for insert with check (auth.uid() = user_id);

-- =====================================================
-- Trigger: create profile + wallet on signup
-- =====================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id) values (new.id) on conflict do nothing;
  insert into public.wallets (user_id, balance_bkn) values (new.id, 1500) on conflict do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- =====================================================
-- RPC: find user id by email (case-insensitive)
-- =====================================================
create or replace function public.user_id_by_email(p_email text)
returns uuid
language sql
security definer
set search_path = public
as $$
  select id
  from auth.users
  where lower(email) = lower(p_email)
  limit 1;
$$;

-- =====================================================
-- RPC: atomic transfer (debit sender, credit receiver)
-- Returns JSON for easy UI handling.
-- =====================================================
create or replace function public.transfer_bkn(p_to uuid, p_amount numeric)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_from uuid := auth.uid();
  v_from_balance numeric;
  v_to_balance numeric;
begin
  if v_from is null then
    return json_build_object('success', false, 'message', 'Not authenticated');
  end if;
  if p_to is null then
    return json_build_object('success', false, 'message', 'Receiver missing');
  end if;
  if p_amount is null or p_amount <= 0 then
    return json_build_object('success', false, 'message', 'Amount invalid');
  end if;
  if p_to = v_from then
    return json_build_object('success', false, 'message', 'Cannot transfer to yourself');
  end if;

  -- Ensure wallets exist (safe no-op if already created)
  insert into public.wallets(user_id, balance_bkn)
  values (v_from, 1500)
  on conflict (user_id) do nothing;

  insert into public.wallets(user_id, balance_bkn)
  values (p_to, 1500)
  on conflict (user_id) do nothing;

  -- Lock sender wallet row
  select balance_bkn into v_from_balance
  from public.wallets
  where user_id = v_from
  for update;

  if v_from_balance is null then
    return json_build_object('success', false, 'message', 'Sender wallet not found');
  end if;

  if v_from_balance < p_amount then
    insert into public.transactions(user_id,type,amount_bkn,counterparty,status,note)
    values (v_from,'TRANSFER_OUT',p_amount,p_to,'NOK',null);
    return json_build_object('success', false, 'message', 'Solde insuffisant', 'new_balance', v_from_balance);
  end if;

  -- Lock receiver wallet row
  select balance_bkn into v_to_balance
  from public.wallets
  where user_id = p_to
  for update;

  if v_to_balance is null then
    return json_build_object('success', false, 'message', 'Receiver wallet not found');
  end if;

  -- Apply transfer
  update public.wallets
    set balance_bkn = v_from_balance - p_amount,
        updated_at = now()
    where user_id = v_from;

  update public.wallets
    set balance_bkn = v_to_balance + p_amount,
        updated_at = now()
    where user_id = p_to;

  -- Log both sides
  insert into public.transactions(user_id,type,amount_bkn,counterparty,status,note)
  values (v_from,'TRANSFER_OUT',p_amount,p_to,'OK',null);

  insert into public.transactions(user_id,type,amount_bkn,counterparty,status,note)
  values (p_to,'TRANSFER_IN',p_amount,v_from,'OK',null);

  return json_build_object('success', true, 'message', 'Transfert OK', 'new_balance', v_from_balance - p_amount);
end;
$$;
