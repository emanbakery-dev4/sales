-- Deterministic development data. These credentials are local/demo-only and must
-- never be copied to a production Supabase project.

insert into public.branches (id, name, address)
values
  ('10000000-0000-0000-0000-000000000001', 'Central Bakery', 'Industrial Area, Dubai'),
  ('10000000-0000-0000-0000-000000000002', 'Northern Branch', 'Al Qusais, Dubai');

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, email_change, email_change_token_new, recovery_token
)
values
  ('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'admin@emanbakery.test', crypt('DemoAdmin!2026', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Demo Administrator"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'manager@emanbakery.test', crypt('DemoManager!2026', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Central Manager"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'staff@emanbakery.test', crypt('DemoStaff!2026', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Order Desk Staff"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated', 'customer@emanbakery.test', crypt('DemoCustomer!2026', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Sunrise Cafe Buyer"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000005', 'authenticated', 'authenticated', 'other.customer@emanbakery.test', crypt('DemoCustomer!2026', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Harbour Hotel Buyer"}', now(), now(), '', '', '', '');

insert into auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
select id, id, id::text, jsonb_build_object('sub', id::text, 'email', email), 'email', now(), now(), now()
from auth.users
where id::text like '20000000-0000-0000-0000-00000000000%';

insert into public.users (id, email, phone, full_name, role_id, branch_id)
values
  ('20000000-0000-0000-0000-000000000001', 'admin@emanbakery.test', '+971500000001', 'Demo Administrator', (select id from public.roles where name = 'master_admin'), null),
  ('20000000-0000-0000-0000-000000000002', 'manager@emanbakery.test', '+971500000002', 'Central Manager', (select id from public.roles where name = 'branch_manager'), '10000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000003', 'staff@emanbakery.test', '+971500000003', 'Order Desk Staff', (select id from public.roles where name = 'staff'), '10000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000004', 'customer@emanbakery.test', '+971500000004', 'Sunrise Cafe Buyer', (select id from public.roles where name = 'customer'), '10000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000005', 'other.customer@emanbakery.test', '+971500000005', 'Harbour Hotel Buyer', (select id from public.roles where name = 'customer'), '10000000-0000-0000-0000-000000000002');

insert into public.customers (id, business_name, contact_person, phone, whatsapp, address, account_code, branch_id)
values
  ('30000000-0000-0000-0000-000000000001', 'Sunrise Cafe', 'Amina Rahman', '+971501110001', '+971501110001', 'Business Bay, Dubai', 'CUS-1001', '10000000-0000-0000-0000-000000000001'),
  ('30000000-0000-0000-0000-000000000002', 'Palm Grocery', 'Omar Khan', '+971501110002', '+971501110002', 'Jumeirah, Dubai', 'CUS-1002', '10000000-0000-0000-0000-000000000001'),
  ('30000000-0000-0000-0000-000000000003', 'Harbour Hotel', 'Sara Joseph', '+971501110003', '+971501110003', 'Dubai Creek, Dubai', 'CUS-2001', '10000000-0000-0000-0000-000000000002');

insert into public.customer_user_links (user_id, customer_id)
values
  ('20000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000003');

insert into public.product_categories (id, name, display_order)
values
  ('40000000-0000-0000-0000-000000000001', 'Bread', 10),
  ('40000000-0000-0000-0000-000000000002', 'Pastries', 20),
  ('40000000-0000-0000-0000-000000000003', 'Cakes', 30);

insert into public.products (id, name, sku, category_id, unit_of_measure, base_price, display_order, tags)
values
  ('50000000-0000-0000-0000-000000000001', 'Arabic Pita Pack', 'BRD-PITA-10', '40000000-0000-0000-0000-000000000001', 'pack of 10', 12.00, 10, array['daily','bread']),
  ('50000000-0000-0000-0000-000000000002', 'Sourdough Loaf', 'BRD-SOUR-01', '40000000-0000-0000-0000-000000000001', 'loaf', 16.50, 20, array['artisan','bread']),
  ('50000000-0000-0000-0000-000000000003', 'Butter Croissant', 'PAS-CROI-01', '40000000-0000-0000-0000-000000000002', 'piece', 5.00, 30, array['breakfast','pastry']),
  ('50000000-0000-0000-0000-000000000004', 'Chocolate Celebration Cake', 'CAK-CHOC-2K', '40000000-0000-0000-0000-000000000003', '2 kg cake', 145.00, 40, array['cake','celebration']);

insert into public.customer_product_prices (id, customer_id, product_id, price, changed_by, change_reason)
values
  ('60000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 10.50, '20000000-0000-0000-0000-000000000001', 'Demo contract price'),
  ('60000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000003', 4.25, '20000000-0000-0000-0000-000000000001', 'Demo contract price');

insert into public.orders (id, customer_id, created_by_user_id, source, status, branch_id, customer_note, total_amount, finalized_at, created_at)
values
  ('70000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'customer', 'queued', '10000000-0000-0000-0000-000000000001', 'Deliver before 8am', 63.50, null, now() - interval '25 minutes'),
  ('70000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000003', 'staff_phone', 'submitted', '10000000-0000-0000-0000-000000000001', null, 165.00, null, now() - interval '70 minutes'),
  ('70000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', 'staff_counter', 'finalized', '10000000-0000-0000-0000-000000000002', null, 290.00, now() - interval '1 day', now() - interval '1 day');

insert into public.order_items (order_id, product_id, product_name_snapshot, unit_price_snapshot, quantity)
values
  ('70000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 'Arabic Pita Pack', 10.50, 4),
  ('70000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000003', 'Butter Croissant', 4.25, 5),
  ('70000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000002', 'Sourdough Loaf', 16.50, 10),
  ('70000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000004', 'Chocolate Celebration Cake', 145.00, 2);

insert into public.order_status_history (order_id, status, changed_by, created_at)
values
  ('70000000-0000-0000-0000-000000000001', 'queued', '20000000-0000-0000-0000-000000000004', now() - interval '25 minutes'),
  ('70000000-0000-0000-0000-000000000002', 'submitted', '20000000-0000-0000-0000-000000000003', now() - interval '70 minutes'),
  ('70000000-0000-0000-0000-000000000003', 'finalized', '20000000-0000-0000-0000-000000000001', now() - interval '1 day');

insert into public.ledger_transactions (id, customer_id, type, amount, reference_id, reference_type, running_balance, created_by, created_at)
values ('80000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000003', 'credit_sale', 290.00, '70000000-0000-0000-0000-000000000003', 'order', 290.00, '20000000-0000-0000-0000-000000000001', now() - interval '1 day');
