begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;
select plan(10);

set local role authenticated;

select set_config('request.jwt.claim.sub', '20000000-0000-0000-0000-000000000004', true);
select results_eq(
  $$ select count(*)::bigint from public.customers $$,
  array[1::bigint],
  'customer sees only its linked customer account'
);
select results_eq(
  $$ select count(*)::bigint from public.orders $$,
  array[1::bigint],
  'customer sees only its own orders'
);
select results_eq(
  $$ select count(*)::bigint from public.ledger_transactions $$,
  array[0::bigint],
  'customer cannot see another customer ledger'
);

select set_config('request.jwt.claim.sub', '20000000-0000-0000-0000-000000000003', true);
select results_eq(
  $$ select count(*)::bigint from public.customers $$,
  array[2::bigint],
  'staff sees customers in its branch only'
);
select results_eq(
  $$ select count(*)::bigint from public.orders $$,
  array[2::bigint],
  'staff sees orders in its branch only'
);

select set_config('request.jwt.claim.sub', '20000000-0000-0000-0000-000000000001', true);
select results_eq(
  $$ select count(*)::bigint from public.customers $$,
  array[3::bigint],
  'master admin sees customers across branches'
);
select results_eq(
  $$ select count(*)::bigint from public.orders $$,
  array[3::bigint],
  'master admin sees orders across branches'
);
select results_eq(
  $$ select count(*)::bigint from public.audit_logs $$,
  array[0::bigint],
  'master admin can query the audit trail'
);

reset role;

select is(
  has_table_privilege('authenticated', 'public.orders', 'delete'),
  false,
  'authenticated cannot delete orders'
);
select is(
  has_table_privilege('authenticated', 'public.ledger_transactions', 'delete'),
  false,
  'authenticated cannot delete ledger transactions'
);

select * from finish();
rollback;
