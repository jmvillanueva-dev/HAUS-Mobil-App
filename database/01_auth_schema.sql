-- 01_auth_schema.sql

-- =====================================================
-- RoomieMatch - Esquema de Autenticación y Perfiles
-- Ejecutar después de 00_init_extensions.sql
-- =====================================================

-- =====================================================
-- ENUMS PARA CONSISTENCIA
-- =====================================================

-- Tipo de rol del usuario
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('student', 'worker');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Estado de verificación de identidad
DO $$ BEGIN
    CREATE TYPE verification_status AS ENUM ('unverified', 'pending', 'verified', 'rejected');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- =====================================================
-- TABLA DE PERFILES (Extiende auth.users)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.profiles (
  -- ID vinculado a auth.users
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  
  -- Información personal
  first_name TEXT,
  last_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  bio TEXT,
  
  -- Rol y verificación
  role user_role DEFAULT 'worker',
  status verification_status DEFAULT 'unverified',
  university_or_company TEXT,
  verification_doc_url TEXT,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Índice para búsquedas por rol y estado
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_status ON public.profiles(status);

-- =====================================================
-- FUNCIÓN: Actualizar timestamp automáticamente
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$;

-- Trigger para updated_at en profiles
DROP TRIGGER IF EXISTS on_profile_updated ON public.profiles;

CREATE TRIGGER on_profile_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- FUNCIÓN TRIGGER: Crear perfil al registrarse
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, first_name, last_name, role)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    COALESCE(
      NULLIF(NEW.raw_user_meta_data->>'role', '')::user_role, 
      'worker'
    )
  );
  RETURN NEW;
EXCEPTION
  WHEN others THEN
    -- Log error pero no fallar el registro
    RAISE WARNING 'Error creating profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$;

-- Eliminar trigger existente si lo hay
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Crear trigger para nuevos usuarios
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE public.profiles IS 'Perfiles de usuario extendidos para RoomieMatch';
COMMENT ON COLUMN public.profiles.role IS 'Rol del usuario: student (estudiante) o worker (trabajador)';
COMMENT ON COLUMN public.profiles.status IS 'Estado de verificación: unverified, pending, verified, rejected';
COMMENT ON COLUMN public.profiles.verification_doc_url IS 'URL del documento subido para verificación de identidad';
