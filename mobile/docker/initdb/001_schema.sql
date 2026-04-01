-- =========================
-- BKN Wallet schema (simple)
-- =========================

-- Profiles: extra user fields (nom/prenom/tel)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nom text not null default '',
  prenom text not null default '',
  telephone text not null default '',
  created_at timestamptz default now()
);

-- Wallets: 1 wallet per user
create table if not exists public.wallets (
  user_id uuid primary key references auth.users(id) on delete cascade,
  balance_bkn numeric not null default 1500,
  updated_at timestamptz default now()
);

-- Transactions
create table if not exists public.transactions (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('BUY','SELL','TRANSFER_IN','TRANSFER_OUT')),
  amount_bkn numeric not null check (amount_bkn > 0),
  counterparty uuid null,
  status text not null default 'OK' check (status in ('OK','NOK')),
  created_at timestamptz default now()
);

-- =========
-- RLS ON
-- =========
alter table public.profiles enable row level security;
alter table public.wallets enable row level security;
alter table public.transactions enable row level security;

create policy "profiles_select_own" on public.profiles
for select using (auth.uid() = id);

create policy "profiles_update_own" on public.profiles
for update using (auth.uid() = id);

create policy "wallets_select_own" on public.wallets
for select using (auth.uid() = user_id);

create policy "tx_select_own" on public.transactions
for select using (auth.uid() = user_id);

-- =========
-- Trigger: create profile + wallet on signup
-- =========
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id) values (new.id) on conflict do nothing;
  insert into public.wallets (user_id, balance_bkn) values (new.id, 1500) on conflict do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- =========
-- Helper: find user id by email (for transfers by email)
-- =========
create or replace function public.user_id_by_email(p_email text)
returns uuid
language sql
security definer
as $$
  select id from auth.users where email = p_email limit 1;
$$;

-- =========
-- RPC: atomic transfer (debit sender, credit receiver)
-- =========
create or replace function public.transfer_bkn(p_to uuid, p_amount numeric)
returns json
language plpgsql
security definer
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
  if p_amount <= 0 then
    return json_build_object('success', false, 'message', 'Amount invalid');
  end if;

  -- lock both wallets to avoid race conditions
  select balance_bkn into v_from_balance from public.wallets where user_id = v_from for update;
  if v_from_balance is null then
    return json_build_object('success', false, 'message', 'Sender wallet not found');
  end if;
  if v_from_balance < p_amount then
    insert into public.transactions(user_id,type,amount_bkn,counterparty,status)
    values (v_from,'TRANSFER_OUT',p_amount,p_to,'NOK');
    return json_build_object('success', false, 'message', 'Solde insuffisant', 'new_balance', v_from_balance);
  end if;

  select balance_bkn into v_to_balance from public.wallets where user_id = p_to for update;
  if v_to_balance is null then
    return json_build_object('success', false, 'message', 'Receiver wallet not found');
  end if;

  update public.wallets set balance_bkn = v_from_balance - p_amount, updated_at = now() where user_id = v_from;
  update public.wallets set balance_bkn = v_to_balance + p_amount, updated_at = now() where user_id = p_to;

  insert into public.transactions(user_id,type,amount_bkn,counterparty,status)
  values (v_from,'TRANSFER_OUT',p_amount,p_to,'OK');

  insert into public.transactions(user_id,type,amount_bkn,counterparty,status)
  values (p_to,'TRANSFER_IN',p_amount,v_from,'OK');

  return json_build_object('success', true, 'message', 'Transfert OK', 'new_balance', v_from_balance - p_amount);
end;
$$;
