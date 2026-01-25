-- =====================================================
-- HAUS - Simular Likes Entrantes (Cheat Script)
-- Ejecutar para recibir likes de los usuarios dummy
-- =====================================================

DO $$
DECLARE
  -- !!! IMPORTANTE: CAMBIA ESTO POR TU EMAIL DE LOGIN !!!
  my_email TEXT := 'tu_email@ejemplo.com'; 
  
  my_user_id UUID;
BEGIN
  -- 1. Obtener tu ID de usuario
  SELECT id INTO my_user_id FROM auth.users WHERE email = my_email;

  IF my_user_id IS NULL THEN
    RAISE NOTICE 'Usuario no encontrado. Asegúrate de poner tu email correcto en la variable my_email.';
    RETURN;
  END IF;

  -- 2. Hacer que 10 usuarios dummy aleatorios te den like
  INSERT INTO public.user_interactions (user_id, target_user_id, action)
  SELECT id, my_user_id, 'like'
  FROM auth.users
  WHERE email LIKE 'test_roomie_%@haus.app' -- Solo usuarios dummy
    AND id != my_user_id -- No auto-like (por si acaso)
  ORDER BY random()
  LIMIT 10
  ON CONFLICT (user_id, target_user_id) DO NOTHING;
  
  RAISE NOTICE '¡Listo! 10 usuarios dummy ahora te han dado like. Ve a la app y dales like para hacer Match.';
END $$;
