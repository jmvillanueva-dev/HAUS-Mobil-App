-- =====================================================
-- HAUS - Actualización de Chat para Matching
-- Ejecutar después de 08_matching.sql
-- =====================================================

-- 1. Hacer listing_id opcional en conversations
ALTER TABLE public.conversations 
ALTER COLUMN listing_id DROP NOT NULL;

-- 2. Eliminar la restricción unique anterior
ALTER TABLE public.conversations 
DROP CONSTRAINT IF EXISTS unique_conversation_per_listing;

-- 3. Añadir columna match_id para vincular con matches
ALTER TABLE public.conversations 
ADD COLUMN IF NOT EXISTS match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE;

-- 4. Nueva restricción unique: O es por listing O es por match
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_conversation_listing 
ON public.conversations(listing_id, user_id) 
WHERE listing_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_conversation_match 
ON public.conversations(match_id) 
WHERE match_id IS NOT NULL;

-- 5. Actualizar la función de creación de match para crear conversación
CREATE OR REPLACE FUNCTION public.check_and_create_match()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  other_like RECORD;
  new_match_id UUID;
  new_conversation_id UUID;
  match_score DECIMAL(5,2);
  ordered_user_a UUID;
  ordered_user_b UUID;
BEGIN
  -- Solo procesar likes (no skips)
  IF NEW.action != 'like' AND NEW.action != 'super_like' THEN
    RETURN NEW;
  END IF;
  
  -- Verificar si el otro usuario también dio like
  SELECT * INTO other_like 
  FROM public.user_interactions 
  WHERE user_id = NEW.target_user_id 
    AND target_user_id = NEW.user_id 
    AND action IN ('like', 'super_like');
  
  -- Si hay like mutuo, crear match
  IF other_like IS NOT NULL THEN
    -- Ordenar usuarios para evitar duplicados
    IF NEW.user_id < NEW.target_user_id THEN
      ordered_user_a := NEW.user_id;
      ordered_user_b := NEW.target_user_id;
    ELSE
      ordered_user_a := NEW.target_user_id;
      ordered_user_b := NEW.user_id;
    END IF;
    
    -- Verificar que no exista ya el match
    IF NOT EXISTS (
      SELECT 1 FROM public.matches 
      WHERE user_a = ordered_user_a AND user_b = ordered_user_b
    ) THEN
      -- Calcular score de compatibilidad
      match_score := public.calculate_match_score(ordered_user_a, ordered_user_b);
      
      -- Insertar match PRIMERO para obtener ID
      INSERT INTO public.matches (user_a, user_b, compatibility_score)
      VALUES (ordered_user_a, ordered_user_b, match_score)
      RETURNING id INTO new_match_id;
      
      -- Crear conversación asociada al match
      INSERT INTO public.conversations (user_id, host_id, match_id)
      VALUES (ordered_user_a, ordered_user_b, new_match_id)
      RETURNING id INTO new_conversation_id;
      
      -- Actualizar match con el ID de conversación
      UPDATE public.matches 
      SET conversation_id = new_conversation_id 
      WHERE id = new_match_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;
