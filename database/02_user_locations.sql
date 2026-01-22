-- =====================================================
-- HAUS - Ubicaciones de Usuario
-- Ejecutar después de 01_auth_schema.sql
-- =====================================================

-- =====================================================
-- ENUM PARA PROPÓSITO DE UBICACIÓN
-- =====================================================

-- Propósito de la ubicación
DO $$ BEGIN
    CREATE TYPE location_purpose AS ENUM ('search', 'listing');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- =====================================================
-- TABLA DE UBICACIONES DE USUARIO
-- =====================================================

CREATE TABLE IF NOT EXISTS public.user_locations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  
  -- Relación con usuario
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Tipo de ubicación
  label TEXT DEFAULT 'work' CHECK (label IN ('home', 'work', 'university', 'other')),
  
  -- Propósito: búsqueda de roomies o publicación de vivienda
  purpose location_purpose DEFAULT 'search',
  
  -- Dirección
  address TEXT,
  city TEXT,
  neighborhood TEXT,
  
  -- Coordenadas geográficas (para futuro uso con mapas)
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  
  -- Indicador de ubicación principal para recomendaciones
  is_primary BOOLEAN DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  -- Restricción: solo una ubicación por tipo y propósito por usuario
  UNIQUE(user_id, label, purpose)
);

-- Índices para optimizar búsquedas
CREATE INDEX IF NOT EXISTS idx_user_locations_user_id ON public.user_locations(user_id);
CREATE INDEX IF NOT EXISTS idx_user_locations_city ON public.user_locations(city);
CREATE INDEX IF NOT EXISTS idx_user_locations_purpose ON public.user_locations(purpose);

-- Índice geoespacial para búsquedas por proximidad (usar cuando PostGIS esté habilitado)
-- CREATE INDEX IF NOT EXISTS idx_user_locations_geo ON public.user_locations USING GIST (ST_MakePoint(longitude, latitude));

-- Trigger para updated_at
DROP TRIGGER IF EXISTS on_location_updated ON public.user_locations;

CREATE TRIGGER on_location_updated
  BEFORE UPDATE ON public.user_locations
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- FUNCIÓN: Asegurar solo una ubicación primaria por propósito
-- =====================================================

CREATE OR REPLACE FUNCTION public.ensure_single_primary_location()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- Si se está marcando como primaria, desmarcar las demás del mismo propósito
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

DROP TRIGGER IF EXISTS on_location_primary_check ON public.user_locations;

CREATE TRIGGER on_location_primary_check
  BEFORE INSERT OR UPDATE ON public.user_locations
  FOR EACH ROW 
  WHEN (NEW.is_primary = true)
  EXECUTE FUNCTION public.ensure_single_primary_location();

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE public.user_locations IS 'Ubicaciones guardadas por los usuarios para búsqueda o publicación';
COMMENT ON COLUMN public.user_locations.label IS 'Tipo de ubicación: home, work, university, other';
COMMENT ON COLUMN public.user_locations.purpose IS 'Propósito: search (buscar roomies cerca) o listing (publicar vivienda)';
COMMENT ON COLUMN public.user_locations.is_primary IS 'Indica la ubicación principal para cálculos de proximidad';
