-- =====================================================
-- UAPay — live fix for payment / wallet / transfer issues
-- Safe to run on an existing Supabase project.
-- =====================================================

begin;

-- ----------
-- Tables
-- ----------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nom text not null default '',
  prenom text not null default '',
  telephone text not null default '',
  wallet_address text null,
  created_at timestamptz default now()
);

create table if not exists public.wallets (
  user_id uuid primary key references auth.users(id) on delete cascade,
  balance_bkn numeric not null default 1500,
  updated_at timestamptz default now()
);

create table if not exists public.transactions (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null,
  amount_bkn numeric not null,
  counterparty uuid null,
  status text not null default 'OK',
  note text null,
  created_at timestamptz default now()
);

alter table public.profiles
  add column if not exists nom text not null default '',
  add column if not exists prenom text not null default '',
  add column if not exists telephone text not null default '',
  add column if not exists wallet_address text null,
  add column if not exists created_at timestamptz default now();

alter table public.wallets
  add column if not exists balance_bkn numeric not null default 1500,
  add column if not exists updated_at timestamptz default now();

alter table public.transactions
  add column if not exists counterparty uuid null,
  add column if not exists note text null,
  add column if not exists created_at timestamptz default now();

alter table public.wallets alter column balance_bkn set default 1500;
alter table public.wallets alter column updated_at set default now();

update public.wallets
set balance_bkn = 1500
where balance_bkn is null;

-- Backfill profile / wallet rows for all existing users.
insert into public.profiles (id)
select u.id
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null;

insert into public.wallets (user_id, balance_bkn, updated_at)
select u.id, 1500, now()
from auth.users u
left join public.wallets w on w.user_id = u.id
where w.user_id is null;

create index if not exists idx_transactions_user_created_at
  on public.transactions (user_id, created_at desc);

-- ----------
-- RLS
-- ----------
alter table public.profiles enable row level security;
alter table public.wallets enable row level security;
alter table public.transactions enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
for select using (auth.uid() = id);

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
for insert with check (auth.uid() = id);

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
for update using (auth.uid() = id);

drop policy if exists wallets_select_own on public.wallets;
create policy wallets_select_own on public.wallets
for select using (auth.uid() = user_id);

drop policy if exists wallets_insert_own on public.wallets;
create policy wallets_insert_own on public.wallets
for insert with check (auth.uid() = user_id);

drop policy if exists wallets_update_own on public.wallets;
create policy wallets_update_own on public.wallets
for update using (auth.uid() = user_id);

drop policy if exists tx_select_own on public.transactions;
create policy tx_select_own on public.transactions
for select using (auth.uid() = user_id);

drop policy if exists tx_insert_own on public.transactions;
create policy tx_insert_own on public.transactions
for insert with check (auth.uid() = user_id);

-- ----------
-- Trigger on signup
-- ----------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id) values (new.id)
  on conflict do nothing;

  insert into public.wallets (user_id, balance_bkn, updated_at)
  values (new.id, 1500, now())
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- ----------
-- RPCs used by the mobile app
-- ----------
create or replace function public.user_id_by_email(p_email text)
returns uuid
language sql
security definer
set search_path = public
as $$
  select id
  from auth.users
  where lower(email) = lower(trim(p_email))
  limit 1;
$$;

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

  insert into public.wallets(user_id, balance_bkn, updated_at)
  values (v_from, 1500, now())
  on conflict (user_id) do nothing;

  insert into public.wallets(user_id, balance_bkn, updated_at)
  values (p_to, 1500, now())
  on conflict (user_id) do nothing;

  select balance_bkn into v_from_balance
  from public.wallets
  where user_id = v_from
  for update;

  if v_from_balance is null then
    return json_build_object('success', false, 'message', 'Sender wallet not found');
  end if;

  if v_from_balance < p_amount then
    insert into public.transactions(user_id, type, amount_bkn, counterparty, status, note)
    values (v_from, 'TRANSFER_OUT', p_amount, p_to, 'NOK', null);

    return json_build_object(
      'success', false,
      'message', 'Solde insuffisant',
      'new_balance', v_from_balance
    );
  end if;

  select balance_bkn into v_to_balance
  from public.wallets
  where user_id = p_to
  for update;

  if v_to_balance is null then
    return json_build_object('success', false, 'message', 'Receiver wallet not found');
  end if;

  update public.wallets
     set balance_bkn = v_from_balance - p_amount,
         updated_at = now()
   where user_id = v_from;

  update public.wallets
     set balance_bkn = v_to_balance + p_amount,
         updated_at = now()
   where user_id = p_to;

  insert into public.transactions(user_id, type, amount_bkn, counterparty, status, note)
  values (v_from, 'TRANSFER_OUT', p_amount, p_to, 'OK', null);

  insert into public.transactions(user_id, type, amount_bkn, counterparty, status, note)
  values (p_to, 'TRANSFER_IN', p_amount, v_from, 'OK', null);

  return json_build_object(
    'success', true,
    'message', 'Transfert OK',
    'new_balance', v_from_balance - p_amount
  );
end;
$$;

grant execute on function public.user_id_by_email(text) to anon, authenticated, service_role;
grant execute on function public.transfer_bkn(uuid, numeric) to authenticated, service_role;

commit;
