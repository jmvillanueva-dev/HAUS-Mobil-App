-- 1. Tabla de Publicaciones
create table public.listings (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  user_id uuid references auth.users not null,
  title text not null,
  description text,
  price numeric not null,
  housing_type text,
  city text,
  neighborhood text,
  address text,
  latitude double precision,
  longitude double precision,
  amenities text[] default '{}', 
  image_urls text[] default '{}',
  is_active boolean default true
);

-- 2. Habilitar RLS (Seguridad)
alter table public.listings enable row level security;

-- Políticas:
-- Cualquiera puede ver listings activos
create policy "Public listings are viewable by everyone" 
on public.listings for select using (is_active = true);

-- Solo el dueño puede insertar
create policy "Users can insert their own listings" 
on public.listings for insert with check (auth.uid() = user_id);

-- Solo el dueño puede actualizar
create policy "Users can update their own listings" 
on public.listings for update using (auth.uid() = user_id);

-- Solo el dueño puede eliminar
create policy "Users can delete their own listings" 
on public.listings for delete using (auth.uid() = user_id);

-- 3. Crear Bucket para imágenes (si no existe)
insert into storage.buckets (id, name, public) values ('listings', 'listings', true);

-- Política de almacenamiento para imágenes
create policy "Give users access to own folder 1u753z_0" ON storage.objects FOR SELECT TO public USING (bucket_id = 'listings');
create policy "Give users access to own folder 1u753z_1" ON storage.objects FOR INSERT TO public WITH CHECK (bucket_id = 'listings' AND auth.uid() = owner);
create policy "Give users access to own folder 1u753z_2" ON storage.objects FOR UPDATE TO public USING (bucket_id = 'listings' AND auth.uid() = owner);
create policy "Give users access to own folder 1u753z_3" ON storage.objects FOR DELETE TO public USING (bucket_id = 'listings' AND auth.uid() = owner);