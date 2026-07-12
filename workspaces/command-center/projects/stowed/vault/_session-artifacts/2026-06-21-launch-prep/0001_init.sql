-- Stowed backend, initial migration
-- Nihilo Solutions LLC
--
-- Scope of this migration:
--   1. Multi-tenant core (organizations, profiles, memberships)
--   2. Warehouses with a join code for employee signup
--   3. Catalog (products, inventory) and customers with customer-specific pricing
--   4. Orders, order items, and the fulfillment pipeline
--   5. Financial tracking (invoices, payments)
--   6. Audit logging for pricing, role, and financial changes
--   7. Row Level Security on every table for tenant isolation and the three roles
--
-- Roles: owner, manager, employee.
--   Pricing and customer management are restricted to owner and manager.
--   Employees can run the order and fulfillment flow.
--   Warehouse-code signup creates a pending membership that an owner approves.
--
-- This migration is written for Supabase (it relies on auth.users and auth.uid()).
-- Apply it to a Supabase branch or staging project first, then reconcile against
-- your own schema.sql before promoting to production.

-- ----------------------------------------------------------------------------
-- 0. Extensions and helper schema
-- ----------------------------------------------------------------------------
create extension if not exists pgcrypto;

create schema if not exists app;

-- ----------------------------------------------------------------------------
-- 1. Enumerated types
-- ----------------------------------------------------------------------------
create type app.membership_role as enum ('owner', 'manager', 'employee');
create type app.membership_status as enum ('pending', 'active', 'suspended');
create type app.order_status as enum (
  'draft', 'submitted', 'picking', 'packed', 'fulfilled', 'shipped', 'delivered', 'canceled'
);
create type app.invoice_status as enum ('draft', 'open', 'paid', 'void');
create type app.payment_method as enum ('cash', 'card', 'transfer', 'other');

