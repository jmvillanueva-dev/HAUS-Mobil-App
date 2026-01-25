-- Function to check if a listing is available
-- Returns true if there are NO approved requests for the listing
CREATE OR REPLACE FUNCTION public.is_available(rec public.listings)
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
  SELECT NOT EXISTS (
    SELECT 1
    FROM public.listing_requests
    WHERE listing_id = rec.id
    AND status = 'approved'
  );
$$;
