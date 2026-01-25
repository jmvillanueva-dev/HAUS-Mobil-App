-- =====================================================
-- HAUS - Funciones para Conexiones (Likes recibidos)
-- Ejecutar después de 14_update_matching_function_role.sql
-- =====================================================

-- =====================================================
-- FUNCIÓN: Obtener likes recibidos (Solicitudes)
-- Retorna usuarios que dieron like al usuario actual
-- y con los que NO hay match todavía
-- =====================================================

CREATE OR REPLACE FUNCTION public.get_incoming_likes(for_user_id UUID)
RETURNS TABLE (
  user_id UUID,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  compatibility_score DECIMAL(5,2),
  role TEXT,
  liked_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id as user_id,
    p.first_name,
    p.last_name,
    p.avatar_url,
    p.bio,
    public.calculate_match_score(for_user_id, p.id) as compatibility_score,
    p.role::text,
    ui.created_at as liked_at
  FROM public.user_interactions ui
  JOIN public.profiles p ON ui.user_id = p.id
  WHERE ui.target_user_id = for_user_id
    AND ui.action IN ('like', 'super_like')
    -- Excluir si ya existe match (ya están conectados)
    AND NOT EXISTS (
      SELECT 1 FROM public.matches m
      WHERE (m.user_a = for_user_id AND m.user_b = p.id)
         OR (m.user_a = p.id AND m.user_b = for_user_id)
    )
    -- Excluir si el usuario actual ya rechazó (skip) o dio like (sería match)
    AND NOT EXISTS (
      SELECT 1 FROM public.user_interactions my_ui
      WHERE my_ui.user_id = for_user_id
        AND my_ui.target_user_id = p.id
    )
  ORDER BY ui.created_at DESC;
END;
$$;

-- Comentario
COMMENT ON FUNCTION public.get_incoming_likes IS 'Obtiene usuarios que dieron like al usuario actual (solicitudes pendientes)';
