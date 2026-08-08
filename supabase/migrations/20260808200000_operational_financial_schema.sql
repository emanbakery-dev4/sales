begin;

create type public.order_source as enum ('customer', 'staff_phone', 'staff_counter', 'reorder');
create type public.order_status as enum ('draft', 'submitted', 'queued', 'finalized', 'ready_for_pickup', 'assigned', 'out_for_delivery', 'delivered', 'collected', 'cancelled');
create type public.ledger_entry_type as enum ('credit_sale', 'payment', 'payment_reversal', 'adjustment');
create type public.payment_method as enum ('cash', 'bank_transfer');
create type public.delivery_status as enum ('ready', 'assigned', 'out_for_delivery', 'delivered', 'collected', 'failed');

create table public.carts (
  id uuid primary key default extensions.gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete restrict,
  created_by_user_id uuid not null references public.users(id) on delete restrict,
  source public.order_source not null default 'customer',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique (customer_id, created_by_user_id)
);
create table public.cart_items (
  id uuid primary key default extensions.gen_random_uuid(),
  cart_id uuid not null references public.carts(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete restrict,
  quantity numeric(12,3) not null check (quantity > 0),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique (cart_id, product_id)
);
create table public.orders (
  id uuid primary key default extensions.gen_random_uuid(),
  order_number bigint generated always as identity unique,
  customer_id uuid not null references public.customers(id) on delete restrict,
  created_by_user_id uuid not null references public.users(id) on delete restrict,
  source public.order_source not null,
  status public.order_status not null default 'submitted',
  branch_id uuid not null references public.branches(id) on delete restrict,
  customer_note text, internal_note text,
  total_amount numeric(14,2) not null default 0 check (total_amount >= 0),
  delivery_pref jsonb not null default '{}'::jsonb,
  finalized_at timestamptz, cancelled_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check ((status <> 'finalized') or finalized_at is not null)
);
create table public.order_items (
  id uuid primary key default extensions.gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete restrict,
  product_name_snapshot text not null,
  unit_price_snapshot numeric(12,2) not null check (unit_price_snapshot >= 0),
  quantity numeric(12,3) not null check (quantity > 0),
  line_total numeric(14,2) generated always as (round(unit_price_snapshot * quantity, 2)) stored,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique (order_id, product_id)
);
create table public.order_revisions (
  id uuid primary key default extensions.gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  changed_by uuid not null references public.users(id) on delete restrict,
  field text not null, previous_value jsonb, new_value jsonb, reason text not null,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.order_status_history (
  id uuid primary key default extensions.gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  status public.order_status not null,
  changed_by uuid not null references public.users(id) on delete restrict,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.ledger_transactions (
  id uuid primary key default extensions.gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete restrict,
  type public.ledger_entry_type not null,
  amount numeric(14,2) not null check (amount > 0),
  reference_id uuid not null, reference_type text not null,
  running_balance numeric(14,2) not null,
  created_by uuid not null references public.users(id) on delete restrict,
  reverses_transaction_id uuid references public.ledger_transactions(id) on delete restrict,
  note text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique (reference_type, reference_id, type)
);
create table public.payments (
  id uuid primary key default extensions.gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete restrict,
  amount numeric(14,2) not null check (amount > 0), method public.payment_method not null,
  bank_reference text, receipt_number text not null unique,
  recorded_by uuid not null references public.users(id) on delete restrict,
  note text, reversed_at timestamptz, reversed_by uuid references public.users(id) on delete restrict,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (method <> 'bank_transfer' or nullif(trim(bank_reference), '') is not null)
);
create table public.drivers (
  id uuid primary key default extensions.gen_random_uuid(),
  name text not null, phone text not null, vehicle text,
  status public.account_status not null default 'active',
  branch_id uuid not null references public.branches(id) on delete restrict,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.deliveries (
  id uuid primary key default extensions.gen_random_uuid(),
  order_id uuid not null unique references public.orders(id) on delete restrict,
  driver_id uuid references public.drivers(id) on delete restrict,
  status public.delivery_status not null default 'ready',
  assigned_at timestamptz, delivered_at timestamptz, failure_reason text, proof_url text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.user_activity_logs (
  id uuid primary key default extensions.gen_random_uuid(),
  user_id uuid references public.users(id) on delete restrict,
  event_type text not null, ip_address inet, device text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.notifications (
  id uuid primary key default extensions.gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete restrict,
  type text not null, message text not null, read_at timestamptz,
  related_record_id uuid,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.automation_settings (
  id uuid primary key default extensions.gen_random_uuid(), key text not null unique,
  value jsonb not null, updated_by uuid not null references public.users(id) on delete restrict,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.system_settings (
  id uuid primary key default extensions.gen_random_uuid(), key text not null unique,
  value jsonb not null, updated_by uuid not null references public.users(id) on delete restrict,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

alter table public.audit_logs add constraint audit_logs_order_id_fkey foreign key (order_id) references public.orders(id) on delete restrict;

create index orders_customer_created_idx on public.orders(customer_id, created_at desc);
create index orders_branch_status_idx on public.orders(branch_id, status, created_at);
create index order_items_order_idx on public.order_items(order_id);
create index ledger_customer_created_idx on public.ledger_transactions(customer_id, created_at, id);
create index payments_customer_created_idx on public.payments(customer_id, created_at desc);
create index deliveries_driver_status_idx on public.deliveries(driver_id, status);
create index notifications_user_unread_idx on public.notifications(user_id, created_at desc) where read_at is null;

create trigger carts_updated_at before update on public.carts for each row execute function public.set_updated_at();
create trigger cart_items_updated_at before update on public.cart_items for each row execute function public.set_updated_at();
create trigger orders_updated_at before update on public.orders for each row execute function public.set_updated_at();
create trigger order_items_updated_at before update on public.order_items for each row execute function public.set_updated_at();
create trigger drivers_updated_at before update on public.drivers for each row execute function public.set_updated_at();
create trigger deliveries_updated_at before update on public.deliveries for each row execute function public.set_updated_at();
create trigger notifications_updated_at before update on public.notifications for each row execute function public.set_updated_at();
create trigger automation_settings_updated_at before update on public.automation_settings for each row execute function public.set_updated_at();
create trigger system_settings_updated_at before update on public.system_settings for each row execute function public.set_updated_at();

alter table public.carts enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.order_revisions enable row level security;
alter table public.order_status_history enable row level security;
alter table public.ledger_transactions enable row level security;
alter table public.payments enable row level security;
alter table public.drivers enable row level security;
alter table public.deliveries enable row level security;
alter table public.user_activity_logs enable row level security;
alter table public.notifications enable row level security;
alter table public.automation_settings enable row level security;
alter table public.system_settings enable row level security;

create policy carts_access on public.carts for all to authenticated using (public.can_access_customer(customer_id)) with check (public.can_access_customer(customer_id));
create policy cart_items_access on public.cart_items for all to authenticated using (exists (select 1 from public.carts c where c.id = cart_id and public.can_access_customer(c.customer_id))) with check (exists (select 1 from public.carts c where c.id = cart_id and public.can_access_customer(c.customer_id)));
create policy orders_read on public.orders for select to authenticated using (public.can_access_customer(customer_id));
create policy order_items_read on public.order_items for select to authenticated using (exists (select 1 from public.orders o where o.id = order_id and public.can_access_customer(o.customer_id)));
create policy revisions_read on public.order_revisions for select to authenticated using (exists (select 1 from public.orders o where o.id = order_id and public.can_access_customer(o.customer_id)));
create policy status_history_read on public.order_status_history for select to authenticated using (exists (select 1 from public.orders o where o.id = order_id and public.can_access_customer(o.customer_id)));
create policy ledger_read on public.ledger_transactions for select to authenticated using (public.can_access_customer(customer_id));
create policy payments_read on public.payments for select to authenticated using (public.can_access_customer(customer_id));
create policy drivers_staff on public.drivers for all to authenticated using (public.is_master_admin() or (public.is_staff() and branch_id = public.current_branch_id())) with check (public.is_master_admin() or (public.is_staff() and branch_id = public.current_branch_id()));
create policy deliveries_read on public.deliveries for select to authenticated using (exists (select 1 from public.orders o where o.id = order_id and public.can_access_customer(o.customer_id)));
create policy activity_admin_read on public.user_activity_logs for select to authenticated using (public.is_master_admin());
create policy notification_owner on public.notifications for select to authenticated using (user_id = (select auth.uid()));
create policy notification_owner_update on public.notifications for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy automation_staff_read on public.automation_settings for select to authenticated using (public.is_staff());
create policy automation_admin_write on public.automation_settings for all to authenticated using (public.is_master_admin()) with check (public.is_master_admin());
create policy settings_staff_read on public.system_settings for select to authenticated using (public.is_staff());
create policy settings_admin_write on public.system_settings for all to authenticated using (public.is_master_admin()) with check (public.is_master_admin());

revoke insert, update, delete on public.orders, public.order_items, public.order_revisions, public.order_status_history, public.ledger_transactions, public.payments from anon, authenticated;
revoke delete on public.customer_product_prices, public.orders, public.order_items, public.payments, public.ledger_transactions, public.audit_logs from anon, authenticated;
revoke update, delete on public.audit_logs, public.user_activity_logs from anon, authenticated;

commit;
