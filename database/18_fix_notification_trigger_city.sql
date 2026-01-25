-- =====================================================
-- FIX 2: Error en Trigger Notificaciones
-- Error: column p.city does not exist
-- Causa: La tabla profiles no tiene columna city. La ciudad está en user_locations.
-- Solución: Unir con user_locations o eliminar el filtro de ciudad por ahora.
--           Para simplificar y evitar errores de joins complejos en triggers,
--           notificaremos a todos (limitado a 100) o si implementamos el join:
-- =====================================================

CREATE OR REPLACE FUNCTION create_listing_notification()
RETURNS TRIGGER AS $$
DECLARE
  listing_image TEXT;
BEGIN
  -- Obtener primera imagen del listing
  IF array_length(NEW.image_urls, 1) > 0 THEN
    listing_image := NEW.image_urls[1];
  ELSE
    listing_image := NULL;
  END IF;
  
  -- Notificar a usuarios. 
  -- Intentamos buscar usuarios con ubicación de búsqueda 'search' en la misma ciudad.
  -- Si no hay ubicación, no filtramos por ciudad (o podríamos omitirlos).
  -- Estrategia robusta: JOIN con user_locations.
  
  INSERT INTO notifications (user_id, type, title, body, data, image_url)
  SELECT DISTINCT
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
  LEFT JOIN user_locations ul ON p.id = ul.user_id AND ul.purpose = 'search'
  WHERE p.id != NEW.user_id
    AND (
      NEW.city IS NULL 
      OR ul.city IS NULL 
      OR ul.city = NEW.city
    )
  LIMIT 100;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
