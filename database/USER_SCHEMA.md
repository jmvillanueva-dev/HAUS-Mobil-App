# HAUS - Esquema de Usuario

Documentación completa del esquema de usuario en la base de datos Supabase.

---

## 📋 Tabla `profiles`

Tabla principal que extiende `auth.users` de Supabase con información adicional del perfil.

### Campos Actuales

| Campo                   | Tipo      | Nullable | Default      | Descripción                                |
| ----------------------- | --------- | -------- | ------------ | ------------------------------------------ |
| `id`                    | UUID      | NO       | -            | Primary Key, referencia a `auth.users(id)` |
| `first_name`            | TEXT      | SI       | NULL         | Nombre del usuario                         |
| `last_name`             | TEXT      | SI       | NULL         | Apellido del usuario                       |
| `phone`                 | TEXT      | SI       | NULL         | Número de teléfono                         |
| `avatar_url`            | TEXT      | SI       | NULL         | URL de la foto de perfil                   |
| `bio`                   | TEXT      | SI       | NULL         | Biografía/descripción personal             |
| `role`                  | ENUM      | NO       | 'worker'     | Rol: `student` o `worker`                  |
| `status`                | ENUM      | NO       | 'unverified' | Estado de verificación                     |
| `university_or_company` | TEXT      | SI       | NULL         | Universidad o empresa                      |
| `verification_doc_url`  | TEXT      | SI       | NULL         | URL del documento de verificación          |
| `onboarding_completed`  | BOOLEAN   | NO       | false        | Indica si completó el onboarding           |
| `created_at`            | TIMESTAMP | NO       | now()        | Fecha de creación                          |
| `updated_at`            | TIMESTAMP | NO       | now()        | Última actualización                       |

---

## 🏷️ ENUMs

### `user_role`

Rol del usuario en la plataforma.

| Valor     | Descripción              |
| --------- | ------------------------ |
| `student` | Estudiante universitario |
| `worker`  | Trabajador/profesional   |

### `verification_status`

Estado del proceso de verificación de identidad.

| Valor        | Descripción                    |
| ------------ | ------------------------------ |
| `unverified` | Sin verificar (estado inicial) |
| `pending`    | Verificación en proceso        |
| `verified`   | Identidad verificada ✅        |
| `rejected`   | Verificación rechazada ❌      |

---

## ⚙️ Triggers Automáticos

### `on_auth_user_created`

- **Evento:** Después de INSERT en `auth.users`
- **Acción:** Crea automáticamente un registro en `profiles`
- **Datos iniciales:** `id`, `first_name`, `last_name`, `role` (desde metadata)

### `on_profile_updated`

- **Evento:** Antes de UPDATE en `profiles`
- **Acción:** Actualiza automáticamente `updated_at`

---

## 🔐 Políticas RLS (Row Level Security)

| Operación | Quién puede           | Condición                                 |
| --------- | --------------------- | ----------------------------------------- |
| SELECT    | Usuarios autenticados | Todos los perfiles                        |
| INSERT    | Usuario autenticado   | Solo su propio perfil (`auth.uid() = id`) |
| UPDATE    | Usuario autenticado   | Solo su propio perfil (`auth.uid() = id`) |
| ALL       | Service Role          | Sin restricciones                         |

---

## 📍 Tabla Relacionada: `user_locations`

Ubicaciones guardadas por el usuario.

| Campo          | Tipo      | Descripción                                     |
| -------------- | --------- | ----------------------------------------------- |
| `id`           | UUID      | Primary Key                                     |
| `user_id`      | UUID      | FK → `auth.users(id)`                           |
| `label`        | TEXT      | Tipo: `home`, `work`, `university`, `other`     |
| `purpose`      | ENUM      | `search` (buscar roomie) o `listing` (publicar) |
| `address`      | TEXT      | Dirección completa                              |
| `city`         | TEXT      | Ciudad                                          |
| `neighborhood` | TEXT      | Barrio/colonia                                  |
| `latitude`     | DOUBLE    | Coordenada latitud                              |
| `longitude`    | DOUBLE    | Coordenada longitud                             |
| `is_primary`   | BOOLEAN   | Ubicación principal para recomendaciones        |
| `created_at`   | TIMESTAMP | Fecha de creación                               |
| `updated_at`   | TIMESTAMP | Última actualización                            |

---

## 🔗 Modelo Flutter

Los campos de la base de datos están mapeados en:

- **Entity:** `lib/features/auth/domain/entities/user_entity.dart`
- **Model:** `lib/features/auth/data/models/user_model.dart`

### Propiedades Computadas

| Propiedad               | Descripción                                  |
| ----------------------- | -------------------------------------------- |
| `displayName`           | Nombre completo o email si no hay nombre     |
| `isProfileComplete`     | `true` si tiene `first_name` y `last_name`   |
| `isVerified`            | `true` si `status == verified`               |
| `isVerificationPending` | `true` si `status == pending`                |
| `onboardingCompleted`   | `true` si completó el onboarding obligatorio |

---

## Storage Buckets

### `avatars`

Bucket para almacenar fotos de perfil de usuarios.

| Propiedad | Valor                                |
| --------- | ------------------------------------ |
| Público   | Sí                                   |
| Path      | `{user_id}/avatar_{timestamp}.{ext}` |

**Políticas RLS:**

| Operación | Quién puede           | Condición                           |
| --------- | --------------------- | ----------------------------------- |
| SELECT    | Usuarios autenticados | Todos los avatars                   |
| INSERT    | Usuario autenticado   | Solo en su carpeta (`folder = uid`) |
| UPDATE    | Usuario autenticado   | Solo sus propios archivos           |
| DELETE    | Usuario autenticado   | Solo sus propios archivos           |

---

## 📝 Notas

- El trigger `on_auth_user_created` extrae `first_name`, `last_name` y `role` del `raw_user_meta_data` de Supabase Auth
- El campo `status` solo puede ser modificado por el Service Role (admin)
- El campo `verification_doc_url` es para almacenar el documento subido para verificación
