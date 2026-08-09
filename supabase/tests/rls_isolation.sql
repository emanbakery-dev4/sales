begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;
select plan(16);

set local role authenticated;

select set_config('request.jwt.claim.sub', '20000000-0000-0000-0000-000000000004', true);
select results_eq(
  $$ select id from public.customers order by id $$,
  array['30000000-0000-0000-0000-000000000001'::uuid],
  'customer sees its linked customer identity only'
);
select results_eq(
  $$ select id from public.orders order by id $$,
  array['70000000-0000-0000-0000-000000000001'::uuid, '70000000-0000-0000-0000-000000000004'::uuid],
  'customer sees its own exact orders only'
);
select results_eq(
  $$ select id from public.ledger_transactions order by id $$,
  array['80000000-0000-0000-0000-000000000002'::uuid],
  'customer sees its own exact ledger entry only'
);

select set_config('request.jwt.claim.sub', '20000000-0000-0000-0000-000000000003', true);
select results_eq(
  $$ select id from public.customers order by id $$,
  array['30000000-0000-0000-0000-000000000001'::uuid, '30000000-0000-0000-0000-000000000002'::uuid],
  'staff sees exact customers in its branch only'
);
select results_eq(
  $$ select id from public.orders order by id $$,
  array['70000000-0000-0000-0000-000000000001'::uuid, '70000000-0000-0000-0000-000000000002'::uuid, '70000000-0000-0000-0000-000000000004'::uuid],
  'staff sees exact orders in its branch only'
);

select set_config('request.jwt.claim.sub', '20000000-0000-0000-0000-000000000002', true);
select results_eq(
  $$ select id from public.customers order by id $$,
  array['30000000-0000-0000-0000-000000000001'::uuid, '30000000-0000-0000-0000-000000000002'::uuid],
  'branch manager sees exact customers in its branch only'
);
select results_eq(
  $$ select id from public.orders order by id $$,
  array['70000000-0000-0000-0000-000000000001'::uuid, '70000000-0000-0000-0000-000000000002'::uuid, '70000000-0000-0000-0000-000000000004'::uuid],
  'branch manager sees exact orders in its branch only'
);

select set_config('request.jwt.claim.sub', '20000000-0000-0000-0000-000000000001', true);
select results_eq(
  $$ select id from public.customers order by id $$,
  array['30000000-0000-0000-0000-000000000001'::uuid, '30000000-0000-0000-0000-000000000002'::uuid, '30000000-0000-0000-0000-000000000003'::uuid],
  'master admin sees exact customers across branches'
);
select results_eq(
  $$ select id from public.orders order by id $$,
  array['70000000-0000-0000-0000-000000000001'::uuid, '70000000-0000-0000-0000-000000000002'::uuid, '70000000-0000-0000-0000-000000000003'::uuid, '70000000-0000-0000-0000-000000000004'::uuid],
  'master admin sees exact orders across branches'
);
select results_eq(
  $$ select record_id from public.audit_logs where record_type = 'ledger_transaction' order by record_id $$,
  array['80000000-0000-0000-0000-000000000001'::uuid, '80000000-0000-0000-0000-000000000002'::uuid],
  'seeded ledger writes have immutable audit records'
);

reset role;

select is(has_table_privilege('authenticated', 'public.orders', 'delete'), false, 'authenticated cannot delete orders');
select is(has_table_privilege('authenticated', 'public.order_items', 'delete'), false, 'authenticated cannot delete order items');
select is(has_table_privilege('authenticated', 'public.payments', 'delete'), false, 'authenticated cannot delete payments');
select is(has_table_privilege('authenticated', 'public.ledger_transactions', 'delete'), false, 'authenticated cannot delete ledger transactions');
select is(has_table_privilege('authenticated', 'public.customer_product_prices', 'delete'), false, 'authenticated cannot delete customer prices');
select is(has_table_privilege('authenticated', 'public.audit_logs', 'delete'), false, 'authenticated cannot delete audit logs');

select * from finish();
rollback;
