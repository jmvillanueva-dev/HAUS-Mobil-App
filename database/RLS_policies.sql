-- =====================================================
-- RoomieMatch - Políticas de Seguridad (RLS)
-- Ejecutar DESPUÉS de crear todas las tablas
-- =====================================================

-- =====================================================
-- HABILITAR ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_locations ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS PARA TABLA: profiles
-- =====================================================

-- Eliminar políticas existentes para evitar conflictos
DROP POLICY IF EXISTS "Profiles are viewable by authenticated users" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Service role can manage all profiles" ON public.profiles;

-- 1. SELECT: Usuarios autenticados pueden ver todos los perfiles
--    (Necesario para buscar roomies compatibles)
CREATE POLICY "Profiles are viewable by authenticated users" 
ON public.profiles 
FOR SELECT 
TO authenticated 
USING (true);

-- 2. INSERT: Solo el usuario puede insertar su propio perfil
--    (Normalmente lo hace el trigger, pero por si acaso)
CREATE POLICY "Users can insert their own profile" 
ON public.profiles 
FOR INSERT 
TO authenticated
WITH CHECK (auth.uid() = id);

-- 3. UPDATE: Solo el usuario puede actualizar su propio perfil
CREATE POLICY "Users can update their own profile" 
ON public.profiles 
FOR UPDATE 
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- 4. Service role puede gestionar todos los perfiles (para admin/moderación)
CREATE POLICY "Service role can manage all profiles" 
ON public.profiles 
FOR ALL 
TO service_role
USING (true)
WITH CHECK (true);

-- =====================================================
-- POLÍTICAS PARA TABLA: user_locations
-- =====================================================

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "Locations viewable by authenticated users" ON public.user_locations;
DROP POLICY IF EXISTS "Users can insert their own locations" ON public.user_locations;
DROP POLICY IF EXISTS "Users can update their own locations" ON public.user_locations;
DROP POLICY IF EXISTS "Users can delete their own locations" ON public.user_locations;
DROP POLICY IF EXISTS "Service role can manage all locations" ON public.user_locations;

-- 1. SELECT: Usuarios autenticados pueden ver ubicaciones
--    NOTA: En producción, podrías limitar esto a solo usuarios verificados
CREATE POLICY "Locations viewable by authenticated users" 
ON public.user_locations 
FOR SELECT 
TO authenticated 
USING (true);

-- 2. INSERT: Usuarios pueden agregar sus propias ubicaciones
CREATE POLICY "Users can insert their own locations" 
ON public.user_locations 
FOR INSERT 
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- 3. UPDATE: Usuarios pueden actualizar sus propias ubicaciones
CREATE POLICY "Users can update their own locations" 
ON public.user_locations 
FOR UPDATE 
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 4. DELETE: Usuarios pueden eliminar sus propias ubicaciones
CREATE POLICY "Users can delete their own locations" 
ON public.user_locations 
FOR DELETE 
TO authenticated
USING (auth.uid() = user_id);

-- 5. Service role puede gestionar todas las ubicaciones
CREATE POLICY "Service role can manage all locations" 
ON public.user_locations 
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
-- WHERE schemaname = 'public';
