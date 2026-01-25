-- =====================================================
-- FIX: Listing Requests Issues
-- 1. Backfill missing profiles (essential for FK constraints)
-- 2. Cleanup potentially bad triggers on listing_requests
-- 3. Verify policies
-- =====================================================

-- 1. BACKFILL MISSING PROFILES
-- Insert profiles for users that exist in auth.users but not in public.profiles
INSERT INTO public.profiles (id, first_name, last_name, role)
SELECT 
  au.id, 
  COALESCE(au.raw_user_meta_data->>'first_name', 'Usuario'), 
  COALESCE(au.raw_user_meta_data->>'last_name', ''),
  'worker'::user_role -- Default safety fallback
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE p.id IS NULL;

-- Note: 'role' column in profiles might need casting if raw_user_meta_data has it.
-- We use default 'worker' here to be safe and avoid enum errors.
-- If you strictly need the role from metadata:
-- CASE WHEN au.raw_user_meta_data->>'role' = 'student' THEN 'student'::user_role ELSE 'worker'::user_role END

-- 2. CLEANUP POTENTIAL BAD TRIGGERS
-- Drop triggers that might be blocking insertion on listing_requests
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT trigger_name 
        FROM information_schema.triggers 
        WHERE event_object_table = 'listing_requests'
        AND trigger_schema = 'public'
    LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || quote_ident(t) || ' ON public.listing_requests CASCADE';
    END LOOP;
END $$;

-- 3. RE-VERIFY POLICIES (Make sure they are permissive enough for basic functionality)
DROP POLICY IF EXISTS "Users can create requests" ON public.listing_requests;
CREATE POLICY "Users can create requests"
  ON public.listing_requests FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = requester_id);

-- Ensure RLS is enabled
ALTER TABLE public.listing_requests ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- 1. Crear la tabla de solicitudes si no existe
CREATE TABLE IF NOT EXISTS public.listing_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
  requester_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  host_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL, -- IMPORTANTE: Necesario para que el dueño la vea
  status TEXT NOT NULL CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')) DEFAULT 'pending',
  message TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  
  -- Evitar duplicados: Un usuario solo puede enviar una solicitud por habitación
  CONSTRAINT unique_active_request UNIQUE(listing_id, requester_id)
);

-- 2. Habilitar seguridad (RLS)
ALTER TABLE public.listing_requests ENABLE ROW LEVEL SECURITY;

-- 3. Políticas de Seguridad (CRUCIAL para que "lleguen" las solicitudes)

-- El que envía (Requester) puede crear la solicitud
DROP POLICY IF EXISTS "Users can create requests" ON public.listing_requests;
CREATE POLICY "Users can create requests"
  ON public.listing_requests FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = requester_id);

-- El que envía puede ver sus propias solicitudes
DROP POLICY IF EXISTS "Users can view own requests" ON public.listing_requests;
CREATE POLICY "Users can view own requests"
  ON public.listing_requests FOR SELECT
  TO authenticated
  USING (auth.uid() = requester_id);

-- El dueño (Host) puede ver las solicitudes que le envían
DROP POLICY IF EXISTS "Hosts can view received requests" ON public.listing_requests;
CREATE POLICY "Hosts can view received requests"
  ON public.listing_requests FOR SELECT
  TO authenticated
  USING (auth.uid() = host_id);

-- El dueño puede aprobar/rechazar (Update)
DROP POLICY IF EXISTS "Hosts can update requests" ON public.listing_requests;
CREATE POLICY "Hosts can update requests"
  ON public.listing_requests FOR UPDATE
  TO authenticated
  USING (auth.uid() = host_id);