-- ----------------------------------------------------------------------------
-- 2. Core tenancy
-- ----------------------------------------------------------------------------
create table public.organizations (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  created_by  uuid references auth.users (id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text,
  email       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table public.warehouses (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null references public.organizations (id) on delete cascade,
  name             text not null,
  join_code        text unique,
  address          text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create table public.memberships (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null references public.organizations (id) on delete cascade,
  user_id          uuid not null references auth.users (id) on delete cascade,
  warehouse_id     uuid references public.warehouses (id) on delete set null,
  role             app.membership_role not null default 'employee',
  status           app.membership_status not null default 'pending',
  invited_by       uuid references auth.users (id),
  approved_by      uuid references auth.users (id),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (organization_id, user_id)
);

create index memberships_user_idx on public.memberships (user_id);
create index memberships_org_idx on public.memberships (organization_id);

-- ----------------------------------------------------------------------------
-- 3. Catalog and inventory
-- ----------------------------------------------------------------------------
create table public.products (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null references public.organizations (id) on delete cascade,
  sku              text not null,
  name             text not null,
  description      text,
  unit             text not null default 'each',
  base_price       numeric(12,2) not null default 0,
  cost             numeric(12,2) not null default 0,
  is_active        boolean not null default true,
  created_by       uuid references auth.users (id),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (organization_id, sku)
);

create index products_org_idx on public.products (organization_id);

create table public.inventory (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null references public.organizations (id) on delete cascade,
  product_id       uuid not null references public.products (id) on delete cascade,
  warehouse_id     uuid not null references public.warehouses (id) on delete cascade,
  quantity         numeric(12,2) not null default 0,
  reorder_point    numeric(12,2) not null default 0,
  updated_at       timestamptz not null default now(),
  unique (product_id, warehouse_id)
);

create index inventory_org_idx on public.inventory (organization_id);

-- ----------------------------------------------------------------------------
-- 4. Customers and customer-specific pricing
-- ----------------------------------------------------------------------------
create table public.customers (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null references public.organizations (id) on delete cascade,
  name             text not null,
  contact_name     text,
  email            text,
  phone            text,
  billing_address  text,
  is_active        boolean not null default true,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index customers_org_idx on public.customers (organization_id);

create table public.customer_prices (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null references public.organizations (id) on delete cascade,
  customer_id      uuid not null references public.customers (id) on delete cascade,
  product_id       uuid not null references public.products (id) on delete cascade,
  price            numeric(12,2) not null,
  created_by       uuid references auth.users (id),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (customer_id, product_id)
);

create index customer_prices_org_idx on public.customer_prices (organization_id);

-- ----------------------------------------------------------------------------
-- 5. Orders and fulfillment
-- ----------------------------------------------------------------------------
create table public.orders (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null references public.organizations (id) on delete cascade,
  customer_id      uuid not null references public.customers (id),
  warehouse_id     uuid references public.warehouses (id),
  order_number     text,
  status           app.order_status not null default 'draft',
  notes            text,
  subtotal         numeric(12,2) not null default 0,
  created_by       uuid references auth.users (id),
  submitted_at     timestamptz,
  fulfilled_at     timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (organization_id, order_number)
);

create index orders_org_idx on public.orders (organization_id);
create index orders_customer_idx on public.orders (customer_id);

create table public.order_items (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null references public.organizations (id) on delete cascade,
  order_id         uuid not null references public.orders (id) on delete cascade,
  product_id       uuid not null references public.products (id),
  quantity         numeric(12,2) not null check (quantity > 0),
  unit_price       numeric(12,2) not null,
  line_total       numeric(12,2) generated always as (quantity * unit_price) stored,
  created_at       timestamptz not null default now()
);

create index order_items_order_idx on public.order_items (order_id);
create index order_items_org_idx on public.order_items (organization_id);

-- ----------------------------------------------------------------------------
-- 6. Financial tracking
-- ----------------------------------------------------------------------------
create table public.invoices (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null references public.organizations (id) on delete cascade,
  order_id         uuid references public.orders (id) on delete set null,
  customer_id      uuid not null references public.customers (id),
  invoice_number   text,
  status           app.invoice_status not null default 'draft',
  amount_due       numeric(12,2) not null default 0,
  issued_at        timestamptz,
  due_at           timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (organization_id, invoice_number)
);

create index invoices_org_idx on public.invoices (organization_id);

create table public.payments (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null references public.organizations (id) on delete cascade,
  invoice_id       uuid not null references public.invoices (id) on delete cascade,
  amount           numeric(12,2) not null,
  method           app.payment_method not null default 'other',
  received_at      timestamptz not null default now(),
  created_by       uuid references auth.users (id),
  created_at       timestamptz not null default now()
);

create index payments_org_idx on public.payments (organization_id);

-- ----------------------------------------------------------------------------
-- 7. Audit log
-- ----------------------------------------------------------------------------
create table public.audit_log (
  id               bigint generated always as identity primary key,
  organization_id  uuid,
  actor_id         uuid,
  action           text not null,
  entity_type      text not null,
  entity_id        text,
  old_data         jsonb,
  new_data         jsonb,
  created_at       timestamptz not null default now()
);

create index audit_log_org_idx on public.audit_log (organization_id);

-- ----------------------------------------------------------------------------
-- 8. Helper functions (security definer so they can read membership state
--    without tripping the row level security policies that depend on them)
-- ----------------------------------------------------------------------------
create or replace function app.is_member(p_org uuid)
returns boolean language sql stable security definer set search_path = public, app as $$
  select exists (
    select 1 from public.memberships m
    where m.organization_id = p_org and m.user_id = auth.uid() and m.status = 'active'
  );
$$;

create or replace function app.has_role(p_org uuid, p_roles app.membership_role[])
returns boolean language sql stable security definer set search_path = public, app as $$
  select exists (
    select 1 from public.memberships m
    where m.organization_id = p_org and m.user_id = auth.uid()
      and m.status = 'active' and m.role = any (p_roles)
  );
$$;

create or replace function app.is_manager_or_owner(p_org uuid)
returns boolean language sql stable security definer set search_path = public, app as $$
  select app.has_role(p_org, array['owner', 'manager']::app.membership_role[]);
$$;

create or replace function app.is_owner(p_org uuid)
returns boolean language sql stable security definer set search_path = public, app as $$
  select app.has_role(p_org, array['owner']::app.membership_role[]);
$$;

create or replace function app.shares_org(p_user uuid)
returns boolean language sql stable security definer set search_path = public, app as $$
  select exists (
    select 1
    from public.memberships me
    join public.memberships them on them.organization_id = me.organization_id
    where me.user_id = auth.uid() and me.status = 'active'
      and them.user_id = p_user and them.status = 'active'
  );
$$;

create or replace function app.resolve_price(p_customer uuid, p_product uuid)
returns numeric language sql stable security definer set search_path = public, app as $$
  select coalesce(
    (select cp.price from public.customer_prices cp
       where cp.customer_id = p_customer and cp.product_id = p_product),
    (select p.base_price from public.products p where p.id = p_product),
    0
  );
$$;

-- ----------------------------------------------------------------------------
-- 9. Trigger functions
-- ----------------------------------------------------------------------------
create or replace function app.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create or replace function app.write_audit()
returns trigger language plpgsql security definer set search_path = public, app as $$
declare
  v_old jsonb := case when tg_op in ('UPDATE', 'DELETE') then to_jsonb(old) else null end;
  v_new jsonb := case when tg_op in ('INSERT', 'UPDATE') then to_jsonb(new) else null end;
  v_org uuid := coalesce((v_new->>'organization_id')::uuid, (v_old->>'organization_id')::uuid);
  v_entity text := coalesce(v_new->>'id', v_old->>'id');
begin
  insert into public.audit_log (organization_id, actor_id, action, entity_type, entity_id, old_data, new_data)
  values (v_org, auth.uid(), lower(tg_table_name) || '.' || lower(tg_op), tg_table_name, v_entity, v_old, v_new);
  return coalesce(new, old);
end;
$$;

create or replace function app.set_order_item_price()
returns trigger language plpgsql security definer set search_path = public, app as $$
declare
  v_customer uuid;
begin
  select o.customer_id, o.organization_id
    into v_customer, new.organization_id
    from public.orders o where o.id = new.order_id;
  if new.unit_price is null then
    new.unit_price := app.resolve_price(v_customer, new.product_id);
  end if;
  return new;
end;
$$;

create or replace function app.recompute_order_total()
returns trigger language plpgsql security definer set search_path = public, app as $$
declare
  v_order uuid := coalesce(new.order_id, old.order_id);
begin
  update public.orders o
    set subtotal = coalesce((select sum(oi.line_total) from public.order_items oi where oi.order_id = v_order), 0),
        updated_at = now()
    where o.id = v_order;
  return coalesce(new, old);
end;
$$;

create or replace function app.set_order_number()
returns trigger language plpgsql security definer set search_path = public, app as $$
begin
  if new.order_number is null then
    new.order_number := 'SO-' || lpad(
      (coalesce((select count(*) from public.orders o where o.organization_id = new.organization_id), 0) + 1)::text,
      5, '0');
  end if;
  return new;
end;
$$;

-- ----------------------------------------------------------------------------
-- 10. Onboarding RPCs (called from the app)
-- ----------------------------------------------------------------------------

-- Create an organization. The caller becomes its owner, and a default
-- warehouse with a join code is created.
create or replace function app.create_organization(p_name text, p_warehouse_name text default 'Main Warehouse')
returns public.organizations language plpgsql security definer set search_path = public, app as $$
declare
  v_org public.organizations;
  v_code text;
begin
  if auth.uid() is null then
    raise exception 'must be authenticated';
  end if;
  insert into public.organizations (name, created_by) values (p_name, auth.uid()) returning * into v_org;
  insert into public.memberships (organization_id, user_id, role, status, approved_by)
    values (v_org.id, auth.uid(), 'owner', 'active', auth.uid());
  v_code := upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 8));
  insert into public.warehouses (organization_id, name, join_code)
    values (v_org.id, p_warehouse_name, v_code);
  return v_org;
end;
$$;

-- Request to join an organization with a warehouse join code. Creates a
-- pending employee membership that an owner must approve.
create or replace function app.request_to_join(p_join_code text)
returns public.memberships language plpgsql security definer set search_path = public, app as $$
declare
  v_wh public.warehouses;
  v_m public.memberships;
begin
  if auth.uid() is null then
    raise exception 'must be authenticated';
  end if;
  select * into v_wh from public.warehouses where join_code = upper(p_join_code);
  if not found then
    raise exception 'invalid join code';
  end if;
  insert into public.memberships (organization_id, user_id, warehouse_id, role, status)
    values (v_wh.organization_id, auth.uid(), v_wh.id, 'employee', 'pending')
    on conflict (organization_id, user_id)
      do update set warehouse_id = excluded.warehouse_id, updated_at = now()
    returning * into v_m;
  return v_m;
end;
$$;

-- Owner approves a pending member.
create or replace function app.approve_member(p_membership uuid)
returns public.memberships language plpgsql security definer set search_path = public, app as $$
declare
  v_m public.memberships;
begin
  select * into v_m from public.memberships where id = p_membership;
  if not found then
    raise exception 'membership not found';
  end if;
  if not app.is_owner(v_m.organization_id) then
    raise exception 'only an owner can approve members';
  end if;
  update public.memberships
    set status = 'active', approved_by = auth.uid(), updated_at = now()
    where id = p_membership returning * into v_m;
  return v_m;
end;
$$;

-- Owner changes a member's role.
create or replace function app.set_member_role(p_membership uuid, p_role app.membership_role)
returns public.memberships language plpgsql security definer set search_path = public, app as $$
declare
  v_m public.memberships;
begin
  select * into v_m from public.memberships where id = p_membership;
  if not found then
    raise exception 'membership not found';
  end if;
  if not app.is_owner(v_m.organization_id) then
    raise exception 'only an owner can change roles';
  end if;
  update public.memberships
    set role = p_role, updated_at = now()
    where id = p_membership returning * into v_m;
  return v_m;
end;
$$;

-- ----------------------------------------------------------------------------
-- 11. Triggers
-- ----------------------------------------------------------------------------
create trigger trg_org_touch before update on public.organizations
  for each row execute function app.touch_updated_at();
create trigger trg_profile_touch before update on public.profiles
  for each row execute function app.touch_updated_at();
create trigger trg_warehouse_touch before update on public.warehouses
  for each row execute function app.touch_updated_at();
create trigger trg_membership_touch before update on public.memberships
  for each row execute function app.touch_updated_at();
create trigger trg_product_touch before update on public.products
  for each row execute function app.touch_updated_at();
create trigger trg_customer_touch before update on public.customers
  for each row execute function app.touch_updated_at();
create trigger trg_customer_price_touch before update on public.customer_prices
  for each row execute function app.touch_updated_at();
create trigger trg_invoice_touch before update on public.invoices
  for each row execute function app.touch_updated_at();

-- Order number and item pricing
create trigger trg_order_number before insert on public.orders
  for each row execute function app.set_order_number();
create trigger trg_order_item_price before insert on public.order_items
  for each row execute function app.set_order_item_price();
create trigger trg_order_total after insert or update or delete on public.order_items
  for each row execute function app.recompute_order_total();

-- Audit: pricing, role, and financial changes
create trigger trg_audit_customer_prices after insert or update or delete on public.customer_prices
  for each row execute function app.write_audit();
create trigger trg_audit_product_price after update on public.products
  for each row when (old.base_price is distinct from new.base_price or old.cost is distinct from new.cost)
  execute function app.write_audit();
create trigger trg_audit_membership after update on public.memberships
  for each row when (old.role is distinct from new.role or old.status is distinct from new.status)
  execute function app.write_audit();
create trigger trg_audit_payment after insert on public.payments
  for each row execute function app.write_audit();
create trigger trg_audit_invoice after insert or update on public.invoices
  for each row execute function app.write_audit();

-- ----------------------------------------------------------------------------
-- 12. Grants (Row Level Security still filters every row)
-- ----------------------------------------------------------------------------
grant usage on schema app to authenticated;
grant execute on all functions in schema app to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;

-- ----------------------------------------------------------------------------
-- 13. Row Level Security
-- ----------------------------------------------------------------------------
alter table public.organizations enable row level security;
alter table public.profiles enable row level security;
alter table public.warehouses enable row level security;
alter table public.memberships enable row level security;
alter table public.products enable row level security;
alter table public.inventory enable row level security;
alter table public.customers enable row level security;
alter table public.customer_prices enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.invoices enable row level security;
alter table public.payments enable row level security;
alter table public.audit_log enable row level security;

-- organizations
create policy org_select on public.organizations
  for select to authenticated using (app.is_member(id));
create policy org_update on public.organizations
  for update to authenticated using (app.is_owner(id)) with check (app.is_owner(id));
create policy org_delete on public.organizations
  for delete to authenticated using (app.is_owner(id));

-- profiles
create policy profile_select on public.profiles
  for select to authenticated using (id = auth.uid() or app.shares_org(id));
create policy profile_insert on public.profiles
  for insert to authenticated with check (id = auth.uid());
create policy profile_update on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- memberships
create policy membership_select on public.memberships
  for select to authenticated using (user_id = auth.uid() or app.is_manager_or_owner(organization_id));
create policy membership_insert on public.memberships
  for insert to authenticated with check (app.is_manager_or_owner(organization_id));
create policy membership_update on public.memberships
  for update to authenticated using (app.is_owner(organization_id)) with check (app.is_owner(organization_id));
create policy membership_delete on public.memberships
  for delete to authenticated using (app.is_owner(organization_id));

-- warehouses
create policy warehouse_select on public.warehouses
  for select to authenticated using (app.is_member(organization_id));
create policy warehouse_write on public.warehouses
  for all to authenticated
  using (app.is_manager_or_owner(organization_id))
  with check (app.is_manager_or_owner(organization_id));

-- products
create policy product_select on public.products
  for select to authenticated using (app.is_member(organization_id));
create policy product_write on public.products
  for all to authenticated
  using (app.is_manager_or_owner(organization_id))
  with check (app.is_manager_or_owner(organization_id));

-- inventory (members read and adjust; only manager or owner can delete)
create policy inventory_select on public.inventory
  for select to authenticated using (app.is_member(organization_id));
create policy inventory_insert on public.inventory
  for insert to authenticated with check (app.is_member(organization_id));
create policy inventory_update on public.inventory
  for update to authenticated using (app.is_member(organization_id)) with check (app.is_member(organization_id));
create policy inventory_delete on public.inventory
  for delete to authenticated using (app.is_manager_or_owner(organization_id));

-- customers (management restricted to manager or owner)
create policy customer_select on public.customers
  for select to authenticated using (app.is_member(organization_id));
create policy customer_write on public.customers
  for all to authenticated
  using (app.is_manager_or_owner(organization_id))
  with check (app.is_manager_or_owner(organization_id));

-- customer-specific pricing (restricted to manager or owner)
create policy customer_price_select on public.customer_prices
  for select to authenticated using (app.is_member(organization_id));
create policy customer_price_write on public.customer_prices
  for all to authenticated
  using (app.is_manager_or_owner(organization_id))
  with check (app.is_manager_or_owner(organization_id));

-- orders (any member can run the fulfillment flow)
create policy order_select on public.orders
  for select to authenticated using (app.is_member(organization_id));
create policy order_insert on public.orders
  for insert to authenticated with check (app.is_member(organization_id));
create policy order_update on public.orders
  for update to authenticated using (app.is_member(organization_id)) with check (app.is_member(organization_id));
create policy order_delete on public.orders
  for delete to authenticated using (app.is_manager_or_owner(organization_id));

-- order items
create policy order_item_select on public.order_items
  for select to authenticated using (app.is_member(organization_id));
create policy order_item_insert on public.order_items
  for insert to authenticated with check (app.is_member(organization_id));
create policy order_item_update on public.order_items
  for update to authenticated using (app.is_member(organization_id)) with check (app.is_member(organization_id));
create policy order_item_delete on public.order_items
  for delete to authenticated using (app.is_member(organization_id));

-- invoices (financial, restricted to manager or owner)
create policy invoice_select on public.invoices
  for select to authenticated using (app.is_member(organization_id));
create policy invoice_write on public.invoices
  for all to authenticated
  using (app.is_manager_or_owner(organization_id))
  with check (app.is_manager_or_owner(organization_id));

-- payments (insert by manager or owner; only owner can amend)
create policy payment_select on public.payments
  for select to authenticated using (app.is_member(organization_id));
create policy payment_insert on public.payments
  for insert to authenticated with check (app.is_manager_or_owner(organization_id));
create policy payment_update on public.payments
  for update to authenticated using (app.is_owner(organization_id)) with check (app.is_owner(organization_id));
create policy payment_delete on public.payments
  for delete to authenticated using (app.is_owner(organization_id));

-- audit log (read only for manager or owner; writes happen through the
-- security-definer trigger, never directly from a client)
create policy audit_select on public.audit_log
  for select to authenticated using (app.is_manager_or_owner(organization_id));
