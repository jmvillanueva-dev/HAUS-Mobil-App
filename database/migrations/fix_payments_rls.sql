-- =====================================================
-- Fix: RLS Policies for rent_payments
-- Allows users to INSERT and UPDATE payments for their contracts
-- =====================================================

-- 1. Allow INSERT for authenticated users who are part of the contract
DROP POLICY IF EXISTS "Users can insert payments for their contracts" ON public.rent_payments;
CREATE POLICY "Users can insert payments for their contracts"
ON public.rent_payments FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.rent_contracts c
    WHERE c.id = contract_id
    AND (c.host_id = auth.uid() OR c.roomie_id = auth.uid())
  )
);

-- 2. Allow UPDATE for authenticated users who are part of the contract
DROP POLICY IF EXISTS "Users can update payments for their contracts" ON public.rent_payments;
CREATE POLICY "Users can update payments for their contracts"
ON public.rent_payments FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.rent_contracts c
    WHERE c.id = contract_id
    AND (c.host_id = auth.uid() OR c.roomie_id = auth.uid())
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.rent_contracts c
    WHERE c.id = contract_id
    AND (c.host_id = auth.uid() OR c.roomie_id = auth.uid())
  )
);
