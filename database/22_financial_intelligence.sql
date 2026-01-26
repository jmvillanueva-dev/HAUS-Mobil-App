-- =====================================================
-- HAUS - Fase 1: Inteligencia Financiera
-- =====================================================

-- 1. Modificación de la Tabla profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS subscription_tier TEXT DEFAULT 'free',
ADD COLUMN IF NOT EXISTS billing_balance NUMERIC DEFAULT 0;

-- 2. Creación de la Tabla rent_contracts
CREATE TABLE IF NOT EXISTS public.rent_contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES public.listings(id) NOT NULL,
  host_id UUID REFERENCES auth.users(id) NOT NULL,
  roomie_id UUID REFERENCES auth.users(id) NOT NULL,
  monthly_rent NUMERIC NOT NULL,
  payment_day INTEGER CHECK (payment_day BETWEEN 1 AND 31) DEFAULT 1,
  status TEXT CHECK (status IN ('active', 'terminated')) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Índices para rent_contracts
CREATE INDEX IF NOT EXISTS idx_contracts_host ON public.rent_contracts(host_id);
CREATE INDEX IF NOT EXISTS idx_contracts_roomie ON public.rent_contracts(roomie_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON public.rent_contracts(status);

-- 3. Creación de la Tabla rent_payments
CREATE TABLE IF NOT EXISTS public.rent_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES public.rent_contracts(id) ON DELETE CASCADE NOT NULL,
  due_date DATE NOT NULL,
  status TEXT CHECK (status IN ('pending', 'paid', 'overdue')) DEFAULT 'pending',
  gross_amount NUMERIC NOT NULL, -- Renta total
  platform_fee NUMERIC NOT NULL, -- Comisión (5%)
  net_amount NUMERIC NOT NULL,   -- Lo que recibe el host
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Índices para rent_payments
CREATE INDEX IF NOT EXISTS idx_payments_contract ON public.rent_payments(contract_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.rent_payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_due_date ON public.rent_payments(due_date);

-- 4. Trigger SQL Automático
-- Función que se ejecuta cuando se aprueba una solicitud
CREATE OR REPLACE FUNCTION public.handle_approved_listing_request()
RETURNS TRIGGER AS $$
DECLARE
  v_monthly_rent NUMERIC;
BEGIN
  -- Obtener el precio del listing
  SELECT price INTO v_monthly_rent FROM public.listings WHERE id = NEW.listing_id;

  -- Si no se encuentra el precio (caso raro), usar 0 o lanzar error. Usamos 0 por seguridad.
  IF v_monthly_rent IS NULL THEN
    v_monthly_rent := 0;
  END IF;

  -- Insertar el contrato automáticamente
  INSERT INTO public.rent_contracts (
    listing_id, 
    host_id, 
    roomie_id, 
    monthly_rent, 
    payment_day, 
    status
  )
  VALUES (
    NEW.listing_id,
    NEW.host_id,
    NEW.requester_id,
    v_monthly_rent,
    EXTRACT(DAY FROM now()), -- El día de pago será el día actual del mes
    'active'
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que dispara la función
DROP TRIGGER IF EXISTS on_listing_request_approved ON public.listing_requests;

CREATE TRIGGER on_listing_request_approved
AFTER UPDATE OF status ON public.listing_requests
FOR EACH ROW
WHEN (OLD.status <> 'approved' AND NEW.status = 'approved')
EXECUTE FUNCTION public.handle_approved_listing_request();

-- =====================================================
-- RLS POLICIES (Seguridad Básica)
-- =====================================================

ALTER TABLE public.rent_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rent_payments ENABLE ROW LEVEL SECURITY;

-- Contracts: Hosts y Roomies pueden ver sus propios contratos
CREATE POLICY "Users can view own contracts"
  ON public.rent_contracts FOR SELECT
  TO authenticated
  USING (auth.uid() = host_id OR auth.uid() = roomie_id);

-- Payments: Hosts y Roomies pueden ver sus propios pagos (a través del contrato)
CREATE POLICY "Users can view own payments"
  ON public.rent_payments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.rent_contracts c
      WHERE c.id = rent_payments.contract_id
      AND (c.host_id = auth.uid() OR c.roomie_id = auth.uid())
    )
  );
