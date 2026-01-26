-- =====================================================
-- Fix: Add foreign keys to profiles for rent_contracts
-- This allows PostgREST to find the relationship profiles!host_id
-- =====================================================

-- 1. Add FK for host_id referencing profiles
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'rent_contracts_host_id_fkey_profiles') THEN
        ALTER TABLE public.rent_contracts
        ADD CONSTRAINT rent_contracts_host_id_fkey_profiles
        FOREIGN KEY (host_id)
        REFERENCES public.profiles(id)
        ON DELETE CASCADE;
    END IF;
END $$;

-- 2. Add FK for roomie_id referencing profiles
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'rent_contracts_roomie_id_fkey_profiles') THEN
        ALTER TABLE public.rent_contracts
        ADD CONSTRAINT rent_contracts_roomie_id_fkey_profiles
        FOREIGN KEY (roomie_id)
        REFERENCES public.profiles(id)
        ON DELETE CASCADE;
    END IF;
END $$;

-- Note: Since profiles.id is a FK to auth.users.id, and rent_contracts.host_id was already a FK to auth.users.id,
-- this creates a redundant path but is necessary for PostgREST to "see" the relationship to profiles directly.
