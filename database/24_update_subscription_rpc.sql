-- Function to safely update subscription tier
-- This function is SECURITY DEFINER, meaning it runs with the privileges of the creator (postgres/admin),
-- allowing it to bypass the 'prevent_subscription_tampering' trigger restrictions if we adjust the trigger 
-- or simply because it's a trusted function.
-- However, our trigger checks "IF (auth.role() = 'authenticated')". 
-- SECURITY DEFINER functions usually run as the owner. If the owner is a superuser, it might still trigger if not careful,
-- but typically we use this pattern to encapsulate logic.

-- Actually, to properly bypass the trigger which specifically blocks 'authenticated' role updates:
-- We can either:
-- 1. Modify the trigger to allow updates if a specific context variable is set.
-- 2. Use a function that runs as 'service_role' (which isn't a standard Postgres role but a Supabase concept).
--    In standard Postgres, SECURITY DEFINER runs as the function owner.

CREATE OR REPLACE FUNCTION update_subscription_tier(
  new_tier subscription_tier
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- Runs with privileges of the creator (admin)
SET search_path = public -- Secure search path
AS $$
DECLARE
  v_user_id uuid;
  v_max_contracts int;
BEGIN
  -- Get current user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Determine max contracts based on tier (simple logic here or fetch from a config table)
  -- For now, hardcoded to match Domain logic to ensure DB consistency
  CASE new_tier
    WHEN 'free' THEN v_max_contracts := 1;
    WHEN 'pro' THEN v_max_contracts := 5;
    WHEN 'business' THEN v_max_contracts := 999;
  END CASE;

  -- Update the profile
  -- We temporarily disable the trigger for this transaction if needed, 
  -- OR we rely on the fact that we are running as the owner (if owner is not 'authenticated').
  -- But since our trigger checks auth.role(), which remains 'authenticated' even in SECURITY DEFINER 
  -- (unless we change it, which is complex), a better approach for the trigger is:
  -- "IF (auth.role() = 'authenticated' AND current_setting('app.is_admin', true) IS DISTINCT FROM 'true')"
  
  -- Let's try a simpler approach: 
  -- The trigger `prevent_subscription_tampering` raises exception if `auth.role() = 'authenticated'`.
  -- We can set a session variable to bypass it.
  
  PERFORM set_config('app.bypass_subscription_trigger', 'true', true);
  
  UPDATE profiles
  SET 
    subscription_tier = new_tier,
    subscription_active = true, -- Auto-activate for now
    contracts_count = (SELECT count(*) FROM rent_contracts WHERE host_id = v_user_id AND status = 'active'), -- Recalculate to be safe
    updated_at = now()
  WHERE id = v_user_id;
  
  -- Reset config (optional as it is local to transaction with third param 'true')
  -- PERFORM set_config('app.bypass_subscription_trigger', '', true);
  
END;
$$;

-- We need to update the trigger function to respect this bypass
CREATE OR REPLACE FUNCTION prevent_subscription_tampering()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if we should bypass (e.g. called from our secure function)
  IF current_setting('app.bypass_subscription_trigger', true) = 'true' THEN
    RETURN NEW;
  END IF;

  -- If the user is not a service_role (superuser/admin context)
  IF (auth.role() = 'authenticated') THEN
    -- Check if sensitive fields are being modified
    IF (NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier) OR
       (NEW.subscription_active IS DISTINCT FROM OLD.subscription_active) OR
       (NEW.contracts_count IS DISTINCT FROM OLD.contracts_count) THEN
      RAISE EXCEPTION 'You are not allowed to modify subscription data directly. Use the official upgrade flow.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
