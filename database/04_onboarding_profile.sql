-- =====================================================
-- HAUS - Migración: Onboarding Obligatorio
-- Ejecutar en Supabase SQL Editor
-- =====================================================

-- =====================================================
-- 1. NUEVO CAMPO: onboarding_completed
-- =====================================================

-- Agregar campo para verificar si el usuario completó el onboarding
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT false;

-- Índice para búsquedas rápidas por estado de onboarding
CREATE INDEX IF NOT EXISTS idx_profiles_onboarding_completed 
ON public.profiles(onboarding_completed);

-- Comentario de documentación
COMMENT ON COLUMN public.profiles.onboarding_completed 
IS 'Indica si el usuario completó el proceso de onboarding obligatorio';

-- =====================================================
-- 2. STORAGE BUCKET: avatars
-- =====================================================

-- Crear bucket para fotos de perfil (público para ver, restringido para modificar)
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 3. POLÍTICAS RLS PARA BUCKET avatars
-- =====================================================

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "Avatar images are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;

-- SELECT: Todos los usuarios autenticados pueden ver avatars
-- (Necesario para ver fotos de perfil de otros usuarios)
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'avatars');

-- INSERT: Solo el usuario puede subir su propio avatar
-- El path debe comenzar con el user_id del usuario
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- UPDATE: Solo el usuario puede actualizar su propio avatar
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' 
  AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'avatars' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- DELETE: Solo el usuario puede eliminar su propio avatar
CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- =====================================================
-- VERIFICACIÓN
-- =====================================================
-- Verificar que el campo se creó:
-- SELECT column_name, data_type, column_default
-- FROM information_schema.columns 
-- WHERE table_name = 'profiles' AND column_name = 'onboarding_completed';

-- Verificar bucket:
-- SELECT * FROM storage.buckets WHERE id = 'avatars';

-- Verificar políticas:
-- SELECT policyname FROM pg_policies 
-- WHERE tablename = 'objects' AND policyname LIKE '%avatar%';
