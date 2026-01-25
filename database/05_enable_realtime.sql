-- 05_enable_realtime.sql

-- Habilitar la publicación supabase_realtime para la tabla listings
-- Esto es necesario para que la aplicación reciba actualizaciones en vivo (streams)
alter publication supabase_realtime add table listings;

-- Nota: Si tienes otras tablas que requieren realtime, también debes agregarlas así.
-- Por ejemplo:
-- alter publication supabase_realtime add table profiles;
