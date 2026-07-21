-- ============================================================================
-- Travelfy Tours — Preparar la base para el PANEL ADMIN
-- Agrega columnas para gestión + utilidad, y políticas para que SOLO
-- usuarios autenticados (tú) puedan leer/editar reservas.
-- Ejecutar en Supabase SQL Editor. Seguro de re-ejecutar.
-- ============================================================================

-- 1) Columnas de gestión en reservations
alter table public.reservations add column if not exists sale_price   numeric(10,2);  -- lo que cobras al cliente
alter table public.reservations add column if not exists cost_price   numeric(10,2);  -- lo que pagas al proveedor
alter table public.reservations add column if not exists currency     text default 'USD';
alter table public.reservations add column if not exists provider     text;           -- proveedor asignado
alter table public.reservations add column if not exists ref_code     text;           -- folio interno
alter table public.reservations add column if not exists updated_at    timestamptz default now();

-- Ampliar los estatus posibles (nueva | contactado | confirmada | pagada | cancelada)
-- (status ya existe como text; no requiere cambio de tipo)

-- 2) Trigger para mantener updated_at
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

drop trigger if exists trg_reservations_touch on public.reservations;
create trigger trg_reservations_touch
  before update on public.reservations
  for each row execute function public.touch_updated_at();

-- 3) POLÍTICAS RLS: solo usuarios autenticados leen/editan reservas.
--    El público SIGUE pudiendo insertar (el formulario de la web), pero NO leer.
drop policy if exists "reservations_auth_read"   on public.reservations;
create policy "reservations_auth_read"
  on public.reservations for select
  to authenticated
  using (true);

drop policy if exists "reservations_auth_update" on public.reservations;
create policy "reservations_auth_update"
  on public.reservations for update
  to authenticated
  using (true) with check (true);

drop policy if exists "reservations_auth_insert" on public.reservations;
create policy "reservations_auth_insert"
  on public.reservations for insert
  to authenticated
  with check (true);

-- (La política pública de INSERT del formulario ya existe: reservations_public_insert)

-- 4) Índices para que los filtros del panel sean rápidos
create index if not exists idx_reservations_status  on public.reservations(status);
create index if not exists idx_reservations_date     on public.reservations(tour_date);
create index if not exists idx_reservations_created  on public.reservations(created_at desc);

-- ============================================================================
-- IMPORTANTE — crea tu usuario admin así (una sola vez):
--   Supabase Dashboard → Authentication → Users → Add user →
--   pon tu email y una contraseña fuerte. Con eso inicias sesión en el panel.
--   NO se necesita "sign up" abierto; créalo tú a mano.
-- ============================================================================
