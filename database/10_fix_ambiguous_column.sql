-- =====================================================
-- HAUS - Corrección de Ambigüedad de Columnas
-- Ejecutar después de 08_matching.sql y 09_update_chat_for_matching.sql
-- =====================================================

-- Corregir get_match_candidates para evitar ambigüedad con user_id
-- Primero eliminamos la función para permitir cambio de tipo de retorno
DROP FUNCTION IF EXISTS public.get_match_candidates(uuid, integer);

CREATE OR REPLACE FUNCTION public.get_match_candidates(for_user_id UUID, limit_count INTEGER DEFAULT 20)
RETURNS TABLE (
  user_id UUID,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  compatibility_score DECIMAL(5,2),
  budget_min DECIMAL(10,2),
  budget_max DECIMAL(10,2),
  cleanliness_level INTEGER,
  sleep_schedule TEXT,
  noise_level TEXT,
  is_smoker BOOLEAN,
  has_pets BOOLEAN,
  exercises BOOLEAN,
  plays_videogames BOOLEAN,
  plays_music BOOLEAN,
  works_from_home BOOLEAN,
  likes_parties BOOLEAN,
  interests TEXT[]
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    mc.user_id,
    mc.first_name,
    mc.last_name,
    mc.avatar_url,
    mc.bio,
    public.calculate_match_score(for_user_id, mc.user_id) as compatibility_score,
    mc.budget_min,
    mc.budget_max,
    mc.cleanliness_level,
    mc.sleep_schedule,
    mc.noise_level,
    mc.is_smoker,
    mc.has_pets,
    mc.exercises,
    mc.plays_videogames,
    mc.plays_music,
    mc.works_from_home,
    mc.likes_parties,
    mc.interests
  FROM public.match_candidates mc
  WHERE mc.user_id != for_user_id
    AND mc.user_id NOT IN (
      -- Usamos alias 'ui' para evitar ambigüedad con el parámetro de salida 'user_id'
      SELECT ui.target_user_id FROM public.user_interactions ui WHERE ui.user_id = for_user_id
    )
  ORDER BY compatibility_score DESC
  LIMIT limit_count;
END;
$$;

-- Corregir get_daily_likes_count por seguridad
CREATE OR REPLACE FUNCTION public.get_daily_likes_count(for_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  likes_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO likes_count
  FROM public.user_interactions ui
  WHERE ui.user_id = for_user_id
    AND ui.action IN ('like', 'super_like')
    AND ui.created_at >= CURRENT_DATE;
  
  RETURN likes_count;
END;
$$;
