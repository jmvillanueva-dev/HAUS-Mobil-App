-- =====================================================
-- HAUS - Corrección de Trigger de Mensajes
-- 1. Corrige el acceso al array de imágenes (text[] vs json)
-- 2. Usa LEFT JOIN para permitir mensajes en conversaciones de Match (sin listing)
-- =====================================================

CREATE OR REPLACE FUNCTION create_message_notification()
RETURNS TRIGGER AS $$
DECLARE
  recipient_id UUID;
  sender_name TEXT;
  sender_avatar TEXT;
  
  -- Variables para datos del listing
  v_listing_id UUID;
  v_listing_title TEXT;
  v_listing_price NUMERIC;
  v_listing_image TEXT;
BEGIN
  -- Obtener el destinatario y datos del listing (si existe)
  SELECT 
    CASE 
      WHEN c.user_id = NEW.sender_id THEN c.host_id 
      ELSE c.user_id 
    END,
    l.id,
    l.title,
    l.price,
    l.image_urls[1] -- CORREGIDO: Sintaxis de array Postgres [1] en lugar de JSON ->>0
  INTO 
    recipient_id, 
    v_listing_id, 
    v_listing_title, 
    v_listing_price, 
    v_listing_image
  FROM conversations c
  LEFT JOIN listings l ON c.listing_id = l.id -- CORREGIDO: LEFT JOIN para soportar matches sin listing
  WHERE c.id = NEW.conversation_id;
  
  -- Obtener nombre y avatar del remitente
  SELECT 
    COALESCE(first_name || ' ' || last_name, 'Usuario'),
    avatar_url
  INTO sender_name, sender_avatar
  FROM profiles 
  WHERE id = NEW.sender_id;
  
  -- No crear notificación si el remitente es el mismo destinatario
  IF recipient_id IS NOT NULL AND recipient_id != NEW.sender_id THEN
    INSERT INTO notifications (user_id, type, title, body, data, image_url)
    VALUES (
      recipient_id,
      'chat_message',
      sender_name,
      LEFT(NEW.content, 100),
      jsonb_build_object(
        'conversationId', NEW.conversation_id,
        'messageId', NEW.id,
        'senderId', NEW.sender_id,
        'listingId', v_listing_id,
        'listingTitle', v_listing_title,
        'listingPrice', v_listing_price,
        'listingImage', v_listing_image
      ),
      sender_avatar
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
