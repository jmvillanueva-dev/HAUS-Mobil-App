-- =====================================================
-- TABLA DE NOTIFICACIONES IN-APP
-- =====================================================
-- Descripción: Sistema de notificaciones persistentes
-- Permite mostrar historial de notificaciones al usuario
-- =====================================================

-- Tabla principal de notificaciones
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('chat_message', 'new_listing', 'match_request', 'system')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  image_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para optimización
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Los usuarios solo pueden ver sus propias notificaciones
CREATE POLICY "Users can read own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Los usuarios pueden marcar como leídas sus notificaciones
CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- Solo el sistema (service role) puede insertar notificaciones
CREATE POLICY "System can insert notifications"
  ON notifications FOR INSERT
  WITH CHECK (TRUE);

-- =====================================================
-- FUNCIÓN: Crear notificación de mensaje nuevo
-- =====================================================
-- Se ejecuta automáticamente cuando se inserta un mensaje
-- Crea una notificación para el destinatario

CREATE OR REPLACE FUNCTION create_message_notification()
RETURNS TRIGGER AS $$
DECLARE
  recipient_id UUID;
  sender_name TEXT;
  listing_title TEXT;
  sender_avatar TEXT;
BEGIN
  -- Obtener el destinatario (el otro usuario en la conversación)
  SELECT 
    CASE 
      WHEN c.user_id = NEW.sender_id THEN c.host_id 
      ELSE c.user_id 
    END,
    l.title
  INTO recipient_id, listing_title
  FROM conversations c
  JOIN listings l ON c.listing_id = l.id
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
      LEFT(NEW.content, 100), -- Limitar a 100 caracteres
      jsonb_build_object(
        'conversationId', NEW.conversation_id,
        'messageId', NEW.id,
        'senderId', NEW.sender_id,
        'listingTitle', listing_title
      ),
      sender_avatar
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para nuevos mensajes
DROP TRIGGER IF EXISTS on_new_message_notification ON messages;
CREATE TRIGGER on_new_message_notification
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION create_message_notification();

-- =====================================================
-- FUNCIÓN: Crear notificación de nueva publicación
-- =====================================================
-- Se ejecuta cuando se crea una nueva publicación
-- Solo notifica a usuarios que tengan preferencias similares
-- (Por ahora notifica a todos, se puede filtrar después)

CREATE OR REPLACE FUNCTION create_listing_notification()
RETURNS TRIGGER AS $$
DECLARE
  listing_image TEXT;
BEGIN
  -- Obtener primera imagen del listing
  listing_image := NEW.image_urls->>0;
  
  -- Notificar a usuarios que podrían estar interesados
  -- Por ahora: usuarios que hayan buscado en la misma ciudad
  -- (Se puede mejorar con sistema de preferencias)
  INSERT INTO notifications (user_id, type, title, body, data, image_url)
  SELECT 
    p.id,
    'new_listing',
    'Nueva publicación disponible',
    NEW.title || ' - $' || NEW.price || '/mes en ' || COALESCE(NEW.city, 'tu zona'),
    jsonb_build_object(
      'listingId', NEW.id,
      'title', NEW.title,
      'price', NEW.price,
      'city', NEW.city
    ),
    listing_image
  FROM profiles p
  WHERE p.id != NEW.user_id
    -- Filtro básico: usuarios con ciudad similar en su perfil
    -- Esto se puede mejorar con una tabla de preferencias
    AND (
      p.city IS NULL -- Si no tiene ciudad, notificar
      OR p.city = NEW.city -- O si coincide con la del listing
    )
  LIMIT 100; -- Limitar para evitar spam masivo
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para nuevas publicaciones
DROP TRIGGER IF EXISTS on_new_listing_notification ON listings;
CREATE TRIGGER on_new_listing_notification
  AFTER INSERT ON listings
  FOR EACH ROW
  EXECUTE FUNCTION create_listing_notification();

-- =====================================================
-- FUNCIÓN: Limpiar notificaciones antiguas
-- =====================================================
-- Elimina notificaciones leídas con más de 30 días

CREATE OR REPLACE FUNCTION cleanup_old_notifications()
RETURNS void AS $$
BEGIN
  DELETE FROM notifications
  WHERE is_read = TRUE
    AND created_at < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- PERMISOS PARA REALTIME
-- =====================================================

ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
