# 📊 Modelo de Datos - Diagrama ER

## Índice
1. [Visión General](#visión-general)
2. [Diagrama ER Completo](#diagrama-er-completo)
3. [Entidades Principales](#entidades-principales)
4. [Relaciones](#relaciones)
5. [Funciones PostgreSQL (RPCs)](#funciones-postgresql-rpcs)

---

## Visión General

La base de datos de **HAUS** está alojada en **Supabase** y utiliza **PostgreSQL** como motor. El modelo es relacional con soporte para datos geoespaciales, búsqueda full-text y funciones programadas.

**Base de datos**: `supabase` (proyecto personal)
**Esquema principal**: `public`
**Authentication**: `auth` (manejado por Supabase)

---

## Diagrama ER Completo

```
┌────────────────────────────────────────────────────────────────────┐
│                      auth.users (Supabase)                         │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ id (UUID) PK                                                  │  │
│  │ email (VARCHAR)                                               │  │
│  │ encrypted_password (VARCHAR)                                  │  │
│  │ email_confirmed_at (TIMESTAMP)                                │  │
│  │ created_at (TIMESTAMP)                                        │  │
│  └──────────────────────────────────────────────────────────────┘  │
│         ▲                    ▲              ▲            ▲         │
└─────────┼────────────────────┼──────────────┼────────────┼─────────┘
          │                    │              │            │
          │ 1:1                │ 1:1          │ 1:N        │ 1:N
      ┌───┴─────────┬──────────┴──────┬───────┴────────┬───┴──────┐
      │              │                 │                │          │
   profiles   subscription_plans   listings         conversations  messages
   
┌─────────────────────────────┐
│       profiles              │  (Extiende auth.users)
├─────────────────────────────┤
│ id (UUID) PK, FK            │
│ first_name (TEXT)           │
│ last_name (TEXT)            │
│ phone (TEXT)                │
│ avatar_url (TEXT)           │
│ bio (TEXT)                  │
│ role (ENUM)                 │  student | worker
│ status (ENUM)               │  unverified | pending | verified
│ university_or_company (TEXT)│
│ verification_doc_url (TEXT) │
│ onboarding_completed (BOOL) │
│ created_at (TIMESTAMP)      │
│ updated_at (TIMESTAMP)      │
└─────────────┬───────────────┘
              │ 1:1
              │
┌─────────────▼──────────────────────┐
│   user_preferences                 │
├────────────────────────────────────┤
│ id (UUID) PK                        │
│ user_id (UUID) FK                  │
│ cleanliness_level (INT 1-5)        │
│ sleep_schedule (TEXT)              │
│ noise_level (TEXT)                 │
│ is_smoker (BOOL)                   │
│ has_pets (BOOL)                    │
│ exercises (BOOL)                   │
│ plays_videogames (BOOL)            │
│ plays_music (BOOL)                 │
│ works_from_home (BOOL)             │
│ likes_parties (BOOL)               │
│ interests (TEXT[])                 │
│ budget_min (DECIMAL)               │
│ budget_max (DECIMAL)               │
│ created_at (TIMESTAMP)             │
│ updated_at (TIMESTAMP)             │
└────────────────────────────────────┘

┌─────────────────────────────┐
│   user_locations            │
├─────────────────────────────┤
│ id (UUID) PK                │
│ user_id (UUID) FK           │
│ address (TEXT)              │
│ city (TEXT)                 │
│ neighborhood (TEXT)         │
│ latitude (DECIMAL)          │
│ longitude (DECIMAL)         │
│ is_primary (BOOL)           │
│ created_at (TIMESTAMP)      │
│ updated_at (TIMESTAMP)      │
└────────────┬────────────────┘
             │ N:1
             │
┌────────────▼──────────────────────┐
│        listings                    │
├────────────────────────────────────┤
│ id (UUID) PK                       │
│ user_id (UUID) FK                  │
│ title (TEXT)                       │
│ description (TEXT)                 │
│ price_per_month (DECIMAL)          │
│ rooms_available (INT)              │
│ room_type (TEXT)                   │
│ utilities_included (TEXT[])        │
│ house_rules (TEXT[])               │
│ amenities (TEXT[])                 │
│ images_urls (TEXT[])               │
│ address (TEXT)                     │
│ city (TEXT)                        │
│ neighborhood (TEXT)                │
│ latitude (DECIMAL)                 │
│ longitude (DECIMAL)                │
│ is_available (BOOL)                │
│ created_at (TIMESTAMP)             │
│ updated_at (TIMESTAMP)             │
└────────────┬─────────────────┬────┘
             │ 1:N             │ 1:N
         ┌───┴────────┐       │
         │            │       │
  listing_requests  user_interactions
  
┌──────────────────────────┐
│   listing_requests       │
├──────────────────────────┤
│ id (UUID) PK             │
│ listing_id (UUID) FK     │
│ requester_id (UUID) FK   │
│ host_id (UUID) FK        │
│ message (TEXT)           │
│ status (ENUM)            │ pending | accepted | rejected
│ created_at (TIMESTAMP)   │
│ updated_at (TIMESTAMP)   │
└──────────────────────────┘

┌──────────────────────────┐
│  user_interactions       │
├──────────────────────────┤
│ id (UUID) PK             │
│ liker_id (UUID) FK       │
│ liked_id (UUID) FK       │
│ action (ENUM)            │ like | skip
│ created_at (TIMESTAMP)   │
└──────────────────────────┘
         │ N:M (Mutual likes)
         │
┌────────▼─────────────────┐
│      matches             │
├──────────────────────────┤
│ id (UUID) PK             │
│ user_id_1 (UUID) FK      │
│ user_id_2 (UUID) FK      │
│ matched_at (TIMESTAMP)   │
│ conversation_id (UUID)   │
│ created_at (TIMESTAMP)   │
│ updated_at (TIMESTAMP)   │
└──────────────────────────┘
         │ 1:1
         │
    ┌────▼──────────────────────────────┐
    │      conversations                │
    ├───────────────────────────────────┤
    │ id (UUID) PK                      │
    │ match_id (UUID) FK                │
    │ user_id_1 (UUID) FK               │
    │ user_id_2 (UUID) FK               │
    │ last_message_at (TIMESTAMP)       │
    │ is_active (BOOL)                  │
    │ created_at (TIMESTAMP)            │
    │ updated_at (TIMESTAMP)            │
    └────────────┬──────────────────────┘
                 │ 1:N
                 │
    ┌────────────▼───────────────────┐
    │         messages               │
    ├────────────────────────────────┤
    │ id (UUID) PK                   │
    │ conversation_id (UUID) FK      │
    │ sender_id (UUID) FK            │
    │ content (TEXT)                 │
    │ image_url (TEXT)               │
    │ is_read (BOOL)                 │
    │ created_at (TIMESTAMP)         │
    │ updated_at (TIMESTAMP)         │
    └────────────────────────────────┘

┌──────────────────────────┐
│   notifications          │
├──────────────────────────┤
│ id (UUID) PK             │
│ user_id (UUID) FK        │
│ type (ENUM)              │ chat_message | new_listing | 
│                          │ match_request | system |
│                          │ request_received |
│                          │ request_update
│ title (TEXT)             │
│ message (TEXT)           │
│ data (JSONB)             │
│ is_read (BOOL)           │
│ created_at (TIMESTAMP)   │
│ updated_at (TIMESTAMP)   │
└──────────────────────────┘

┌──────────────────────────┐
│  rent_contracts          │
├──────────────────────────┤
│ id (UUID) PK             │
│ listing_id (UUID) FK     │
│ tenant_id (UUID) FK      │
│ landlord_id (UUID) FK    │
│ start_date (DATE)        │
│ end_date (DATE)          │
│ monthly_rent (DECIMAL)   │
│ deposit (DECIMAL)        │
│ status (ENUM)            │ active | terminated
│ contract_pdf_url (TEXT)  │
│ created_at (TIMESTAMP)   │
│ updated_at (TIMESTAMP)   │
└──────────────────────────┘
         │ 1:N
         │
┌────────▼──────────────────────┐
│    rent_payments             │
├──────────────────────────────┤
│ id (UUID) PK                 │
│ contract_id (UUID) FK        │
│ amount (DECIMAL)             │
│ payment_date (DATE)          │
│ status (ENUM)                │ pending | paid | overdue
│ payment_method (TEXT)        │
│ transaction_id (TEXT)        │
│ notes (TEXT)                 │
│ created_at (TIMESTAMP)       │
│ updated_at (TIMESTAMP)       │
└──────────────────────────────┘

┌──────────────────────────┐
│ subscription_plans       │
├──────────────────────────┤
│ id (UUID) PK             │
│ user_id (UUID) FK        │
│ plan_type (TEXT)         │
│ price_per_month (DEC)    │
│ max_listings (INT)       │
│ max_likes_per_day (INT)  │
│ priority_boost (BOOL)    │
│ is_active (BOOL)         │
│ started_at (TIMESTAMP)   │
│ expires_at (TIMESTAMP)   │
│ created_at (TIMESTAMP)   │
│ updated_at (TIMESTAMP)   │
└──────────────────────────┘
```

---

## Entidades Principales

### 1. **profiles**
Extiende la tabla `auth.users` con información adicional del perfil.

```sql
CREATE TABLE profiles (
  id UUID NOT NULL PRIMARY KEY REFERENCES auth.users(id),
  first_name TEXT,
  last_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  bio TEXT,
  role user_role NOT NULL DEFAULT 'worker',
  status verification_status NOT NULL DEFAULT 'unverified',
  university_or_company TEXT,
  verification_doc_url TEXT,
  onboarding_completed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
```

**Enums:**
- `user_role`: `student` | `worker`
- `verification_status`: `unverified` | `pending` | `verified`

---

### 2. **user_preferences**
Almacena las preferencias de estilo de vida de cada usuario para el algoritmo de matching.

```sql
CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES profiles(id),
  cleanliness_level INTEGER CHECK (cleanliness_level BETWEEN 1 AND 5),
  sleep_schedule TEXT,
  noise_level TEXT,
  is_smoker BOOLEAN,
  has_pets BOOLEAN,
  exercises BOOLEAN,
  plays_videogames BOOLEAN,
  plays_music BOOLEAN,
  works_from_home BOOLEAN,
  likes_parties BOOLEAN,
  interests TEXT[] DEFAULT '{}',
  budget_min DECIMAL(10, 2),
  budget_max DECIMAL(10, 2),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

---

### 3. **user_locations**
Guarda múltiples ubicaciones por usuario (principal y secundarias).

```sql
CREATE TABLE user_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  neighborhood TEXT,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

---

### 4. **listings**
Publicaciones de habitaciones disponibles.

```sql
CREATE TABLE listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  title TEXT NOT NULL,
  description TEXT,
  price_per_month DECIMAL(10, 2) NOT NULL,
  rooms_available INTEGER DEFAULT 1,
  room_type TEXT,
  utilities_included TEXT[],
  house_rules TEXT[],
  amenities TEXT[],
  images_urls TEXT[] DEFAULT '{}',
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  neighborhood TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

---

### 5. **user_interactions**
Registro de interacciones (likes/skips) entre usuarios.

```sql
CREATE TABLE user_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  liker_id UUID NOT NULL REFERENCES profiles(id),
  liked_id UUID NOT NULL REFERENCES profiles(id),
  action ENUM ('like', 'skip') NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  
  CHECK (liker_id != liked_id)
);
```

---

### 6. **matches**
Matches creados cuando dos usuarios se dan like mutuamente.

```sql
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id_1 UUID NOT NULL REFERENCES profiles(id),
  user_id_2 UUID NOT NULL REFERENCES profiles(id),
  matched_at TIMESTAMP DEFAULT now(),
  conversation_id UUID REFERENCES conversations(id),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  
  CHECK (user_id_1 < user_id_2),
  UNIQUE(user_id_1, user_id_2)
);
```

---

### 7. **conversations**
Conversaciones entre usuarios que hicieron match.

```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id),
  user_id_1 UUID NOT NULL REFERENCES profiles(id),
  user_id_2 UUID NOT NULL REFERENCES profiles(id),
  last_message_at TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

---

### 8. **messages**
Mensajes de chat entre usuarios.

```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id),
  sender_id UUID NOT NULL REFERENCES profiles(id),
  content TEXT NOT NULL,
  image_url TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

---

### 9. **notifications**
Sistema de notificaciones global.

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  type ENUM (
    'chat_message',
    'new_listing',
    'match_request',
    'system',
    'request_received',
    'request_update'
  ) NOT NULL,
  title TEXT NOT NULL,
  message TEXT,
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

---

### 10. **listing_requests**
Solicitudes de inquilinos para habitar un listing.

```sql
CREATE TABLE listing_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES listings(id),
  requester_id UUID NOT NULL REFERENCES profiles(id),
  host_id UUID NOT NULL REFERENCES profiles(id),
  message TEXT,
  status ENUM ('pending', 'accepted', 'rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

---

### 11. **rent_contracts**
Contratos de alquiler automáticamente generados.

```sql
CREATE TABLE rent_contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES listings(id),
  tenant_id UUID NOT NULL REFERENCES profiles(id),
  landlord_id UUID NOT NULL REFERENCES profiles(id),
  start_date DATE NOT NULL,
  end_date DATE,
  monthly_rent DECIMAL(10, 2) NOT NULL,
  deposit DECIMAL(10, 2),
  status ENUM ('active', 'terminated') DEFAULT 'active',
  contract_pdf_url TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

---

### 12. **rent_payments**
Pagos mensuales de alquiler.

```sql
CREATE TABLE rent_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID NOT NULL REFERENCES rent_contracts(id),
  amount DECIMAL(10, 2) NOT NULL,
  payment_date DATE,
  status ENUM ('pending', 'paid', 'overdue') DEFAULT 'pending',
  payment_method TEXT,
  transaction_id TEXT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

---

### 13. **subscription_plans**
Planes de suscripción premium.

```sql
CREATE TABLE subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  plan_type TEXT NOT NULL,
  price_per_month DECIMAL(10, 2),
  max_listings INTEGER,
  max_likes_per_day INTEGER,
  priority_boost BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  started_at TIMESTAMP DEFAULT now(),
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

---

## Relaciones

| Relación | Cardinalidad | Descripción |
|----------|--------------|-------------|
| profiles → auth.users | 1:1 | Cada perfil está vinculado a un usuario Supabase |
| profiles → user_preferences | 1:1 | Un usuario tiene exactamente una preferencia |
| profiles → user_locations | 1:N | Un usuario puede tener múltiples ubicaciones |
| profiles → listings | 1:N | Un usuario puede publicar múltiples listings |
| listings → listing_requests | 1:N | Un listing puede recibir múltiples solicitudes |
| user_interactions → profiles | N:N | Los usuarios pueden interactuar entre sí |
| matches → conversations | 1:1 | Cada match tiene exactamente una conversación |
| conversations → messages | 1:N | Una conversación contiene múltiples mensajes |
| rent_contracts → rent_payments | 1:N | Un contrato tiene múltiples pagos |
| profiles → notifications | 1:N | Un usuario recibe múltiples notificaciones |

---

## Funciones PostgreSQL (RPCs)

Supabase expone funciones PostgreSQL como **Remote Procedure Calls (RPCs)** que pueden ser llamadas desde la app.

### 1. **get_match_candidates**
Obtiene candidatos compatibles para matching.

```sql
CREATE FUNCTION public.get_match_candidates(
  for_user_id UUID,
  limit_count INTEGER DEFAULT 20
)
RETURNS TABLE (
  user_id UUID,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  compatibility_score DECIMAL(5,2),
  budget_min DECIMAL(10,2),
  budget_max DECIMAL(10,2),
  -- ... más campos
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
  -- Calcula compatibilidad basada en preferencias
  -- Excluye: usuarios ya interactuados, misma ubicación
  -- Retorna top N candidatos ordenados por score
$$;
```

**Uso en Flutter:**
```dart
final candidates = await supabaseClient
  .rpc('get_match_candidates', params: {
    'for_user_id': userId,
    'limit_count': 20,
  });
```

---

### 2. **create_match_if_mutual**
Crea un match si ambos usuarios se dieron like.

```sql
CREATE FUNCTION public.create_match_if_mutual(
  liker_id UUID,
  liked_id UUID
)
RETURNS TABLE (
  match_id UUID,
  conversation_id UUID,
  is_new_match BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  -- Verifica si liked_id también dio like a liker_id
  -- Si es mutuo: crea match y conversación
  -- Si no: solo retorna NULL
$$;
```

---

### 3. **send_notification**
Envía una notificación a un usuario.

```sql
CREATE FUNCTION public.send_notification(
  target_user_id UUID,
  notif_type TEXT,
  title TEXT,
  message TEXT,
  data JSONB
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  -- Inserta en tabla notifications
  -- Dispara cambio en Realtime
$$;
```

---

### 4. **get_daily_likes_count**
Obtiene el número de likes realizados hoy.

```sql
CREATE FUNCTION public.get_daily_likes_count(for_user_id UUID)
RETURNS TABLE (likes_count INTEGER)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
  -- Cuenta registros en user_interactions del día actual
$$;
```

---

### 5. **approve_listing_request**
Aprueba una solicitud de listing y crea contrato.

```sql
CREATE FUNCTION public.approve_listing_request(
  request_id UUID
)
RETURNS TABLE (
  contract_id UUID,
  pdf_url TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  -- Actualiza listing_request a 'accepted'
  -- Crea rent_contract
  -- Genera PDF de contrato
  -- Envía notificaciones
$$;
```

---

### 6. **reject_listing_request**
Rechaza una solicitud de listing.

```sql
CREATE FUNCTION public.reject_listing_request(
  request_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  -- Actualiza listing_request a 'rejected'
  -- Envía notificación de rechazo
$$;
```

---

## Indexación

Para optimizar las consultas más frecuentes:

```sql
-- Búsqueda por ciudad
CREATE INDEX idx_listings_city ON listings(city);

-- Búsqueda geoespacial
CREATE INDEX idx_listings_location 
  ON listings USING GIST(ll_to_earth(latitude, longitude));

-- Búsqueda por usuario
CREATE INDEX idx_listings_user_id ON listings(user_id);

-- Conversaciones activas
CREATE INDEX idx_conversations_users 
  ON conversations(user_id_1, user_id_2);

-- Mensajes por conversación
CREATE INDEX idx_messages_conversation 
  ON messages(conversation_id, created_at DESC);

-- Notificaciones no leídas
CREATE INDEX idx_notifications_unread 
  ON notifications(user_id, is_read) 
  WHERE is_read = false;

-- Matching rápido
CREATE INDEX idx_matches_users 
  ON matches(user_id_1, user_id_2);

-- Interacciones duplicadas
CREATE INDEX idx_interactions_unique 
  ON user_interactions(liker_id, liked_id);
```

---

## Row Level Security (RLS)

Las tablas cuentan con políticas RLS para asegurar que los usuarios solo accedan a sus propios datos:

```sql
-- Usuarios solo pueden ver su perfil
CREATE POLICY select_own_profile ON profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Usuarios solo pueden actualizar su perfil
CREATE POLICY update_own_profile ON profiles
  FOR UPDATE
  USING (auth.uid() = id);

-- Solo propietarios pueden ver sus listings
CREATE POLICY select_own_listings ON listings
  FOR SELECT
  USING (auth.uid() = user_id OR is_available = true);

-- Solo participantes ven sus conversaciones
CREATE POLICY select_own_conversations ON conversations
  FOR SELECT
  USING (auth.uid() = user_id_1 OR auth.uid() = user_id_2);
```

---

**Última actualización**: Enero 2026
**Motor de BD**: PostgreSQL (Supabase)
**Versión del Schema**: 1.0
