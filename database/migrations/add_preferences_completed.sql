-- =====================================================
-- MIGRATION: Add preferences_completed to user_preferences
-- Safe migration: Checks if column exists before adding
-- =====================================================

DO $$ 
BEGIN 
    -- Verificar si la columna ya existe
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_preferences' 
        AND column_name = 'preferences_completed'
    ) THEN
        -- Agregar la columna si no existe
        ALTER TABLE public.user_preferences 
        ADD COLUMN preferences_completed BOOLEAN DEFAULT false;
        
        -- Agregar comentario
        COMMENT ON COLUMN public.user_preferences.preferences_completed IS 'Indica si el usuario completó el formulario de preferencias. Requerido para participar en matching.';
        
        -- Crear índice para optimizar consultas
        CREATE INDEX IF NOT EXISTS idx_user_preferences_completed 
        ON public.user_preferences(preferences_completed);
        
        RAISE NOTICE 'Columna preferences_completed agregada exitosamente.';
    ELSE
        RAISE NOTICE 'La columna preferences_completed ya existe.';
    END IF;
END $$;
