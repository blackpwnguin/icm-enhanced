-- Stowed seed data: Northbeam Coffee Co
-- For LOCAL development (supabase db reset runs this automatically).
-- It inserts three demo auth users so the foreign keys resolve. On a hosted
-- project, create users through Supabase Auth instead and swap the UUIDs below.
--
-- Demo logins (local only): owner@northbeam.test / manager@northbeam.test /
-- employee@northbeam.test, all with password Password123!

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data
) values
  ('00000000-0000-0000-0000-000000000000', '11111111-1111-1111-1111-111111111111',
   'authenticated', 'authenticated', 'owner@northbeam.test', crypt('Password123!', gen_salt('bf')),
   now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}'),
  ('00000000-0000-0000-0000-000000000000', '22222222-2222-2222-2222-222222222222',
   'authenticated', 'authenticated', 'manager@northbeam.test', crypt('Password123!', gen_salt('bf')),
   now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}'),
  ('00000000-0000-0000-0000-000000000000', '33333333-3333-3333-3333-333333333333',
   'authenticated', 'authenticated', 'employee@northbeam.test', crypt('Password123!', gen_salt('bf')),
   now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}')
on conflict (id) do nothing;

do $$
declare
  v_owner    uuid := '11111111-1111-1111-1111-111111111111';
  v_manager  uuid := '22222222-2222-2222-2222-222222222222';
  v_employee uuid := '33333333-3333-3333-3333-333333333333';
  v_org uuid;
  v_wh  uuid;
  v_house uuid;
  v_espresso uuid;
  v_decaf uuid;
  v_cafe uuid;
  v_bistro uuid;
  v_order uuid;
begin
  insert into public.profiles (id, full_name, email) values
    (v_owner,    'Sam Owner',    'owner@northbeam.test'),
    (v_manager,  'Mia Manager',  'manager@northbeam.test'),
    (v_employee, 'Eli Employee', 'employee@northbeam.test')
  on conflict (id) do nothing;

  insert into public.organizations (name, created_by)
    values ('Northbeam Coffee Co', v_owner) returning id into v_org;

  insert into public.warehouses (organization_id, name, join_code)
    values (v_org, 'Roastery', 'NORTH123') returning id into v_wh;

  insert into public.memberships (organization_id, user_id, role, status, approved_by) values
    (v_org, v_owner,   'owner',   'active', v_owner),
    (v_org, v_manager, 'manager', 'active', v_owner);
  insert into public.memberships (organization_id, user_id, warehouse_id, role, status, approved_by)
    values (v_org, v_employee, v_wh, 'employee', 'active', v_owner);

  insert into public.products (organization_id, sku, name, unit, base_price, cost, created_by)
    values (v_org, 'HB-12', 'House Blend 12oz', 'bag', 14.00, 6.50, v_owner) returning id into v_house;
  insert into public.products (organization_id, sku, name, unit, base_price, cost, created_by)
    values (v_org, 'ESP-12', 'Espresso Roast 12oz', 'bag', 16.00, 7.00, v_owner) returning id into v_espresso;
  insert into public.products (organization_id, sku, name, unit, base_price, cost, created_by)
    values (v_org, 'DEC-12', 'Decaf 12oz', 'bag', 15.00, 6.80, v_owner) returning id into v_decaf;

  insert into public.inventory (organization_id, product_id, warehouse_id, quantity, reorder_point) values
    (v_org, v_house,    v_wh, 120, 40),
    (v_org, v_espresso, v_wh, 80,  30),
    (v_org, v_decaf,    v_wh, 45,  20);

  insert into public.customers (organization_id, name, contact_name, email)
    values (v_org, 'Lighthouse Cafe', 'Dana', 'orders@lighthouse.test') returning id into v_cafe;
  insert into public.customers (organization_id, name, contact_name, email)
    values (v_org, 'Corner Bistro', 'Reed', 'buy@cornerbistro.test') returning id into v_bistro;

  -- Lighthouse Cafe has contract pricing on two products
  insert into public.customer_prices (organization_id, customer_id, product_id, price, created_by) values
    (v_org, v_cafe, v_house,    12.50, v_owner),
    (v_org, v_cafe, v_espresso, 14.50, v_owner);

  -- A sample order for Lighthouse. Unit prices resolve from the contract
  -- automatically, the order number is generated, and the subtotal is computed.
  insert into public.orders (organization_id, customer_id, warehouse_id, status, created_by)
    values (v_org, v_cafe, v_wh, 'submitted', v_employee) returning id into v_order;
  insert into public.order_items (order_id, product_id, quantity) values
    (v_order, v_house,    10),
    (v_order, v_espresso, 6);
end $$;
