-- =====================================================
-- FIX/FEATURE: Notificaciones de Solicitudes
-- Ejecutar en Supabase SQL Editor
-- =====================================================

-- 1. Actualizar el constraint de 'type' en notifications
-- Primero eliminamos el check existente para agregar nuevos tipos
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;

-- Agregamos el check con los nuevos tipos incluidos
ALTER TABLE public.notifications 
ADD CONSTRAINT notifications_type_check 
CHECK (type IN ('chat_message', 'new_listing', 'match_request', 'system', 'request_received', 'request_update'));

-- 2. Función para crear notificación al recibir solicitud
CREATE OR REPLACE FUNCTION public.create_request_notification()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  requester_name TEXT;
  requester_avatar TEXT;
  listing_title TEXT;
  listing_image TEXT;
BEGIN
  -- Obtener información del solicitante
  SELECT 
    COALESCE(first_name || ' ' || last_name, 'Un usuario'),
    avatar_url
  INTO requester_name, requester_avatar
  FROM public.profiles
  WHERE id = NEW.requester_id;

  -- Obtener información del listing
  SELECT 
    title,
    CASE 
      WHEN image_urls IS NOT NULL AND array_length(image_urls, 1) > 0 THEN image_urls[1]
      ELSE NULL 
    END
  INTO listing_title, listing_image
  FROM public.listings
  WHERE id = NEW.listing_id;

  -- Crear la notificación para el DUEÑO (host_id)
  -- Importante: El host_id debe estar populated en listing_requests (ver paso anterior)
  INSERT INTO public.notifications (
    user_id,
    type,
    title,
    body,
    data,
    image_url
  ) VALUES (
    NEW.host_id,
    'request_received',
    'Nueva Solicitud de Interés',
    requester_name || ' está interesado en tu publicación: ' || COALESCE(listing_title, 'Tu propiedad'),
    jsonb_build_object(
      'requestId', NEW.id,
      'listingId', NEW.listing_id,
      'requesterId', NEW.requester_id
    ),
    requester_avatar -- Usamos la foto del usuario para que sepa quién es
  );

  RETURN NEW;
END;
$$;

-- 3. Trigger en listing_requests
DROP TRIGGER IF EXISTS on_new_request_notification ON public.listing_requests;

CREATE TRIGGER on_new_request_notification
  AFTER INSERT ON public.listing_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.create_request_notification();

-- 4. (Opcional) Notificación cuando se aprueba/rechaza
CREATE OR REPLACE FUNCTION public.create_request_status_notification()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  listing_title TEXT;
  listing_image TEXT;
BEGIN
  -- Solo notificar si cambió el estado
  IF OLD.status = NEW.status THEN
    RETURN NEW;
  END IF;

  -- Obtener info del listing
  SELECT 
    title,
    CASE 
      WHEN image_urls IS NOT NULL AND array_length(image_urls, 1) > 0 THEN image_urls[1]
      ELSE NULL 
    END
  INTO listing_title, listing_image
  FROM public.listings
  WHERE id = NEW.listing_id;

  -- Notificar al SOLICITANTE
  INSERT INTO public.notifications (
    user_id,
    type,
    title,
    body,
    data,
    image_url
  ) VALUES (
    NEW.requester_id,
    'request_update',
    'Actualización de Solicitud',
    CASE 
      WHEN NEW.status = 'approved' THEN '¡Tu solicitud para ' || COALESCE(listing_title, 'la propiedad') || ' ha sido aprobada!'
      WHEN NEW.status = 'rejected' THEN 'Tu solicitud para ' || COALESCE(listing_title, 'la propiedad') || ' no fue aceptada.'
      ELSE 'El estado de tu solicitud ha cambiado a ' || NEW.status
    END,
    jsonb_build_object(
      'requestId', NEW.id,
      'listingId', NEW.listing_id,
      'status', NEW.status
    ),
    listing_image -- Usamos la foto de la casa aquí
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_request_status_change ON public.listing_requests;

CREATE TRIGGER on_request_status_change
  AFTER UPDATE ON public.listing_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.create_request_status_notification();
