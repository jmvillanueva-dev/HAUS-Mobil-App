-- =====================================================
-- HAUS - Seed Dummy Users for Matching
-- Genera 20 usuarios de prueba con perfiles y preferencias
-- Ejecutar en Supabase SQL Editor
-- =====================================================

-- Asegurar que pgcrypto está habilitado para gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

DO $$
DECLARE
  i INTEGER := 0;
  new_user_id UUID;
  first_names TEXT[] := ARRAY['Ana', 'Carlos', 'Sofia', 'Diego', 'Laura', 'Juan', 'Valentina', 'Andres', 'Camila', 'Gabriel', 'Lucia', 'Mateo', 'Isabella', 'Alejandro', 'Mariana', 'Santiago', 'Gabriela', 'Daniel', 'Fernanda', 'David'];
  last_names TEXT[] := ARRAY['Garcia', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Perez', 'Sanchez', 'Ramirez', 'Torres', 'Flores', 'Rivera', 'Gomez', 'Diaz', 'Reyes', 'Morales', 'Cruz', 'Ortiz', 'Gutierrez', 'Chavez'];
  avatars TEXT[] := ARRAY[
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1504257432389-52343af06ae3?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1548142813-c348350df52b?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1554151228-14d9def656ec?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1463453091185-61582044d556?auto=format&fit=crop&w=200&q=80'
  ];
  
  -- Preferencias aleatorias
  v_budget_min INTEGER;
  v_budget_max INTEGER;
  v_cleanliness INTEGER;
  v_sleep TEXT;
  v_noise TEXT;
  v_smoker BOOLEAN;
  v_pets BOOLEAN;
  v_exercises BOOLEAN;
  v_videogames BOOLEAN;
  v_music BOOLEAN;
  v_wfh BOOLEAN;
  v_parties BOOLEAN;
  v_role TEXT;
  
BEGIN
  -- 0. Limpiar usuarios de prueba anteriores para evitar duplicados
  -- Borramos de auth.users y el cascade se encarga del resto
  DELETE FROM auth.users WHERE email LIKE 'test_roomie_%@haus.app';

  FOR i IN 1..20 LOOP
    -- 1. Generar ID
    new_user_id := gen_random_uuid();
    
    -- Determinar rol aleatorio
    IF random() < 0.5 THEN
      v_role := 'student';
    ELSE
      v_role := 'worker';
    END IF;
    
    -- 2. Insertar en auth.users (Simulado)
    INSERT INTO auth.users (
      id,
      instance_id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at
    ) VALUES (
      new_user_id,
      '00000000-0000-0000-0000-000000000000',
      'authenticated',
      'authenticated',
      'test_roomie_' || i || '@haus.app',
      '$2a$10$abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN0123456789', -- Password dummy hash
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(),
      now()
    );

    -- 3. Insertar o Actualizar en public.profiles
    -- Usamos ON CONFLICT por si existe un trigger que crea el perfil automáticamente
    INSERT INTO public.profiles (
      id,
      first_name,
      last_name,
      avatar_url,
      bio,
      role,
      created_at,
      updated_at
    ) VALUES (
      new_user_id,
      first_names[i],
      last_names[i],
      avatars[i],
      'Hola, soy ' || first_names[i] || '. Busco un lugar tranquilo y buena compañía. Me gusta el orden y respetar el espacio de los demás.',
      v_role::user_role,
      now(),
      now()
    )
    ON CONFLICT (id) DO UPDATE SET
      first_name = EXCLUDED.first_name,
      last_name = EXCLUDED.last_name,
      avatar_url = EXCLUDED.avatar_url,
      bio = EXCLUDED.bio,
      role = EXCLUDED.role,
      updated_at = now();

    -- 4. Generar preferencias aleatorias
    v_budget_min := (floor(random() * 3) + 1) * 100; -- 100, 200, 300
    v_budget_max := v_budget_min + (floor(random() * 3) + 1) * 100 + 100; -- +200 a +400
    v_cleanliness := floor(random() * 5) + 1; -- 1-5
    
    IF random() < 0.33 THEN v_sleep := 'early_bird';
    ELSIF random() < 0.66 THEN v_sleep := 'night_owl';
    ELSE v_sleep := 'flexible'; END IF;
    
    IF random() < 0.33 THEN v_noise := 'quiet';
    ELSIF random() < 0.66 THEN v_noise := 'moderate';
    ELSE v_noise := 'social'; END IF;
    
    v_smoker := random() > 0.8; -- 20% fumadores
    v_pets := random() > 0.7; -- 30% tienen mascotas
    v_exercises := random() > 0.5;
    v_videogames := random() > 0.5;
    v_music := random() > 0.6;
    v_wfh := random() > 0.7; -- 30% home office
    v_parties := random() > 0.8; -- 20% fiestas

    -- 5. Insertar en public.user_preferences
    INSERT INTO public.user_preferences (
      user_id,
      budget_min,
      budget_max,
      cleanliness_level,
      sleep_schedule,
      noise_level,
      is_smoker,
      has_pets,
      exercises,
      plays_videogames,
      plays_music,
      works_from_home,
      likes_parties,
      preferred_gender,
      preferred_smoker,
      preferred_pet_friendly,
      guests_frequency,
      drinks_alcohol,
      interests,
      preferences_completed
    ) VALUES (
      new_user_id,
      v_budget_min,
      v_budget_max,
      v_cleanliness,
      v_sleep,
      v_noise,
      v_smoker,
      v_pets,
      v_exercises,
      v_videogames,
      v_music,
      v_wfh,
      v_parties,
      'any', -- preferred_gender
      'indifferent', -- preferred_smoker
      true, -- preferred_pet_friendly
      'sometimes', -- guests_frequency
      'socially', -- drinks_alcohol
      ARRAY['Cine', 'Música', 'Viajes'], -- interests dummy
      true
    );
    
  END LOOP;
END $$;
