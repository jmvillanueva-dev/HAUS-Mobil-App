-- =====================================================
-- HAUS - Sistema de Solicitudes de Listings
-- =====================================================

CREATE TABLE IF NOT EXISTS public.listing_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Listing al que se aplica
  listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
  
  -- Usuario que solicita
  requester_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Dueño del listing (Host) - redundante pero útil para consultas rápidas y permisos
  host_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Estado de la solicitud
  status TEXT NOT NULL CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')) DEFAULT 'pending',
  
  -- Mensaje opcional
  message TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  
  -- Restricción: Un usuario solo puede tener una solicitud activa por listing
  CONSTRAINT unique_active_request UNIQUE(listing_id, requester_id)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_requests_host ON public.listing_requests(host_id);
CREATE INDEX IF NOT EXISTS idx_requests_requester ON public.listing_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_requests_listing ON public.listing_requests(listing_id);
CREATE INDEX IF NOT EXISTS idx_requests_status ON public.listing_requests(status);

-- =====================================================
-- RLS POLICIES
-- =====================================================

ALTER TABLE public.listing_requests ENABLE ROW LEVEL SECURITY;

-- Requester: Ver sus propias solicitudes
CREATE POLICY "Users can view own requests"
  ON public.listing_requests FOR SELECT
  TO authenticated
  USING (auth.uid() = requester_id);

-- Host: Ver solicitudes recibidas
CREATE POLICY "Hosts can view received requests"
  ON public.listing_requests FOR SELECT
  TO authenticated
  USING (auth.uid() = host_id);
  
-- Requester: Crear solicitud
CREATE POLICY "Users can create requests"
  ON public.listing_requests FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = requester_id);

-- Host: Actualizar estado (Aprobar/Rechazar)
CREATE POLICY "Hosts can update requests"
  ON public.listing_requests FOR UPDATE
  TO authenticated
  USING (auth.uid() = host_id);
  
-- Requester: Cancelar (Actualizar)
CREATE POLICY "Requesters can update requests"
  ON public.listing_requests FOR UPDATE
  TO authenticated
  USING (auth.uid() = requester_id);

-- =====================================================
-- PUBLICACIÓN REALTIME
-- =====================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.listing_requests;

COMMENT ON TABLE public.listing_requests IS 'Solicitudes de usuarios interesados en un listing';
