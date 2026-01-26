# 🔌 Documentación de API

## Índice
1. [Visión General](#visión-general)
2. [Autenticación](#autenticación)
3. [Endpoints Principales](#endpoints-principales)
4. [Remote Procedure Calls (RPCs)](#remote-procedure-calls-rpcs)
5. [Real-time Subscriptions](#real-time-subscriptions)
6. [Ejemplos de Uso](#ejemplos-de-uso)
7. [Códigos de Error](#códigos-de-error)

---

## Visión General

**HAUS** utiliza **Supabase** como backend, que proporciona:

- **REST API**: Para CRUD operations estándar
- **GraphQL API**: Alternativa de consultas
- **Real-time API**: Para subscripciones en tiempo real
- **PostgreSQL Functions (RPCs)**: Lógica de negocio específica

**Base URL de API**: `https://{PROJECT_ID}.supabase.co`
**Headers requeridos**:
```
Content-Type: application/json
Authorization: Bearer {ANON_KEY}
apikey: {ANON_KEY}
```

---

## Autenticación

### Sign Up (Registro)

**Endpoint**: `POST /auth/v1/signup`

**Request:**
```json
{
  "email": "usuario@example.com",
  "password": "SecurePassword123!",
  "data": {
    "first_name": "Juan",
    "last_name": "Pérez",
    "role": "student"
  }
}
```

**Response (201 Created):**
```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "usuario@example.com",
    "email_confirmed_at": null,
    "created_at": "2025-01-26T10:30:00.000Z"
  },
  "session": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "...",
    "expires_in": 3600
  }
}
```

**Flutter Implementation:**
```dart
final response = await supabaseClient.auth.signUpWithPassword(
  email: 'usuario@example.com',
  password: 'SecurePassword123!',
  data: {
    'first_name': 'Juan',
    'last_name': 'Pérez',
    'role': 'student',
  },
);
```

---

### Sign In (Login)

**Endpoint**: `POST /auth/v1/token?grant_type=password`

**Request:**
```json
{
  "email": "usuario@example.com",
  "password": "SecurePassword123!"
}
```

**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "..."
}
```

**Flutter Implementation:**
```dart
final response = await supabaseClient.auth.signInWithPassword(
  email: 'usuario@example.com',
  password: 'SecurePassword123!',
);

final user = response.user;
final session = response.session;
```

---

### Password Reset

**Endpoint**: `POST /auth/v1/recover`

**Request:**
```json
{
  "email": "usuario@example.com"
}
```

**Response (200 OK):**
```json
{
  "message": "Check your email for the password reset link"
}
```

---

## Endpoints Principales

### Profiles (Perfiles de Usuario)

#### GET - Obtener perfil actual

**Endpoint**: `GET /rest/v1/profiles?id=eq.{userId}`

**Headers:**
```
Authorization: Bearer {ACCESS_TOKEN}
```

**Response (200 OK):**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "first_name": "Juan",
    "last_name": "Pérez",
    "email": "juan@example.com",
    "phone": "+57 3001234567",
    "avatar_url": "https://bucket.supabase.co/avatars/550e8400.jpg",
    "bio": "Estudiante de Ingeniería en Sistemas",
    "role": "student",
    "status": "verified",
    "university_or_company": "Universidad Nacional",
    "onboarding_completed": true,
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-26T10:30:00Z"
  }
]
```

**Flutter Implementation:**
```dart
final response = await supabaseClient
  .from('profiles')
  .select()
  .eq('id', userId)
  .single();

final profile = UserModel.fromJson(response);
```

---

#### PUT - Actualizar perfil

**Endpoint**: `PATCH /rest/v1/profiles?id=eq.{userId}`

**Request:**
```json
{
  "first_name": "Juan",
  "last_name": "Pérez",
  "bio": "Estudiante de Ingeniería",
  "phone": "+57 3001234567"
}
```

**Response (200 OK):** El perfil actualizado

**Flutter Implementation:**
```dart
await supabaseClient
  .from('profiles')
  .update({
    'first_name': 'Juan',
    'bio': 'Estudiante de Ingeniería',
  })
  .eq('id', userId);
```

---

### Listings (Publicaciones de Habitaciones)

#### GET - Obtener todos los listings

**Endpoint**: `GET /rest/v1/listings?is_available=eq.true&order=created_at.desc`

**Query Parameters:**
- `city=eq.Medellín` - Filtrar por ciudad
- `price_per_month=lte.1000000` - Filtrar por precio máximo
- `order=created_at.desc` - Ordenar por fecha descendente
- `limit=20&offset=0` - Paginación

**Response (200 OK):**
```json
[
  {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Habitación amplia en Laureles",
    "description": "Habitación con vista a la ciudad...",
    "price_per_month": 850000,
    "rooms_available": 1,
    "room_type": "private",
    "utilities_included": ["WiFi", "Agua"],
    "house_rules": ["No mascotas", "Silencio después de 11pm"],
    "amenities": ["Cocina compartida", "Baño privado"],
    "images_urls": ["https://bucket...jpg"],
    "address": "Carrera 45 #32-10",
    "city": "Medellín",
    "neighborhood": "Laureles",
    "latitude": 6.2548,
    "longitude": -75.5694,
    "is_available": true,
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-26T10:30:00Z"
  }
]
```

**Flutter Implementation:**
```dart
final listings = await supabaseClient
  .from('listings')
  .select()
  .eq('is_available', true)
  .order('created_at', ascending: false)
  .limit(20);
```

---

#### POST - Crear un nuevo listing

**Endpoint**: `POST /rest/v1/listings`

**Request:**
```json
{
  "title": "Habitación amplia en Laureles",
  "description": "Habitación con vista a la ciudad",
  "price_per_month": 850000,
  "rooms_available": 1,
  "room_type": "private",
  "utilities_included": ["WiFi", "Agua"],
  "house_rules": ["No mascotas"],
  "amenities": ["Cocina", "Baño"],
  "images_urls": [],
  "address": "Carrera 45 #32-10",
  "city": "Medellín",
  "neighborhood": "Laureles",
  "latitude": 6.2548,
  "longitude": -75.5694,
  "is_available": true
}
```

**Response (201 Created):**
```json
{
  "id": "660e8400-e29b-41d4-a716-446655440001",
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "created_at": "2025-01-26T10:30:00Z",
  "updated_at": "2025-01-26T10:30:00Z",
  ...
}
```

---

#### GET - Obtener un listing específico

**Endpoint**: `GET /rest/v1/listings?id=eq.{listingId}`

**Response (200 OK):**
```json
[
  {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    ...
  }
]
```

---

### Messages (Chat en Tiempo Real)

#### POST - Enviar un mensaje

**Endpoint**: `POST /rest/v1/messages`

**Request:**
```json
{
  "conversation_id": "770e8400-e29b-41d4-a716-446655440002",
  "sender_id": "550e8400-e29b-41d4-a716-446655440000",
  "content": "¡Hola! ¿Te interesa la habitación?",
  "image_url": null
}
```

**Response (201 Created):**
```json
{
  "id": "880e8400-e29b-41d4-a716-446655440003",
  "conversation_id": "770e8400-e29b-41d4-a716-446655440002",
  "sender_id": "550e8400-e29b-41d4-a716-446655440000",
  "content": "¡Hola! ¿Te interesa la habitación?",
  "is_read": false,
  "created_at": "2025-01-26T10:30:00Z"
}
```

**Flutter Implementation:**
```dart
await supabaseClient.from('messages').insert({
  'conversation_id': conversationId,
  'sender_id': currentUserId,
  'content': 'Hola!',
});
```

---

#### Real-time Subscription - Escuchar mensajes

```dart
supabaseClient
  .from('messages:conversation_id=eq.$conversationId')
  .on(RealtimeListenTypes.all, (payload) {
    print('Nuevo mensaje: ${payload.newRecord}');
  })
  .subscribe();
```

---

### User Interactions (Matching)

#### POST - Registrar una interacción (Like/Skip)

**Endpoint**: `POST /rest/v1/user_interactions`

**Request:**
```json
{
  "liker_id": "550e8400-e29b-41d4-a716-446655440000",
  "liked_id": "660e8400-e29b-41d4-a716-446655440001",
  "action": "like"
}
```

**Response (201 Created):**
```json
{
  "id": "990e8400-e29b-41d4-a716-446655440004",
  "liker_id": "550e8400-e29b-41d4-a716-446655440000",
  "liked_id": "660e8400-e29b-41d4-a716-446655440001",
  "action": "like",
  "created_at": "2025-01-26T10:30:00Z"
}
```

---

### Listing Requests (Solicitudes de Habitación)

#### POST - Enviar solicitud para un listing

**Endpoint**: `POST /rest/v1/listing_requests`

**Request:**
```json
{
  "listing_id": "660e8400-e29b-41d4-a716-446655440001",
  "requester_id": "550e8400-e29b-41d4-a716-446655440000",
  "host_id": "770e8400-e29b-41d4-a716-446655440002",
  "message": "¡Hola! Me interesa tu habitación. Soy estudiante de Sistemas."
}
```

**Response (201 Created):**
```json
{
  "id": "aa0e8400-e29b-41d4-a716-446655440005",
  "listing_id": "660e8400-e29b-41d4-a716-446655440001",
  "requester_id": "550e8400-e29b-41d4-a716-446655440000",
  "host_id": "770e8400-e29b-41d4-a716-446655440002",
  "status": "pending",
  "message": "¡Hola! Me interesa tu habitación...",
  "created_at": "2025-01-26T10:30:00Z"
}
```

---

#### PUT - Actualizar estado de solicitud (Aprobar/Rechazar)

**Endpoint**: `PATCH /rest/v1/listing_requests?id=eq.{requestId}`

**Request:**
```json
{
  "status": "accepted"
}
```

**Response (200 OK):**
```json
[
  {
    "id": "aa0e8400-e29b-41d4-a716-446655440005",
    "status": "accepted",
    ...
  }
]
```

---

## Remote Procedure Calls (RPCs)

### GET - Obtener candidatos de matching

**Endpoint**: `POST /rest/v1/rpc/get_match_candidates`

**Request:**
```json
{
  "for_user_id": "550e8400-e29b-41d4-a716-446655440000",
  "limit_count": 20
}
```

**Response (200 OK):**
```json
[
  {
    "user_id": "660e8400-e29b-41d4-a716-446655440001",
    "first_name": "María",
    "last_name": "García",
    "avatar_url": "https://...",
    "bio": "Estudiante de Arquitectura",
    "compatibility_score": 85.50,
    "budget_min": 700000,
    "budget_max": 1000000,
    "cleanliness_level": 4,
    "sleep_schedule": "early_bird",
    "is_smoker": false,
    "has_pets": false
  },
  ...
]
```

**Flutter Implementation:**
```dart
final candidates = await supabaseClient
  .rpc('get_match_candidates', params: {
    'for_user_id': userId,
    'limit_count': 20,
  });
```

---

### GET - Obtener matches del usuario

**Endpoint**: `GET /rest/v1/matches?user_id_1=eq.{userId} or user_id_2=eq.{userId}`

**Response (200 OK):**
```json
[
  {
    "id": "bb0e8400-e29b-41d4-a716-446655440006",
    "user_id_1": "550e8400-e29b-41d4-a716-446655440000",
    "user_id_2": "660e8400-e29b-41d4-a716-446655440001",
    "matched_at": "2025-01-20T10:30:00Z",
    "conversation_id": "cc0e8400-e29b-41d4-a716-446655440007",
    "created_at": "2025-01-20T10:30:00Z"
  }
]
```

---

### POST - Crear match (RPC)

**Endpoint**: `POST /rest/v1/rpc/create_match_if_mutual`

**Request:**
```json
{
  "liker_id": "550e8400-e29b-41d4-a716-446655440000",
  "liked_id": "660e8400-e29b-41d4-a716-446655440001"
}
```

**Response (200 OK):**
```json
[
  {
    "match_id": "bb0e8400-e29b-41d4-a716-446655440006",
    "conversation_id": "cc0e8400-e29b-41d4-a716-446655440007",
    "is_new_match": true
  }
]
```

---

### GET - Contar likes diarios

**Endpoint**: `POST /rest/v1/rpc/get_daily_likes_count`

**Request:**
```json
{
  "for_user_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response (200 OK):**
```json
[
  {
    "likes_count": 15
  }
]
```

---

## Real-time Subscriptions

### Escuchar nuevos mensajes

```dart
supabaseClient
  .from('messages:conversation_id=eq.$conversationId')
  .on(RealtimeListenTypes.insert, (payload) {
    final newMessage = MessageModel.fromJson(payload.newRecord);
    print('Nuevo mensaje recibido: ${newMessage.content}');
  })
  .subscribe();
```

### Escuchar cambios en listings

```dart
supabaseClient
  .from('listings:city=eq.$city')
  .on(RealtimeListenTypes.all, (payload) {
    if (payload.eventType == 'INSERT') {
      print('Nuevo listing publicado');
    } else if (payload.eventType == 'UPDATE') {
      print('Listing actualizado');
    }
  })
  .subscribe();
```

### Escuchar notificaciones

```dart
supabaseClient
  .from('notifications:user_id=eq.$userId')
  .on(RealtimeListenTypes.insert, (payload) {
    final notification = NotificationModel.fromJson(payload.newRecord);
    print('Nueva notificación: ${notification.title}');
  })
  .subscribe();
```

---

## Ejemplos de Uso

### Ejemplo completo: Sign Up y crear perfil

```dart
// 1. Sign up
final response = await supabaseClient.auth.signUpWithPassword(
  email: email,
  password: password,
);

final user = response.user;

// 2. Crear perfil (se crea automáticamente con trigger)
// 3. Completar preferencias
await supabaseClient
  .from('user_preferences')
  .insert({
    'user_id': user!.id,
    'budget_min': 700000,
    'budget_max': 1200000,
    'is_smoker': false,
    'cleanliness_level': 4,
  });

// 4. Agregar ubicación
await supabaseClient
  .from('user_locations')
  .insert({
    'user_id': user.id,
    'address': 'Carrera 45 #32-10',
    'city': 'Medellín',
    'latitude': 6.2548,
    'longitude': -75.5694,
    'is_primary': true,
  });
```

---

## Códigos de Error

| Código | Significado | Solución |
|--------|-------------|----------|
| 400 | Bad Request | Verifica los parámetros enviados |
| 401 | Unauthorized | Token expirado o no enviado |
| 403 | Forbidden | Permisos insuficientes (RLS) |
| 404 | Not Found | Recurso no existe |
| 409 | Conflict | Email ya registrado o UNIQUE constraint |
| 500 | Server Error | Error del servidor de Supabase |
| 503 | Service Unavailable | Supabase está en mantenimiento |

---

**Última actualización**: Enero 2026
**Version de API**: v1
**Backend**: Supabase REST API
