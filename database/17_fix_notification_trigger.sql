-- =====================================================
-- FIX: Error en Trigger de Notificaciones de Listing
-- Error: operator does not exist: text[] >> integer
-- Causa: Uso de operador JSON ->>0 en columna text[] image_urls
-- Solución: Usar sintaxis de array de Postgres [1]
-- =====================================================

CREATE OR REPLACE FUNCTION create_listing_notification()
RETURNS TRIGGER AS $$
DECLARE
  listing_image TEXT;
BEGIN
  -- Obtener primera imagen del listing (Postgres arrays are 1-indexed)
  -- image_urls is text[], not json
  IF array_length(NEW.image_urls, 1) > 0 THEN
    listing_image := NEW.image_urls[1];
  ELSE
    listing_image := NULL;
  END IF;
  
  -- Notificar a usuarios que podrían estar interesados
  INSERT INTO notifications (user_id, type, title, body, data, image_url)
  SELECT 
    p.id,
    'new_listing',
    'Nueva publicación disponible',
    NEW.title || ' - $' || NEW.price || ' en ' || COALESCE(NEW.city, 'tu zona'),
    jsonb_build_object(
      'listingId', NEW.id,
      'title', NEW.title,
      'price', NEW.price,
      'city', NEW.city
    ),
    listing_image
  FROM profiles p
  WHERE p.id != NEW.user_id
    -- Filtro básico
    AND (
      p.city IS NULL 
      OR NEW.city IS NULL
      OR p.city = NEW.city 
    )
  LIMIT 100;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
