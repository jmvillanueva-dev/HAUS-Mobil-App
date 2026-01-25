-- =====================================================
-- HAUS - Sistema de Matching de Roomies
-- Ejecutar después de 07_user_preferences.sql
-- =====================================================

-- =====================================================
-- TABLA: user_interactions
-- Registra los likes/skips entre usuarios
-- =====================================================

CREATE TABLE IF NOT EXISTS public.user_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Usuario que realiza la acción
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Usuario objetivo de la acción
  target_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Tipo de acción: 'like', 'skip', 'super_like'
  action TEXT NOT NULL CHECK (action IN ('like', 'skip', 'super_like')),
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  
  -- Restricción: Solo una interacción por par de usuarios
  CONSTRAINT unique_interaction UNIQUE(user_id, target_user_id),
  
  -- No puede interactuar consigo mismo
  CONSTRAINT no_self_interaction CHECK (user_id != target_user_id)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_interactions_user ON public.user_interactions(user_id);
CREATE INDEX IF NOT EXISTS idx_interactions_target ON public.user_interactions(target_user_id);
CREATE INDEX IF NOT EXISTS idx_interactions_action ON public.user_interactions(action);
CREATE INDEX IF NOT EXISTS idx_interactions_date ON public.user_interactions(created_at DESC);

-- =====================================================
-- TABLA: matches
-- Almacena los matches mutuos entre usuarios
-- =====================================================

CREATE TABLE IF NOT EXISTS public.matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Los dos usuarios del match (user_a siempre < user_b para evitar duplicados)
  user_a UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  user_b UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Score de compatibilidad calculado (0-100)
  compatibility_score DECIMAL(5,2) DEFAULT 0,
  
  -- Conversación creada automáticamente
  conversation_id UUID REFERENCES public.conversations(id) ON DELETE SET NULL,
  
  -- Estado del match
  is_active BOOLEAN DEFAULT true,
  
  -- Timestamps
  matched_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  
  -- Restricción: user_a siempre menor que user_b para evitar duplicados
  CONSTRAINT unique_match UNIQUE(user_a, user_b),
  CONSTRAINT ordered_users CHECK (user_a < user_b)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_matches_user_a ON public.matches(user_a);
CREATE INDEX IF NOT EXISTS idx_matches_user_b ON public.matches(user_b);
CREATE INDEX IF NOT EXISTS idx_matches_active ON public.matches(is_active);
CREATE INDEX IF NOT EXISTS idx_matches_date ON public.matches(matched_at DESC);

-- =====================================================
-- FUNCIÓN: Calcular Match Score Simple
-- Retorna un porcentaje (0-100) de compatibilidad
-- =====================================================

CREATE OR REPLACE FUNCTION public.calculate_match_score(user_a_id UUID, user_b_id UUID)
RETURNS DECIMAL(5,2)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  prefs_a public.user_preferences%ROWTYPE;
  prefs_b public.user_preferences%ROWTYPE;
  profile_a public.profiles%ROWTYPE;
  profile_b public.profiles%ROWTYPE;
  total_fields INTEGER := 15;
  matching_fields INTEGER := 0;
BEGIN
  -- Obtener preferencias de ambos usuarios
  SELECT * INTO prefs_a FROM public.user_preferences WHERE user_id = user_a_id;
  SELECT * INTO prefs_b FROM public.user_preferences WHERE user_id = user_b_id;
  SELECT * INTO profile_a FROM public.profiles WHERE id = user_a_id;
  SELECT * INTO profile_b FROM public.profiles WHERE id = user_b_id;
  
  -- Si alguno no tiene preferencias, retornar 0
  IF prefs_a IS NULL OR prefs_b IS NULL THEN
    RETURN 0;
  END IF;
  
  -- 1. Fumador: Compatible si A acepta fumador O B no fuma
  IF prefs_a.preferred_smoker = 'indifferent' 
     OR (prefs_a.preferred_smoker = 'no' AND prefs_b.is_smoker = false)
     OR (prefs_a.preferred_smoker = 'yes' AND prefs_b.is_smoker = true) THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 2. Alcohol: Mismo nivel o flexible
  IF prefs_a.drinks_alcohol = prefs_b.drinks_alcohol 
     OR prefs_a.drinks_alcohol = 'socially' 
     OR prefs_b.drinks_alcohol = 'socially' THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 3. Mascotas: A acepta mascotas O B no tiene
  IF prefs_a.preferred_pet_friendly = true OR prefs_b.has_pets = false THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 4. Horario de sueño: Mismo o uno es flexible
  IF prefs_a.sleep_schedule = prefs_b.sleep_schedule 
     OR prefs_a.sleep_schedule = 'flexible' 
     OR prefs_b.sleep_schedule = 'flexible' THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 5. Nivel de ruido: Mismo o compatible
  IF prefs_a.noise_level = prefs_b.noise_level 
     OR prefs_a.preferred_noise_level = 'any'
     OR prefs_a.noise_level = 'moderate' 
     OR prefs_b.noise_level = 'moderate' THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 6. Limpieza: Diferencia <= 1
  IF ABS(COALESCE(prefs_a.cleanliness_level, 3) - COALESCE(prefs_b.cleanliness_level, 3)) <= 1 THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 7. Visitas/Invitados: Compatible
  IF prefs_a.guests_frequency = prefs_b.guests_frequency 
     OR prefs_a.guests_frequency = 'sometimes' 
     OR prefs_b.guests_frequency = 'sometimes' THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 8. Género preferido: Coincide (simplificado - asume any = OK)
  IF prefs_a.preferred_gender = 'any' THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 9. Edad: Dentro del rango (simplificado - sin profile data aquí, asume OK)
  -- En producción se compararía con la edad real del perfil
  matching_fields := matching_fields + 1;
  
  -- 10. Presupuesto: Rangos se superponen
  IF (COALESCE(prefs_a.budget_min, 0) <= COALESCE(prefs_b.budget_max, 9999)) 
     AND (COALESCE(prefs_a.budget_max, 9999) >= COALESCE(prefs_b.budget_min, 0)) THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 11. Ejercicio: Ambos o ninguno
  IF prefs_a.exercises = prefs_b.exercises THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 12. Videojuegos: Ambos o ninguno
  IF prefs_a.plays_videogames = prefs_b.plays_videogames THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 13. Música: Ambos o ninguno
  IF prefs_a.plays_music = prefs_b.plays_music THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 14. Trabajo remoto: Ambos o ninguno
  IF prefs_a.works_from_home = prefs_b.works_from_home THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- 15. Fiestas: Ambos o ninguno
  IF prefs_a.likes_parties = prefs_b.likes_parties THEN
    matching_fields := matching_fields + 1;
  END IF;
  
  -- Calcular porcentaje
  RETURN ROUND((matching_fields::DECIMAL / total_fields) * 100, 2);
