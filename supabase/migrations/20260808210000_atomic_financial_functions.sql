begin;

create function public.customer_balance(target_customer_id uuid) returns numeric
language sql stable security definer set search_path = ''
as $$
  select coalesce((select running_balance from public.ledger_transactions where customer_id = target_customer_id order by created_at desc, id desc limit 1), 0)::numeric(14,2)
$$;

create function public.change_customer_price(
  target_customer_id uuid, target_product_id uuid, new_price numeric, reason text
) returns public.customer_product_prices
language plpgsql security definer set search_path = ''
as $$
declare
  actor uuid := auth.uid(); old_row public.customer_product_prices; result public.customer_product_prices;
begin
  if actor is null or not public.is_staff() or not public.can_access_customer(target_customer_id) then raise exception 'permission_denied' using errcode = '42501'; end if;
  if new_price < 0 then raise exception 'invalid_price' using errcode = '22003'; end if;
  if length(trim(reason)) < 3 then raise exception 'change_reason_required' using errcode = '22023'; end if;
  if not exists (select 1 from public.products where id = target_product_id) then raise exception 'product_not_found' using errcode = 'P0002'; end if;

  select * into old_row from public.customer_product_prices
    where customer_id = target_customer_id and product_id = target_product_id and status = 'active' for update;
  if found then update public.customer_product_prices set status = 'superseded' where id = old_row.id; end if;

  insert into public.customer_product_prices(customer_id, product_id, price, changed_by, change_reason, previous_price)
  values (target_customer_id, target_product_id, new_price, actor, trim(reason), old_row.price) returning * into result;
  insert into public.audit_logs(user_id, action_type, module, record_type, record_id, previous_value, new_value, reason, customer_id)
  values (actor, 'price_changed', 'pricing', 'customer_product_prices', result.id, to_jsonb(old_row), to_jsonb(result), trim(reason), target_customer_id);
  return result;
end $$;

create function public.finalize_order(target_order_id uuid) returns public.orders
language plpgsql security definer set search_path = ''
as $$
declare
  actor uuid := auth.uid(); target public.orders; calculated_total numeric(14,2); balance numeric(14,2); result public.orders; ledger_id uuid;
begin
  if actor is null or not public.is_staff() then raise exception 'permission_denied' using errcode = '42501'; end if;
  select * into target from public.orders where id = target_order_id for update;
  if not found then raise exception 'order_not_found' using errcode = 'P0002'; end if;
  if not public.can_access_customer(target.customer_id) then raise exception 'permission_denied' using errcode = '42501'; end if;
  if target.status not in ('submitted', 'queued') then raise exception 'order_cannot_be_finalized' using errcode = '22023'; end if;
  select coalesce(sum(round(unit_price_snapshot * quantity, 2)), 0) into calculated_total from public.order_items where order_id = target_order_id;
  if calculated_total <= 0 then raise exception 'order_has_no_items' using errcode = '22023'; end if;

  perform pg_advisory_xact_lock(hashtextextended(target.customer_id::text, 0));
  balance := public.customer_balance(target.customer_id) + calculated_total;
  update public.orders set status = 'finalized', total_amount = calculated_total, finalized_at = now() where id = target_order_id returning * into result;
  insert into public.ledger_transactions(customer_id, type, amount, reference_id, reference_type, running_balance, created_by)
    values (target.customer_id, 'credit_sale', calculated_total, target_order_id, 'order', balance, actor) returning id into ledger_id;
  insert into public.order_status_history(order_id, status, changed_by) values (target_order_id, 'finalized', actor);
  insert into public.audit_logs(user_id, action_type, module, record_type, record_id, previous_value, new_value, customer_id, order_id)
    values (actor, 'order_finalized', 'orders', 'orders', target_order_id, to_jsonb(target), to_jsonb(result) || jsonb_build_object('ledger_transaction_id', ledger_id), target.customer_id, target_order_id);
  return result;
end $$;

create function public.record_payment(
  target_customer_id uuid, payment_amount numeric, payment_method public.payment_method,
  payment_bank_reference text, payment_receipt_number text, payment_note text default null
) returns public.payments
language plpgsql security definer set search_path = ''
as $$
declare
  actor uuid := auth.uid(); result public.payments; balance numeric(14,2); ledger_id uuid;
