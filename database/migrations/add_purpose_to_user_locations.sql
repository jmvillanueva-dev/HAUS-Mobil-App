-- =====================================================
-- HAUS - Migración: Añadir campo purpose a user_locations
-- Ejecutar en Supabase SQL Editor si la tabla ya existe
-- =====================================================

-- 1. Crear nuevo ENUM location_purpose
DO $$ BEGIN
    CREATE TYPE location_purpose AS ENUM ('search', 'listing');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Añadir columna purpose
ALTER TABLE public.user_locations 
ADD COLUMN IF NOT EXISTS purpose location_purpose DEFAULT 'search';

-- 3. Crear índice para purpose
CREATE INDEX IF NOT EXISTS idx_user_locations_purpose 
ON public.user_locations(purpose);

-- 4. Actualizar constraint UNIQUE (requiere eliminar y recrear)
-- Primero, verificar si existe el constraint antiguo
DO $$
BEGIN
    -- Intentar eliminar constraint antiguo si existe
    ALTER TABLE public.user_locations 
    DROP CONSTRAINT IF EXISTS user_locations_user_id_label_key;
EXCEPTION
    WHEN undefined_object THEN null;
END $$;

-- 5. Crear nuevo constraint con purpose incluido
ALTER TABLE public.user_locations 
ADD CONSTRAINT user_locations_user_id_label_purpose_key 
UNIQUE (user_id, label, purpose);

-- 6. Actualizar función de primary location para considerar purpose
CREATE OR REPLACE FUNCTION public.ensure_single_primary_location()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.is_primary = true THEN
    UPDATE public.user_locations 
    SET is_primary = false 
    WHERE user_id = NEW.user_id 
      AND id != NEW.id 
      AND purpose = NEW.purpose
      AND is_primary = true;
  END IF;
  RETURN NEW;
END;
$$;

-- 7. Actualizar comentario
COMMENT ON COLUMN public.user_locations.purpose 
IS 'Propósito: search (buscar roomies cerca) o listing (publicar vivienda)';

-- =====================================================
-- VERIFICACIÓN
-- =====================================================
-- SELECT column_name, data_type, udt_name 
-- FROM information_schema.columns 
-- WHERE table_name = 'user_locations' AND column_name = 'purpose';
