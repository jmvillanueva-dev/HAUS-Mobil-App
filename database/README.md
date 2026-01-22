# RoomieMatch - Scripts de Base de Datos

## Orden de Ejecución

Ejecutar los scripts en el **SQL Editor de Supabase** en el siguiente orden:

1. `00_init_extensions.sql` - Habilita extensiones necesarias
2. `01_auth_schema.sql` - Crea tabla `profiles` y triggers
3. `02_user_locations.sql` - Crea tabla `user_locations`
4. `RLS_policies.sql` - Aplica políticas de seguridad (**OBLIGATORIO**)

## Verificación

Después de ejecutar todos los scripts, verifica con:

```sql
-- Ver políticas RLS creadas
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE schemaname = 'public';

-- Verificar estructura de tablas
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'profiles';
```

## Prueba del Trigger

Para verificar que el trigger funciona:

1. Registra un nuevo usuario desde la app
2. Verifica que se creó la entrada en `profiles`:

```sql
SELECT * FROM public.profiles ORDER BY created_at DESC LIMIT 1;
```

## Notas Importantes

- ⚠️ **RLS es obligatorio**: Sin las políticas RLS, los datos son vulnerables
- El trigger `on_auth_user_created` crea automáticamente el perfil al registrarse
- El campo `status` inicia como `'unverified'` por defecto
