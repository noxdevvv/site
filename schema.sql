-- Cole este script no Supabase: SQL Editor > New query > Run
-- Versão reforçada: RLS obrigatória, acesso só para usuários logados,
-- validações no banco e campos sensíveis protegidos contra alteração.

create table if not exists public.sales (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  created_at  timestamptz not null default now(),
  customer    text not null check (char_length(customer) between 1 and 80),
  product     text not null check (char_length(product)  between 1 and 80),
  quantity    integer       not null check (quantity > 0 and quantity <= 100000),
  unit_price  numeric(12,2) not null check (unit_price >= 0 and unit_price <= 10000000),
  total       numeric(16,2) generated always as (quantity * unit_price) stored
);

create index if not exists sales_user_created_idx on public.sales (user_id, created_at desc);

-- 1) RLS ligada e obrigatória (vale até para o dono da tabela)
alter table public.sales enable row level security;
alter table public.sales force  row level security;

-- 2) Visitantes sem login não têm nenhum acesso
revoke all on public.sales from anon, public;
revoke all on public.sales from authenticated;
grant select, insert, delete on public.sales to authenticated;
grant update (customer, product, quantity, unit_price) on public.sales to authenticated;

-- 3) Políticas: cada usuário só mexe nas próprias vendas
drop policy if exists "ver proprias vendas"     on public.sales;
drop policy if exists "inserir proprias vendas" on public.sales;
drop policy if exists "editar proprias vendas"  on public.sales;
drop policy if exists "excluir proprias vendas" on public.sales;

create policy "ver proprias vendas"     on public.sales for select to authenticated using ((select auth.uid()) = user_id);
create policy "inserir proprias vendas" on public.sales for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "editar proprias vendas"  on public.sales for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "excluir proprias vendas" on public.sales for delete to authenticated using ((select auth.uid()) = user_id);

-- 4) Trava: user_id e created_at nunca mudam depois de criados
create or replace function public.sales_lock_fields()
returns trigger language plpgsql security invoker set search_path = '' as $$
begin
  new.user_id    := old.user_id;
  new.created_at := old.created_at;
  return new;
end $$;

drop trigger if exists sales_lock_fields on public.sales;
create trigger sales_lock_fields before update on public.sales
for each row execute function public.sales_lock_fields();

-- 5) Tempo real (só adiciona se ainda não estiver)
do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'sales') then
    alter publication supabase_realtime add table public.sales;
  end if;
end $$;
