-- =====================================================
-- HAUS - Políticas RLS para Chat
-- Ejecutar DESPUÉS de 05_chat.sql
-- =====================================================

-- =====================================================
-- HABILITAR ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS PARA TABLA: conversations
-- =====================================================

-- Eliminar políticas existentes para evitar conflictos
DROP POLICY IF EXISTS "Users can view own conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can create conversations" ON public.conversations;
DROP POLICY IF EXISTS "Service role can manage all conversations" ON public.conversations;

-- 1. SELECT: Solo participantes pueden ver sus conversaciones
CREATE POLICY "Users can view own conversations" 
ON public.conversations 
FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id OR auth.uid() = host_id);

-- 2. INSERT: Solo el usuario buscador puede crear conversaciones
--    (El host no inicia conversaciones, responde a las existentes)
CREATE POLICY "Users can create conversations" 
ON public.conversations 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- 3. Service role puede gestionar todas las conversaciones (admin)
CREATE POLICY "Service role can manage all conversations" 
ON public.conversations 
FOR ALL 
TO service_role
USING (true)
WITH CHECK (true);

-- =====================================================
-- POLÍTICAS PARA TABLA: messages
-- =====================================================

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "Participants can view messages" ON public.messages;
DROP POLICY IF EXISTS "Participants can send messages" ON public.messages;
DROP POLICY IF EXISTS "Participants can mark messages as read" ON public.messages;
DROP POLICY IF EXISTS "Service role can manage all messages" ON public.messages;

-- 1. SELECT: Solo participantes de la conversación pueden ver mensajes
CREATE POLICY "Participants can view messages" 
ON public.messages 
FOR SELECT 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM public.conversations c 
    WHERE c.id = conversation_id 
    AND (c.user_id = auth.uid() OR c.host_id = auth.uid())
  )
);

-- 2. INSERT: Solo participantes pueden enviar mensajes en sus conversaciones
CREATE POLICY "Participants can send messages" 
ON public.messages 
FOR INSERT 
TO authenticated 
WITH CHECK (
  -- El sender debe ser el usuario autenticado
  auth.uid() = sender_id
  AND
  -- Y debe ser participante de la conversación
  EXISTS (
    SELECT 1 FROM public.conversations c 
    WHERE c.id = conversation_id 
    AND (c.user_id = auth.uid() OR c.host_id = auth.uid())
  )
);

-- 3. UPDATE: Solo el receptor puede marcar mensajes como leídos
CREATE POLICY "Participants can mark messages as read" 
ON public.messages 
FOR UPDATE 
TO authenticated 
USING (
  -- Debe ser participante de la conversación
  EXISTS (
    SELECT 1 FROM public.conversations c 
    WHERE c.id = conversation_id 
    AND (c.user_id = auth.uid() OR c.host_id = auth.uid())
  )
)
WITH CHECK (
  -- Solo puede marcar como leídos los mensajes que NO envió
  sender_id != auth.uid()
);

-- 4. Service role puede gestionar todos los mensajes (admin)
CREATE POLICY "Service role can manage all messages" 
ON public.messages 
FOR ALL 
TO service_role
USING (true)
WITH CHECK (true);

-- =====================================================
-- VERIFICACIÓN DE POLÍTICAS
-- =====================================================

-- Consulta para verificar que las políticas se crearon correctamente
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check 
-- FROM pg_policies 
-- WHERE schemaname = 'public' AND tablename IN ('conversations', 'messages');