END;
$$;

-- =====================================================
-- FUNCIÓN: Verificar y crear match mutuo
-- Se ejecuta cuando hay un nuevo like
-- =====================================================

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
      
      -- Crear conversación para el match (sin listing_id ya que es match de personas)
      -- Nota: Esto requiere modificar la tabla conversations o crear una separada
      -- Por ahora, dejamos conversation_id como NULL y lo manejamos en Flutter
      
      -- Insertar match
      INSERT INTO public.matches (user_a, user_b, compatibility_score)
      VALUES (ordered_user_a, ordered_user_b, match_score)
      RETURNING id INTO new_match_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Trigger para verificar matches al insertar interacción
DROP TRIGGER IF EXISTS on_interaction_check_match ON public.user_interactions;

CREATE TRIGGER on_interaction_check_match
  AFTER INSERT ON public.user_interactions
  FOR EACH ROW EXECUTE FUNCTION public.check_and_create_match();

-- =====================================================
-- VISTA: Candidatos para matching
-- Usuarios que NO has interactuado y tienen preferencias completas
-- =====================================================

CREATE OR REPLACE VIEW public.match_candidates AS
SELECT 
  p.id as user_id,
  p.first_name,
  p.last_name,
  p.avatar_url,
  p.bio,
  p.role,
  up.budget_min,
  up.budget_max,
  up.cleanliness_level,
  up.sleep_schedule,
  up.noise_level,
  up.is_smoker,
  up.has_pets,
  up.exercises,
  up.plays_videogames,
  up.plays_music,
  up.works_from_home,
  up.likes_parties,
  up.interests
FROM public.profiles p
JOIN public.user_preferences up ON p.id = up.user_id
WHERE up.preferences_completed = true;

-- =====================================================
-- RLS POLICIES
-- =====================================================

ALTER TABLE public.user_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;

-- user_interactions: Ver propias interacciones
DROP POLICY IF EXISTS "Users can view own interactions" ON public.user_interactions;
CREATE POLICY "Users can view own interactions"
  ON public.user_interactions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- user_interactions: Crear propias interacciones
DROP POLICY IF EXISTS "Users can create own interactions" ON public.user_interactions;
CREATE POLICY "Users can create own interactions"
  ON public.user_interactions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- matches: Ver propios matches
DROP POLICY IF EXISTS "Users can view own matches" ON public.matches;
CREATE POLICY "Users can view own matches"
  ON public.matches FOR SELECT
  TO authenticated
  USING (auth.uid() = user_a OR auth.uid() = user_b);

-- =====================================================
-- FUNCIÓN: Obtener candidatos para un usuario
-- Excluye usuarios ya interactuados
-- =====================================================

-- Eliminar función anterior si existe para permitir cambio de tipo de retorno
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
      SELECT ui.target_user_id FROM public.user_interactions ui WHERE ui.user_id = for_user_id
    )
  ORDER BY compatibility_score DESC
  LIMIT limit_count;
END;
$$;

-- =====================================================
-- FUNCIÓN: Contar likes del día
-- Para el límite de 10 likes diarios
-- =====================================================

CREATE OR REPLACE FUNCTION public.get_daily_likes_count(for_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  likes_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO likes_count
  FROM public.user_interactions
  WHERE user_id = for_user_id
    AND action IN ('like', 'super_like')
    AND created_at >= CURRENT_DATE;
  
  RETURN likes_count;
END;
$$;

-- =====================================================
-- HABILITAR REALTIME
-- =====================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.matches;

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON TABLE public.user_interactions IS 'Interacciones de like/skip entre usuarios para matching';
COMMENT ON TABLE public.matches IS 'Matches mutuos entre usuarios';
COMMENT ON FUNCTION public.calculate_match_score IS 'Calcula compatibilidad entre dos usuarios (0-100%)';
COMMENT ON FUNCTION public.get_match_candidates IS 'Obtiene candidatos de matching para un usuario';
COMMENT ON FUNCTION public.get_daily_likes_count IS 'Cuenta likes del día para límite diario';
