-- 00_init_extensions.sql

-- =====================================================
-- RoomieMatch - Extensiones de Base de Datos
-- Ejecutar primero en Supabase SQL Editor
-- =====================================================

-- UUID para generar IDs únicos (generalmente ya está habilitado en Supabase)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- PostGIS para geolocalización (descomentar cuando se implemente el módulo de mapas)
-- CREATE EXTENSION IF NOT EXISTS postgis;
