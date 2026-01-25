-- =====================================================
-- HAUS - Backfill de Conversaciones para Matches
-- Crea conversaciones para matches existentes que no tienen una
-- =====================================================

DO $$
DECLARE
  match_record RECORD;
  new_conversation_id UUID;
BEGIN
  -- Iterar sobre matches activos sin conversation_id
  FOR match_record IN 
    SELECT * FROM public.matches 
    WHERE conversation_id IS NULL
  LOOP
    -- Verificar si ya existe una conversación para este par de usuarios (por si acaso)
    -- Aunque la lógica de match usa user_a y user_b ordenados, la conversación usa user_id y host_id
    -- Intentamos buscar una conversación existente vinculada a este match_id (que no debería existir si conversation_id es null, pero por seguridad)
    
    -- Crear nueva conversación
    INSERT INTO public.conversations (user_id, host_id, match_id)
    VALUES (match_record.user_a, match_record.user_b, match_record.id)
    RETURNING id INTO new_conversation_id;
    
    -- Actualizar el match
    UPDATE public.matches
    SET conversation_id = new_conversation_id
    WHERE id = match_record.id;
    
    RAISE NOTICE 'Conversación creada % para match %', new_conversation_id, match_record.id;
  END LOOP;
END $$;
