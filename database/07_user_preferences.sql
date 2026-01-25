-- =====================================================
-- HAUS - User Preferences para Matching
-- Ejecutar en Supabase SQL Editor
-- =====================================================

-- =====================================================
-- TABLA: user_preferences
-- Almacena las preferencias de convivencia del usuario
-- para el sistema de matching de roomies
-- =====================================================

CREATE TABLE IF NOT EXISTS public.user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  
  -- ═══════════════════════════════════════════════════
  -- HÁBITOS PERSONALES (sobre el usuario)
  -- ═══════════════════════════════════════════════════
  is_smoker BOOLEAN DEFAULT false,
  drinks_alcohol TEXT CHECK (drinks_alcohol IN ('never', 'socially', 'regularly')) DEFAULT 'socially',
  has_pets BOOLEAN DEFAULT false,
  pet_type TEXT, -- 'dog', 'cat', 'bird', 'other', null
  
  -- ═══════════════════════════════════════════════════
  -- ESTILO DE VIDA
  -- ═══════════════════════════════════════════════════
  sleep_schedule TEXT CHECK (sleep_schedule IN ('early_bird', 'night_owl', 'flexible')) DEFAULT 'flexible',
  work_schedule TEXT CHECK (work_schedule IN ('morning', 'afternoon', 'night', 'remote', 'flexible')) DEFAULT 'flexible',
  noise_level TEXT CHECK (noise_level IN ('quiet', 'moderate', 'social')) DEFAULT 'moderate',
  cleanliness_level INTEGER CHECK (cleanliness_level BETWEEN 1 AND 5) DEFAULT 3,
  guests_frequency TEXT CHECK (guests_frequency IN ('never', 'rarely', 'sometimes', 'often')) DEFAULT 'sometimes',
  
  -- ═══════════════════════════════════════════════════
  -- ACTIVIDADES & INTERESES
  -- ═══════════════════════════════════════════════════
  exercises BOOLEAN DEFAULT false,
  exercise_frequency TEXT CHECK (exercise_frequency IN ('never', 'sometimes', 'regularly', 'daily')),
  diet_preference TEXT CHECK (diet_preference IN ('none', 'vegetarian', 'vegan', 'keto', 'other')),
  cooking_frequency TEXT CHECK (cooking_frequency IN ('never', 'sometimes', 'often', 'daily')) DEFAULT 'sometimes',
  studies_at_home BOOLEAN DEFAULT false,
  works_from_home BOOLEAN DEFAULT false,
  plays_music BOOLEAN DEFAULT false,
  plays_videogames BOOLEAN DEFAULT false,
  watches_movies BOOLEAN DEFAULT false,
  likes_reading BOOLEAN DEFAULT false,
  likes_outdoor_activities BOOLEAN DEFAULT false,
  likes_parties BOOLEAN DEFAULT false,
  
  -- ═══════════════════════════════════════════════════
  -- PREFERENCIAS DE ROOMIE (lo que busca)
  -- ═══════════════════════════════════════════════════
  preferred_gender TEXT CHECK (preferred_gender IN ('male', 'female', 'any')) DEFAULT 'any',
  preferred_age_min INTEGER DEFAULT 18,
  preferred_age_max INTEGER DEFAULT 99,
  preferred_smoker TEXT CHECK (preferred_smoker IN ('yes', 'no', 'indifferent')) DEFAULT 'indifferent',
  preferred_pet_friendly BOOLEAN DEFAULT true,
  preferred_noise_level TEXT CHECK (preferred_noise_level IN ('quiet', 'moderate', 'social', 'any')) DEFAULT 'any',
  preferred_cleanliness_min INTEGER CHECK (preferred_cleanliness_min BETWEEN 1 AND 5) DEFAULT 1,
  
  -- ═══════════════════════════════════════════════════
  -- PRESUPUESTO (USD)
  -- ═══════════════════════════════════════════════════
  budget_min DECIMAL(10,2),
  budget_max DECIMAL(10,2),
  
  -- ═══════════════════════════════════════════════════
  -- INTERESES PERSONALIZADOS (tags libres)
  -- ═══════════════════════════════════════════════════
  interests TEXT[] DEFAULT '{}',
  
  -- Indica si el usuario completó sus preferencias (requerido para matching)
  preferences_completed BOOLEAN DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =====================================================
-- ÍNDICES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id 
  ON public.user_preferences(user_id);

CREATE INDEX IF NOT EXISTS idx_user_preferences_completed 
  ON public.user_preferences(preferences_completed);

-- =====================================================
-- TRIGGER: Actualizar updated_at automáticamente
-- =====================================================

DROP TRIGGER IF EXISTS on_user_preferences_updated ON public.user_preferences;

CREATE TRIGGER on_user_preferences_updated
  BEFORE UPDATE ON public.user_preferences
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- RLS POLICIES
-- =====================================================

ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "Users can view all preferences for matching" ON public.user_preferences;
DROP POLICY IF EXISTS "Users can insert own preferences" ON public.user_preferences;
DROP POLICY IF EXISTS "Users can update own preferences" ON public.user_preferences;
DROP POLICY IF EXISTS "Users can delete own preferences" ON public.user_preferences;

-- SELECT: Usuarios autenticados pueden ver todas las preferencias (necesario para matching)
CREATE POLICY "Users can view all preferences for matching"
  ON public.user_preferences FOR SELECT 
  TO authenticated 
  USING (true);

-- INSERT: Solo puede crear sus propias preferencias
CREATE POLICY "Users can insert own preferences"
  ON public.user_preferences FOR INSERT 
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- UPDATE: Solo puede actualizar sus propias preferencias
CREATE POLICY "Users can update own preferences"
  ON public.user_preferences FOR UPDATE 
  TO authenticated
  USING (auth.uid() = user_id);

-- DELETE: Solo puede eliminar sus propias preferencias
CREATE POLICY "Users can delete own preferences"
  ON public.user_preferences FOR DELETE 
  TO authenticated
  USING (auth.uid() = user_id);

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE public.user_preferences IS 'Preferencias de convivencia del usuario para el sistema de matching de HAUS';
COMMENT ON COLUMN public.user_preferences.preferences_completed IS 'Indica si el usuario completó el formulario de preferencias. Requerido para participar en matching.';
COMMENT ON COLUMN public.user_preferences.cleanliness_level IS 'Nivel de limpieza del usuario: 1 (relajado) a 5 (muy ordenado)';
COMMENT ON COLUMN public.user_preferences.interests IS 'Array de intereses/hobbies personalizados del usuario';

-- =====================================================
-- VERIFICACIÓN
-- =====================================================
-- Verificar que la tabla se creó:
-- SELECT column_name, data_type, column_default
-- FROM information_schema.columns 
-- WHERE table_name = 'user_preferences';

-- Verificar políticas:
-- SELECT policyname FROM pg_policies 
-- WHERE tablename = 'user_preferences';