begin
  if actor is null or not public.is_staff() or not public.can_access_customer(target_customer_id) then raise exception 'permission_denied' using errcode = '42501'; end if;
  if payment_amount <= 0 then raise exception 'payment_amount_must_be_positive' using errcode = '22003'; end if;
  if payment_method = 'bank_transfer' and nullif(trim(payment_bank_reference), '') is null then raise exception 'bank_reference_required' using errcode = '22023'; end if;
  if nullif(trim(payment_receipt_number), '') is null then raise exception 'receipt_number_required' using errcode = '22023'; end if;

  perform pg_advisory_xact_lock(hashtextextended(target_customer_id::text, 0));
  balance := public.customer_balance(target_customer_id) - payment_amount;
  insert into public.payments(customer_id, amount, method, bank_reference, receipt_number, recorded_by, note)
    values (target_customer_id, payment_amount, payment_method, nullif(trim(payment_bank_reference), ''), trim(payment_receipt_number), actor, payment_note) returning * into result;
  insert into public.ledger_transactions(customer_id, type, amount, reference_id, reference_type, running_balance, created_by)
    values (target_customer_id, 'payment', payment_amount, result.id, 'payment', balance, actor) returning id into ledger_id;
  insert into public.audit_logs(user_id, action_type, module, record_type, record_id, new_value, customer_id)
    values (actor, 'payment_recorded', 'payments', 'payments', result.id, to_jsonb(result) || jsonb_build_object('ledger_transaction_id', ledger_id), target_customer_id);
  return result;
end $$;

create function public.reverse_payment(target_payment_id uuid, reason text) returns public.ledger_transactions
language plpgsql security definer set search_path = ''
as $$
declare
  actor uuid := auth.uid(); payment public.payments; original_ledger public.ledger_transactions; result public.ledger_transactions; balance numeric(14,2);
begin
  if actor is null or not public.is_staff() then raise exception 'permission_denied' using errcode = '42501'; end if;
  if length(trim(reason)) < 3 then raise exception 'reversal_reason_required' using errcode = '22023'; end if;
  select * into payment from public.payments where id = target_payment_id for update;
  if not found then raise exception 'payment_not_found' using errcode = 'P0002'; end if;
  if not public.can_access_customer(payment.customer_id) then raise exception 'permission_denied' using errcode = '42501'; end if;
  if payment.reversed_at is not null then raise exception 'payment_already_reversed' using errcode = '23505'; end if;
  select * into strict original_ledger from public.ledger_transactions where reference_type = 'payment' and reference_id = payment.id and type = 'payment';

  perform pg_advisory_xact_lock(hashtextextended(payment.customer_id::text, 0));
  balance := public.customer_balance(payment.customer_id) + payment.amount;
  update public.payments set reversed_at = now(), reversed_by = actor where id = payment.id;
  insert into public.ledger_transactions(customer_id, type, amount, reference_id, reference_type, running_balance, created_by, reverses_transaction_id, note)
    values (payment.customer_id, 'payment_reversal', payment.amount, payment.id, 'payment_reversal', balance, actor, original_ledger.id, trim(reason)) returning * into result;
  insert into public.audit_logs(user_id, action_type, module, record_type, record_id, previous_value, new_value, reason, customer_id)
    values (actor, 'payment_reversed', 'payments', 'payments', payment.id, to_jsonb(payment), jsonb_build_object('reversal_ledger_transaction', to_jsonb(result)), trim(reason), payment.customer_id);
  return result;
end $$;

revoke all on function public.change_customer_price(uuid, uuid, numeric, text) from public, anon;
revoke all on function public.finalize_order(uuid) from public, anon;
revoke all on function public.record_payment(uuid, numeric, public.payment_method, text, text, text) from public, anon;
revoke all on function public.reverse_payment(uuid, text) from public, anon;
grant execute on function public.change_customer_price(uuid, uuid, numeric, text) to authenticated;
grant execute on function public.finalize_order(uuid) to authenticated;
grant execute on function public.record_payment(uuid, numeric, public.payment_method, text, text, text) to authenticated;
grant execute on function public.reverse_payment(uuid, text) to authenticated;

commit;
