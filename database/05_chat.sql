-- =====================================================
-- HAUS - Sistema de Chat en Tiempo Real
-- Ejecutar después de 03_listing.sql
-- =====================================================

-- =====================================================
-- TABLA: conversations
-- Almacena las conversaciones entre usuarios sobre un listing específico
-- =====================================================

CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  
  -- Listing asociado a la conversación
  listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
  
  -- Usuario que busca habitación (inicia la conversación)
  -- Referencia a profiles para permitir JOINs con datos del perfil
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  
  -- Dueño/anfitrión del listing
  host_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  
  -- Timestamp del último mensaje (para ordenar conversaciones)
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  -- Restricción: Solo una conversación por usuario/listing
  CONSTRAINT unique_conversation_per_listing UNIQUE(listing_id, user_id)
);

-- Índices para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_conversations_user ON public.conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_host ON public.conversations(host_id);
CREATE INDEX IF NOT EXISTS idx_conversations_listing ON public.conversations(listing_id);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message ON public.conversations(last_message_at DESC);

-- =====================================================
-- TABLA: messages
-- Almacena los mensajes individuales de cada conversación
-- =====================================================

CREATE TABLE IF NOT EXISTS public.messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  
  -- Conversación a la que pertenece el mensaje
  conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE NOT NULL,
  
  -- Usuario que envía el mensaje (referencia a profiles para JOINs)
  sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  
  -- Contenido del mensaje
  content TEXT NOT NULL,
  
  -- Estado de lectura
  is_read BOOLEAN DEFAULT FALSE,
  
  -- Timestamp
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Índices para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_created ON public.messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON public.messages(sender_id);

-- =====================================================
-- FUNCIÓN: Actualizar last_message_at automáticamente
-- =====================================================

CREATE OR REPLACE FUNCTION public.update_conversation_last_message()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.conversations 
  SET last_message_at = NEW.created_at
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$;

-- Trigger para actualizar last_message_at al insertar mensaje
DROP TRIGGER IF EXISTS on_message_created ON public.messages;

CREATE TRIGGER on_message_created
  AFTER INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.update_conversation_last_message();

-- =====================================================
-- HABILITAR REALTIME
-- =====================================================

-- Habilitar Realtime para mensajes (para chat en tiempo real)
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE public.conversations IS 'Conversaciones de chat entre usuarios sobre listings específicos';
COMMENT ON COLUMN public.conversations.listing_id IS 'Listing/propiedad sobre la que se está conversando';
COMMENT ON COLUMN public.conversations.user_id IS 'Usuario que busca habitación (inicia el chat)';
COMMENT ON COLUMN public.conversations.host_id IS 'Dueño/anfitrión del listing';
COMMENT ON COLUMN public.conversations.last_message_at IS 'Timestamp del último mensaje para ordenar conversaciones';

COMMENT ON TABLE public.messages IS 'Mensajes individuales dentro de cada conversación';
COMMENT ON COLUMN public.messages.conversation_id IS 'Conversación a la que pertenece el mensaje';
COMMENT ON COLUMN public.messages.sender_id IS 'Usuario que envió el mensaje';
COMMENT ON COLUMN public.messages.is_read IS 'Indica si el mensaje fue leído por el receptor';
