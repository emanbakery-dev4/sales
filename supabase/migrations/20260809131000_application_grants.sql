begin;

grant usage on schema public to authenticated;
grant select on all tables in schema public to authenticated;
grant usage, select on all sequences in schema public to authenticated;

grant insert, update on public.branches, public.roles, public.users,
  public.role_permissions, public.customers, public.customer_user_links,
  public.product_categories, public.products, public.drivers, public.deliveries,
  public.automation_settings, public.system_settings to authenticated;

grant insert, update, delete on public.carts, public.cart_items to authenticated;
grant update on public.notifications to authenticated;

-- Financial history is readable through RLS but writable only through the
-- audited security-definer functions defined in the preceding migration.
revoke insert, update, delete on public.customer_product_prices, public.orders,
  public.order_items, public.order_revisions, public.order_status_history,
  public.ledger_transactions, public.payments, public.audit_logs from authenticated;

revoke all on all tables in schema public from anon;

commit;
