begin;

create extension if not exists pgcrypto with schema extensions;

create type public.account_status as enum ('active', 'inactive', 'frozen');
create type public.app_role as enum ('customer', 'staff', 'branch_manager', 'master_admin');
create type public.price_status as enum ('active', 'superseded');

create table public.branches (
  id uuid primary key default extensions.gen_random_uuid(),
  name text not null check (length(trim(name)) between 2 and 120),
  address text not null default '',
  status public.account_status not null default 'active',
  settings_override jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.roles (
  id uuid primary key default extensions.gen_random_uuid(),
  name public.app_role not null unique,
  description text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.users (
  id uuid primary key references auth.users(id) on delete restrict,
  email text not null,
  phone text,
  full_name text not null check (length(trim(full_name)) >= 2),
  role_id uuid not null references public.roles(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  status public.account_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (email)
);

create table public.role_permissions (
  id uuid primary key default extensions.gen_random_uuid(),
  role_id uuid not null references public.roles(id) on delete cascade,
  capability_key text not null check (capability_key ~ '^[a-z][a-z0-9_.-]+$'),
  allowed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (role_id, capability_key)
);

create table public.customers (
  id uuid primary key default extensions.gen_random_uuid(),
  business_name text not null check (length(trim(business_name)) >= 2),
  contact_person text not null,
  phone text not null,
  whatsapp text,
  address text not null default '',
  account_code text not null unique,
  branch_id uuid not null references public.branches(id) on delete restrict,
  status public.account_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.customer_user_links (
  id uuid primary key default extensions.gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete restrict,
  customer_id uuid not null references public.customers(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, customer_id)
);

create table public.product_categories (
  id uuid primary key default extensions.gen_random_uuid(),
  name text not null unique,
  display_order integer not null default 0 check (display_order >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default extensions.gen_random_uuid(),
  name text not null check (length(trim(name)) >= 2),
  sku text not null unique,
  category_id uuid not null references public.product_categories(id) on delete restrict,
  unit_of_measure text not null,
  base_price numeric(12,2) not null check (base_price >= 0),
  image_url text,
  status public.account_status not null default 'active',
  display_order integer not null default 0 check (display_order >= 0),
  tags text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.customer_product_prices (
  id uuid primary key default extensions.gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete restrict,
  price numeric(12,2) not null check (price >= 0),
  effective_date timestamptz not null default now(),
  changed_by uuid not null references public.users(id) on delete restrict,
  change_reason text not null check (length(trim(change_reason)) >= 3),
  previous_price numeric(12,2) check (previous_price is null or previous_price >= 0),
  status public.price_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index customer_product_prices_one_active
  on public.customer_product_prices(customer_id, product_id) where status = 'active';

create table public.audit_logs (
  id uuid primary key default extensions.gen_random_uuid(),
  user_id uuid references public.users(id) on delete restrict,
  action_type text not null,
  module text not null,
  record_type text not null,
  record_id uuid,
  previous_value jsonb,
  new_value jsonb,
  reason text,
  customer_id uuid references public.customers(id) on delete restrict,
  order_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index users_branch_id_idx on public.users(branch_id);
create index customers_branch_id_idx on public.customers(branch_id);
create index customer_user_links_user_id_idx on public.customer_user_links(user_id);
create index customer_product_prices_lookup_idx on public.customer_product_prices(customer_id, product_id, effective_date desc);
create index audit_logs_record_idx on public.audit_logs(record_type, record_id, created_at desc);

create function public.current_app_role() returns public.app_role
language sql stable security definer set search_path = ''
as $$
  select r.name from public.users u join public.roles r on r.id = u.role_id
  where u.id = (select auth.uid()) and u.status = 'active'
$$;

create function public.current_branch_id() returns uuid
language sql stable security definer set search_path = ''
as $$ select branch_id from public.users where id = (select auth.uid()) and status = 'active' $$;

create function public.is_master_admin() returns boolean
language sql stable security definer set search_path = ''
as $$ select coalesce(public.current_app_role() = 'master_admin', false) $$;

create function public.is_staff() returns boolean
language sql stable security definer set search_path = ''
as $$ select coalesce(public.current_app_role() in ('staff','branch_manager','master_admin'), false) $$;

create function public.can_access_customer(target_customer_id uuid) returns boolean
language sql stable security definer set search_path = ''
as $$
  select public.is_master_admin()
    or (public.is_staff() and exists (
      select 1 from public.customers c
      where c.id = target_customer_id and c.branch_id = public.current_branch_id()
    ))
    or exists (
      select 1 from public.customer_user_links l
      where l.user_id = (select auth.uid()) and l.customer_id = target_customer_id
    )
$$;

create function public.set_updated_at() returns trigger
language plpgsql set search_path = ''
as $$ begin new.updated_at = now(); return new; end $$;

create trigger branches_updated_at before update on public.branches for each row execute function public.set_updated_at();
create trigger roles_updated_at before update on public.roles for each row execute function public.set_updated_at();
create trigger users_updated_at before update on public.users for each row execute function public.set_updated_at();
create trigger role_permissions_updated_at before update on public.role_permissions for each row execute function public.set_updated_at();
create trigger customers_updated_at before update on public.customers for each row execute function public.set_updated_at();
create trigger customer_user_links_updated_at before update on public.customer_user_links for each row execute function public.set_updated_at();
create trigger product_categories_updated_at before update on public.product_categories for each row execute function public.set_updated_at();
create trigger products_updated_at before update on public.products for each row execute function public.set_updated_at();
create trigger customer_product_prices_updated_at before update on public.customer_product_prices for each row execute function public.set_updated_at();

alter table public.branches enable row level security;
alter table public.roles enable row level security;
alter table public.users enable row level security;
alter table public.role_permissions enable row level security;
alter table public.customers enable row level security;
alter table public.customer_user_links enable row level security;
alter table public.product_categories enable row level security;
alter table public.products enable row level security;
alter table public.customer_product_prices enable row level security;
alter table public.audit_logs enable row level security;

create policy branches_read on public.branches for select to authenticated
  using (public.is_master_admin() or id = public.current_branch_id());
create policy branches_admin on public.branches for all to authenticated
  using (public.is_master_admin()) with check (public.is_master_admin());
create policy roles_read on public.roles for select to authenticated using (true);
create policy roles_admin on public.roles for all to authenticated
  using (public.is_master_admin()) with check (public.is_master_admin());
create policy users_self_or_staff_read on public.users for select to authenticated
  using (id = (select auth.uid()) or public.is_master_admin() or (public.is_staff() and branch_id = public.current_branch_id()));
create policy users_admin_write on public.users for all to authenticated
  using (public.is_master_admin()) with check (public.is_master_admin());
create policy permissions_read on public.role_permissions for select to authenticated using (true);
create policy permissions_admin on public.role_permissions for all to authenticated
  using (public.is_master_admin()) with check (public.is_master_admin());
create policy customers_read on public.customers for select to authenticated
  using (public.can_access_customer(id));
create policy customers_staff_write on public.customers for all to authenticated
  using (public.is_master_admin() or (public.is_staff() and branch_id = public.current_branch_id()))
  with check (public.is_master_admin() or (public.is_staff() and branch_id = public.current_branch_id()));
create policy customer_links_read on public.customer_user_links for select to authenticated
  using (user_id = (select auth.uid()) or public.is_staff());
create policy customer_links_admin on public.customer_user_links for all to authenticated
  using (public.is_master_admin()) with check (public.is_master_admin());
create policy categories_read on public.product_categories for select to authenticated using (true);
create policy categories_staff_write on public.product_categories for all to authenticated
  using (public.is_staff()) with check (public.is_staff());
create policy products_read on public.products for select to authenticated using (true);
create policy products_staff_write on public.products for all to authenticated
  using (public.is_staff()) with check (public.is_staff());
create policy customer_prices_read on public.customer_product_prices for select to authenticated
  using (public.can_access_customer(customer_id));
create policy audit_admin_read on public.audit_logs for select to authenticated using (public.is_master_admin());

revoke all on public.audit_logs from anon, authenticated;
grant select on public.audit_logs to authenticated;
revoke delete on public.customer_product_prices, public.audit_logs from anon, authenticated;
revoke insert, update, delete on public.customer_product_prices from anon, authenticated;

insert into public.roles(name, description) values
  ('customer', 'Wholesale customer account'),
  ('staff', 'Central ordering and operations staff'),
  ('branch_manager', 'Branch-scoped operational manager'),
  ('master_admin', 'System-wide administrator');

commit;
