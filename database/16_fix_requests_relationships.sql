-- =====================================================
-- FIX: Relaciones de Listing Requests con Profiles
-- Add foreign key constraints to public.profiles to enable PostgREST joins
-- =====================================================

-- Add FK for requester_id pointing to public.profiles
ALTER TABLE public.listing_requests
DROP CONSTRAINT IF EXISTS listing_requests_requester_id_fkey, -- delete old if implies auth.users only
ADD CONSTRAINT listing_requests_requester_id_fkey_profiles
FOREIGN KEY (requester_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Add FK for host_id pointing to public.profiles
ALTER TABLE public.listing_requests
DROP CONSTRAINT IF EXISTS listing_requests_host_id_fkey,
ADD CONSTRAINT listing_requests_host_id_fkey_profiles
FOREIGN KEY (host_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Note: Since public.profiles.id is a FK to auth.users.id, referential integrity to auth.users is still maintained indirectly or we can keep both if DB supports multiple FKs on same column (it does).
-- But typically we change the main reference or add a secondary one.
-- PostgREST needs the FK to the table we want to join (profiles).

-- COMMENT indicating the relationship for clarity
COMMENT ON CONSTRAINT listing_requests_requester_id_fkey_profiles ON public.listing_requests IS 'Link to public.profiles for easy joining';
