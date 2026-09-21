-- ============================================================
-- 365 RAZONES PARA ELEGIRTE — Setup completo Supabase
-- Ejecuta TODO en SQL Editor
-- ============================================================

-- 1) Cartas
create table if not exists public.love_letters (
  id bigint generated always as identity primary key,
  sender_name text not null default 'Susan',
  message text not null,
  is_favorite boolean not null default false,
  is_read boolean not null default false,
  reply text,
  replied_at timestamptz,
  created_at timestamptz not null default now()
);

-- 2) Fotos
create table if not exists public.love_photos (
  id bigint generated always as identity primary key,
  caption text,
  image_url text not null,
  created_at timestamptz not null default now()
);

-- 3) "Te pienso" pings
create table if not exists public.love_pings (
  id bigint generated always as identity primary key,
  from_name text not null default 'Susan',
  note text,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

-- 4) RLS
alter table public.love_letters enable row level security;
alter table public.love_photos enable row level security;
alter table public.love_pings enable row level security;

revoke all on table public.love_letters from anon, authenticated;
revoke all on table public.love_photos from anon, authenticated;
revoke all on table public.love_pings from anon, authenticated;

grant insert on table public.love_letters to anon;
grant select, update on table public.love_letters to authenticated;

grant select on table public.love_photos to anon, authenticated;
grant insert, update, delete on table public.love_photos to authenticated;

grant insert on table public.love_pings to anon;
grant select, update on table public.love_pings to authenticated;

-- Políticas letters
drop policy if exists "Public can send love letters" on public.love_letters;
create policy "Public can send love letters"
on public.love_letters for insert to anon
with check (
  char_length(sender_name) between 1 and 80
  and char_length(message) between 3 and 2000
);

drop policy if exists "Owner can read love letters" on public.love_letters;
create policy "Owner can read love letters"
on public.love_letters for select to authenticated using (true);

drop policy if exists "Owner can update love letters" on public.love_letters;
create policy "Owner can update love letters"
on public.love_letters for update to authenticated using (true) with check (true);

-- Políticas photos
drop policy if exists "Anyone can view photos" on public.love_photos;
create policy "Anyone can view photos"
on public.love_photos for select to anon, authenticated using (true);

drop policy if exists "Owner can manage photos" on public.love_photos;
create policy "Owner can manage photos"
on public.love_photos for all to authenticated using (true) with check (true);

-- Políticas pings
drop policy if exists "Anyone can send ping" on public.love_pings;
create policy "Anyone can send ping"
on public.love_pings for insert to anon
with check (char_length(from_name) between 1 and 80);

drop policy if exists "Owner can read pings" on public.love_pings;
create policy "Owner can read pings"
on public.love_pings for select to authenticated using (true);

drop policy if exists "Owner can update pings" on public.love_pings;
create policy "Owner can update pings"
on public.love_pings for update to authenticated using (true) with check (true);

-- 5) Storage bucket para fotos (público de lectura)
insert into storage.buckets (id, name, public)
values ('love-photos', 'love-photos', true)
on conflict (id) do nothing;

drop policy if exists "Public read love photos" on storage.objects;
create policy "Public read love photos"
on storage.objects for select to anon, authenticated
using (bucket_id = 'love-photos');

drop policy if exists "Auth upload love photos" on storage.objects;
create policy "Auth upload love photos"
on storage.objects for insert to authenticated
with check (bucket_id = 'love-photos');

drop policy if exists "Auth update love photos" on storage.objects;
create policy "Auth update love photos"
on storage.objects for update to authenticated
using (bucket_id = 'love-photos');

drop policy if exists "Auth delete love photos" on storage.objects;
create policy "Auth delete love photos"
on storage.objects for delete to authenticated
using (bucket_id = 'love-photos');

-- ============================================================
-- CUENTAS (hazlo en Authentication → Users → Add user)
-- ============================================================
-- No se pueden crear correos @amor.com desde aquí.
-- Usa tus correos reales (Gmail, etc.) o desactiva
-- "Confirm email" en Auth → Providers → Email.
--
-- Sugerencia de contraseña (aniversario 27/07/2024):
--   27072024
-- o:  NuestroAmor2707
--
-- Crea DOS usuarios (tú y Susan) con esa misma contraseña
-- si quieres que ambos suban fotos.
