-- ============================================================================
-- Travelfy Tours — Esquema Supabase
-- Ejecuta en:  Supabase → SQL Editor → New query → Run
-- ============================================================================

-- 1) TABLA: tours (catálogo editable desde Table Editor)
create table if not exists public.tours (
  id          uuid primary key default gen_random_uuid(),
  name        text    not null,
  description text    not null,
  category    text    not null default 'cancun',  -- cancun | isla | riviera
  price       integer,                             -- precio en USD (null si "consultar")
  image_url   text,                                -- ruta o URL de la foto
  icon        text    default 'aventura',
  badge       text,                                -- 'Más vendido', 'Popular', 'Fiesta', etc.
  sort_order  integer default 0,
  active      boolean default true,
  created_at  timestamptz default now()
);

-- 2) TABLA: reservations (solicitudes del formulario)
create table if not exists public.reservations (
  id         uuid primary key default gen_random_uuid(),
  tour       text not null,
  name       text not null,
  email      text not null,
  phone      text,
  tour_date  date,
  people     integer default 1,
  notes      text,
  status     text default 'nueva',
  created_at timestamptz default now()
);

-- 3) SEGURIDAD (RLS)
alter table public.tours        enable row level security;
alter table public.reservations enable row level security;

drop policy if exists "tours_public_read" on public.tours;
create policy "tours_public_read" on public.tours for select to anon, authenticated using (active = true);

drop policy if exists "reservations_public_insert" on public.reservations;
create policy "reservations_public_insert" on public.reservations for insert to anon, authenticated with check (true);

-- 4) DATOS INICIALES — 17 tours
insert into public.tours (name, description, category, badge, sort_order) values
  -- CANCÚN
  ('Coco Bongo',                    'El show nocturno más famoso de Cancún: acrobacias, música y fiesta.',      'cancun', 'Fiesta',     1),
  ('Mandala',                       'Club nocturno icónico en la zona hotelera con la mejor música y VIP.',     'cancun', null,         2),
  ('Catamarán Cancún–Isla',         'Navega en catamarán hacia Isla Mujeres con barra libre, snorkel y playa.','cancun', 'Popular',    3),
  ('Paseo en Lancha Cancún',        'Recorre la laguna Nichupté y el mar Caribe a bordo de una lancha rápida.','cancun', null,         4),
  ('Barco Pirata',                  'Cena y espectáculo a bordo del galeón Jolly Roger con show pirata.',      'cancun', null,         5),
  ('Columbus – Cena Romántica',     'Cena gourmet al atardecer navegando frente a la zona hotelera.',          'cancun', null,         6),
  ('Ice Bar',                       'Experiencia única: bar a –15°C con esculturas de hielo y bebidas.',       'cancun', null,         7),
  -- ISLA MUJERES
  ('Isla Mujeres Tour',             'Día completo: Playa Norte, Punta Sur, snorkel y tiempo libre.',           'isla',   'Más vendido',8),
  ('Garrafón',                      'Parque natural con snorkel, tirolesa, kayak y vistas panorámicas.',       'isla',   null,         9),
  ('Beach Club Isla Mujeres',       'Los mejores beach clubs con barra libre y playa privada.',                'isla',   null,         10),
  ('Lancha Transparente Isla',      'Paseo en lancha con fondo de cristal para ver arrecifes.',                'isla',   null,         11),
  ('Aqua Nick',                     'Parque acuático con atracciones temáticas Nickelodeon.',                   'isla',   null,         12),
  -- RIVIERA MAYA
  ('Chichén Itzá – Compartido',     'Excursión grupal a Chichén Itzá con guía certificado y cenote.',         'riviera','Más vendido',13),
  ('Chichén Itzá – Privado',        'Tour privado exclusivo con horario flexible y paradas personalizadas.',   'riviera',null,         14),
  ('Tulum 4×1',                     'Ruinas de Tulum, cenote, Playa del Carmen y Quinta Avenida.',             'riviera','Popular',    15),
  ('Tulum Privado + Cenote + Ruinas','Tour privado: ruinas de Tulum, cenote exclusivo y playa.',               'riviera',null,         16),
  ('Nado con Tortugas – Akumal',    'Snorkel junto a tortugas marinas en la bahía de Akumal.',                 'riviera',null,         17)
on conflict do nothing;

create index if not exists tours_cat_sort_idx on public.tours (category, sort_order) where active;
