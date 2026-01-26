-- 1. Create Subscription Tier Enum
-- We use an enum to ensure data integrity for plan types
CREATE TYPE subscription_tier AS ENUM ('free', 'pro', 'business');

-- 2. Extend Profiles Table
-- Adding columns to track subscription status without breaking existing data
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS subscription_tier subscription_tier DEFAULT 'free',
ADD COLUMN IF NOT EXISTS subscription_active BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS contracts_count INTEGER DEFAULT 0;

-- 3. Security Policies (RLS)
-- Crucial: Users should NOT be able to update their own subscription status directly.
-- Only the system (service_role) or specific backend functions should update these.

-- Ensure RLS is enabled (it should be already, but good practice)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own subscription data
-- (This likely already exists via a generic "read own profile" policy, 
-- but we ensure these specific columns are readable if we had column-level security, 
-- which Supabase doesn't enforce by default on SELECT, so the existing SELECT policy covers this).

-- Policy: Protect Subscription Fields from User Updates
-- We need to ensure that the generic "Users can update own profile" policy 
-- doesn't allow changing these sensitive fields.
-- Since Supabase/Postgres policies are permissive (OR logic), if there is an existing 
-- "UPDATE" policy for the user, they might be able to change these columns.
-- To strictly prevent this, we would typically use a Trigger or separate table.
-- However, for this implementation, we will rely on the frontend not exposing these fields 
-- and backend functions (Edge Functions) using service_role for upgrades.

-- Ideally, we would create a trigger to prevent updates to these columns by non-service_role users.
CREATE OR REPLACE FUNCTION prevent_subscription_tampering()
RETURNS TRIGGER AS $$
BEGIN
  -- If the user is not a service_role (superuser/admin context)
  IF (auth.role() = 'authenticated') THEN
    -- Check if sensitive fields are being modified
    IF (NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier) OR
       (NEW.subscription_active IS DISTINCT FROM OLD.subscription_active) OR
       (NEW.contracts_count IS DISTINCT FROM OLD.contracts_count) THEN
      RAISE EXCEPTION 'You are not allowed to modify subscription data directly.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to profiles
DROP TRIGGER IF EXISTS protect_subscription_fields ON profiles;
CREATE TRIGGER protect_subscription_fields
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION prevent_subscription_tampering();

-- 4. Comments for Documentation
COMMENT ON COLUMN profiles.subscription_tier IS 'Current subscription plan (free, pro, business)';
COMMENT ON COLUMN profiles.subscription_active IS 'Whether the subscription is currently valid';
COMMENT ON COLUMN profiles.contracts_count IS 'Number of active contracts managed by this user (for plan limits)';
