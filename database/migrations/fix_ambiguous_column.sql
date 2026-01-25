-- =====================================================
-- FIX: Resolver ambigüedad en columna compatibility_score
-- =====================================================

CREATE OR REPLACE FUNCTION public.get_match_candidates(for_user_id UUID, limit_count INTEGER DEFAULT 20)
RETURNS TABLE (
  user_id UUID,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  role TEXT,
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
  WITH scored_candidates AS (
    SELECT 
      mc.user_id,
      mc.first_name,
      mc.last_name,
      mc.avatar_url,
      mc.bio,
      mc.role::TEXT,
      -- Renombramos la columna calculada para evitar conflicto con el parámetro de salida
      public.calculate_match_score(for_user_id, mc.user_id) as calc_score,
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
        SELECT ui.target_user_id FROM public.user_interactions ui WHERE ui.user_id = for_user_id
      )
  )
  SELECT 
    sc.user_id,
    sc.first_name,
    sc.last_name,
    sc.avatar_url,
    sc.bio,
    sc.role,
    sc.calc_score as compatibility_score, -- Mapeamos de vuelta al nombre esperado
    sc.budget_min,
    sc.budget_max,
    sc.cleanliness_level,
    sc.sleep_schedule,
    sc.noise_level,
    sc.is_smoker,
    sc.has_pets,
    sc.exercises,
    sc.plays_videogames,
    sc.plays_music,
    sc.works_from_home,
    sc.likes_parties,
    sc.interests
  FROM scored_candidates sc
  WHERE sc.calc_score >= 30 -- Usamos el nombre interno
  ORDER BY sc.calc_score DESC
  LIMIT limit_count;
END;
$$;

COMMENT ON FUNCTION public.get_match_candidates IS 'Obtiene candidatos de matching con al menos 30% de compatibilidad (Fix ambigüedad)';
