-- =====================================================
-- Trigger: Update Host Balance on Payment
-- Increases profiles.billing_balance when a payment is marked as 'paid'
-- =====================================================

CREATE OR REPLACE FUNCTION public.update_host_balance()
RETURNS TRIGGER AS $$
DECLARE
  v_host_id UUID;
BEGIN
  -- Only proceed if status changed to 'paid'
  IF (NEW.status = 'paid' AND (OLD.status IS DISTINCT FROM 'paid')) THEN
    
    -- Get the host_id from the contract
    SELECT host_id INTO v_host_id 
    FROM public.rent_contracts 
    WHERE id = NEW.contract_id;

    -- Update the host's profile balance
    UPDATE public.profiles
    SET 
      billing_balance = COALESCE(billing_balance, 0) + NEW.net_amount,
      updated_at = now()
    WHERE id = v_host_id;

  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
DROP TRIGGER IF EXISTS on_rent_payment_paid ON public.rent_payments;

CREATE TRIGGER on_rent_payment_paid
AFTER UPDATE OF status ON public.rent_payments
FOR EACH ROW
EXECUTE FUNCTION public.update_host_balance();
