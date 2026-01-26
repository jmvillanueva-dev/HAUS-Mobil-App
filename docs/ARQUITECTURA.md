# 🏗️ Arquitectura del Sistema HAUS

## Índice
1. [Visión General](#visión-general)
2. [Diagrama de Componentes](#diagrama-de-componentes)
3. [Capas de Arquitectura](#capas-de-arquitectura)
4. [Servicios Principales](#servicios-principales)
5. [Patrones de Diseño](#patrones-de-diseño)
6. [Flujos de Datos](#flujos-de-datos)

---

## Visión General

**HAUS** es una plataforma móvil que implementa **Clean Architecture** con una estructura claramente definida en tres capas:

- **Presentation Layer**: UI reactiva con Flutter y gestión de estado con BLoC
- **Domain Layer**: Lógica de negocio pura, agnóstica de frameworks
- **Data Layer**: Acceso a datos a través de repositorios y DataSources

### Tecnologías Principales

```
┌─────────────────────────────────────────┐
│         Frontend (Flutter 3.6+)         │
│  - Flutter BLoC para state management   │
│  - GetIt para inyección de dependencias │
│  - Responsive Design                    │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│      Backend (Supabase Platform)        │
│  - PostgreSQL Database                  │
│  - Real-time Subscriptions (Realtime)   │
│  - Authentication (Supabase Auth)       │
│  - Storage (Supabase Storage)           │
│  - Edge Functions (Optional)            │
└─────────────────────────────────────────┘
```

---

## Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                    CAPA PRESENTACIÓN                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              BLoC State Management                   │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │ ┌────────────┐ ┌────────────┐ ┌────────────┐        │  │
│  │ │ AuthBloc   │ │ HomeBloc   │ │ChatBloc    │ ...    │  │
│  │ │ Events     │ │ Events     │ │ Events     │        │  │
│  │ │ States     │ │ States     │ │ States     │        │  │
│  │ └────────────┘ └────────────┘ └────────────┘        │  │
│  └──────────────────────────────────────────────────────┘  │
│                       ▲                                     │
│                       │                                     │
│  ┌────────────────────┴────────────────────┐               │
│  │                                          │               │
│ Pages        Widgets        Dialogs    Screens              │
│  │                                          │               │
│  └────────────────────┬────────────────────┘               │
│                       │                                     │
└───────────────────────┼─────────────────────────────────────┘
                        │ UseCase Calls
┌───────────────────────▼─────────────────────────────────────┐
│                 CAPA DOMINIO                                │
├───────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐ │
│  │                  USE CASES                           │ │
│  ├──────────────────────────────────────────────────────┤ │
│  │ • GetCurrentUser         • SendMessage              │ │
│  │ • SignUp/SignIn          • UpdateProfile            │ │
│  │ • GetListings            • RecordInteraction        │ │
│  │ • CreateListing          • GetMatches               │ │
│  │ • SendRequest            • GetNotifications         │ │
│  │ • UpdateRequestStatus    • GetConversations         │ │
│  └──────────────────────────────────────────────────────┘ │
│                       ▲                                    │
│                       │                                    │
│  ┌────────────────────┴──────────────────────────────┐    │
│  │                                                   │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────┐ │    │
│  │  │ Entities     │  │ Repositories │  │ Failure │ │    │
│  │  │ (Pure Data)  │  │ (Abstract)   │  │ Types   │ │    │
│  │  └──────────────┘  └──────────────┘  └─────────┘ │    │
│  │                                                   │    │
│  └───────────────────┬──────────────────────────────┘    │
│                      │                                   │
└──────────────────────┼───────────────────────────────────┘
                       │ Repository Implementation
┌──────────────────────▼───────────────────────────────────┐
│              CAPA DE DATOS                               │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │        Remote Data Sources                         │ │
│  ├────────────────────────────────────────────────────┤ │
│  │ • Auth DataSource  (Supabase Auth API)             │ │
│  │ • Listing DataSource (Supabase Database)           │ │
│  │ • Chat DataSource (Supabase Realtime)              │ │
│  │ • Matching DataSource (Supabase Functions)         │ │
│  │ • Notification DataSource (Supabase Realtime)      │ │
│  └────────────────────────────────────────────────────┘ │
│                       ▲                                  │
│                       │                                  │
│  ┌────────────────────┴──────────────────────────────┐  │
│  │  Repository Implementations                       │  │
│  │  (Implement error handling & transformation)      │  │
│  └────────────────────┬──────────────────────────────┘  │
│                       │                                  │
└───────────────────────┼──────────────────────────────────┘
                        │
        ┌───────────────┴──────────────┬───────────┐
        │                              │           │
    ┌───▼──────┐          ┌───────────▼──┐   ┌──────▼──┐
    │ Supabase │          │   Supabase   │   │ Supabase│
    │ Auth     │          │   Database   │   │ Storage │
    │          │          │   (PostgreSQL)  │          │
    └──────────┘          └──────────────┘   └─────────┘
        │                       │
        └───────────┬───────────┘
                    │
            ┌───────▼───────┐
            │  Supabase API │
            │   Backend     │
            └───────────────┘
```

---

## Capas de Arquitectura

### 1. **Presentation Layer** 📱

Responsable de la interfaz de usuario y la gestión de estado.

```
lib/features/
  ├── {feature}/
  │   └── presentation/
  │       ├── bloc/
  │       │   ├── {feature}_bloc.dart       # BLoC principal
  │       │   ├── {feature}_event.dart      # Eventos
  │       │   └── {feature}_state.dart      # Estados
  │       └── pages/
  │           ├── {feature}_page.dart       # Página principal
  │           └── {detail}_page.dart        # Páginas secundarias
  │       └── widgets/
  │           └── {custom}_widget.dart      # Widgets reutilizables
```

**Responsabilidades:**
- Renderizar la UI
- Escuchar eventos de usuario
- Emitir eventos al BLoC
- Actualizar UI según cambios de estado

**Ejemplo BLoC:**
```dart
// Event
class SignInEvent extends AuthEvent {
  final String email;
  final String password;
  SignInEvent({required this.email, required this.password});
}

// State
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final UserEntity user;
  AuthSuccess(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

---

### 2. **Domain Layer** 🧠

Contiene la lógica de negocio pura, independiente de cualquier framework.

```
lib/features/
  └── {feature}/
      └── domain/
          ├── entities/
          │   └── {entity}.dart         # Modelos de negocio puros
          ├── repositories/
          │   └── {feature}_repository.dart  # Contrato de repositorio
          └── usecases/
              └── {use_case}.dart       # Casos de uso
```

**Responsabilidades:**
- Definir entidades (modelos de negocio)
- Definir repositorios abstractos
- Implementar casos de uso
- Manejar errores (Failures)

**Ejemplo de Entity:**
```dart
class UserEntity {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role; // 'student' o 'worker'
  final String status; // 'unverified', 'pending', 'verified'
  
  UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
  });
}
```

**Ejemplo de UseCase:**
```dart
class SignInWithEmailAndPassword 
    implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;
  
  SignInWithEmailAndPassword(this.repository);
  
  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}
```

---

### 3. **Data Layer** 💾

Implementa la lógica de acceso a datos y transformación de modelos.

```
lib/features/
  └── {feature}/
      └── data/
          ├── datasources/
          │   └── {feature}_remote_data_source.dart  # Contrato
          │   └── {feature}_remote_data_source_impl.dart  # Implementación
          ├── models/
          │   └── {model}_model.dart  # DTO (Data Transfer Objects)
          └── repositories/
              └── {feature}_repository_impl.dart  # Implementación
```

**Responsabilidades:**
- Acceder a datos remotos (Supabase)
- Transformar DTOs a Entities
- Manejar errores de red
- Implementar Repositorios

**Ejemplo DataSource:**
```dart
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  
  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    // Construir UserModel desde la respuesta
    return UserModel.fromJson(response.user?.toJson() ?? {});
  }
}
```

**Ejemplo Repository Implementation:**
```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  
  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userModel.toEntity()); // Convertir a Entity
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

---

## Servicios Principales

### 1. **Inyección de Dependencias (GetIt + Injectable)**

Todos los servicios están registrados en `injection_container.dart`:

```dart
// Supabase Client (singleton)
getIt.registerLazySingleton<SupabaseClient>(
  () => Supabase.instance.client
);

// Servicios core
getIt.registerLazySingleton<NavigationService>(() => NavigationService());
getIt.registerLazySingleton<AvatarService>(() => AvatarServiceImpl(...));

// Repositories
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(getIt())
);

// Use Cases
getIt.registerLazySingleton(
  () => SignInWithEmailAndPassword(getIt())
);

// BLoCs
getIt.registerFactory(() => AuthBloc(getIt()));
```

### 2. **Servicios Core**

#### NavigationService
Proporciona navegación global desde cualquier parte de la app:
```dart
GetIt.I<NavigationService>().navigateTo(ChatPage());
```

#### AvatarService
Gestiona upload/descarga de avatares en Supabase Storage:
```dart
final fileName = await avatarService.uploadAvatar(userId, imageFile);
```

#### NotificationService
Maneja notificaciones locales y escucha de cambios en tiempo real:
```dart
GlobalMessageListener().startListening();
```

#### PDFGeneratorService
Genera contratos de alquiler en PDF:
```dart
final pdf = await pdfGenerator.generateAcceptanceLetter(...);
```

---

## Patrones de Diseño

### 1. **BLoC Pattern**
```
User Interaction → Event → BLoC → State → UI Update
```

### 2. **Repository Pattern**
```
UseCase → Repository (Abstract) → DataSource → Supabase API
                     ↓
              RepositoryImpl (Concrete)
```

### 3. **Either Pattern (Functional Programming)**
Manejo de errores sin excepciones:

```dart
Either<Failure, UserEntity> result = await signIn();

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('Éxito: ${user.email}'),
);
```

### 4. **Dependency Injection**
```dart
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository { ... }

// Uso en constructor
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc(this.repository);
}
```

---

## Flujos de Datos

### Flujo de Autenticación

```
┌─────────────────────────────────────────────────────────────┐
│                    PANTALLA LOGIN                           │
│  (Usuario ingresa email y contraseña)                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
         emit SignInEvent(email, password)
                     │
┌────────────────────┼────────────────────────────────────────┐
│                 AUTH BLOC                                   │
│  on<SignInEvent>:                                           │
│  - emit(AuthLoading)                                        │
│  - call SignInUseCase                                       │
└────────────────────┼────────────────────────────────────────┘
                     │
                     ▼
         ┌───────────────────────────┐
         │   SignInUseCase Call      │
         │  await repository.signIn()│
         └───────────────┬───────────┘
                         │
┌────────────────────────┼─────────────────────────────────────┐
│           AUTH REPOSITORY (Abstract)                         │
│  Retorna: Either<Failure, UserEntity>                        │
└────────────────────────┼─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│    AUTH REPOSITORY IMPL (Concrete)                           │
│  - Llama remoteDataSource.signIn()                           │
│  - Transforma UserModel → UserEntity                         │
│  - Maneja excepciones → Failure                              │
└────────────────────────┬─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│   AUTH REMOTE DATA SOURCE (Supabase)                         │
│  - await supabase.auth.signInWithPassword(...)               │
│  - Retorna UserModel                                         │
└────────────────────────┬─────────────────────────────────────┘
                         │
         ┌───────────────┼────────────────────┐
         │               │                    │
    ┌────▼───┐      ┌────▼────┐        ┌────▼────┐
    │ Success│      │ Error   │        │Timeout  │
    └────┬───┘      └────┬────┘        └────┬────┘
         │               │                    │
         └───────────────┼────────────────────┘
                         │
              ┌──────────▼──────────┐
              │ Either<Failure, User>
              └──────────┬──────────┘
                         │
         ┌───────────────┴────────────────┐
         │                                │
    ┌────▼──────────┐          ┌─────────▼────────┐
    │ Left(Failure) │          │ Right(UserEntity)│
    └────┬──────────┘          └─────────┬────────┘
         │                              │
    emit AuthError                  emit AuthSuccess
         │                              │
         └──────────────┬───────────────┘
                        │
              ┌─────────▼─────────┐
              │   BLoC Emits      │
              │   New State       │
              └─────────┬─────────┘
                        │
            ┌───────────▼──────────┐
            │  UI Updates          │
            │  (Provider rebuild)  │
            └──────────────────────┘
```

### Flujo de Listings (Real-time)

```
┌──────────────────────────────────┐
│   ListingBloc Initialization     │
└────────────┬─────────────────────┘
             │
             ▼
  add LoadListingsEvent()
             │
┌────────────┼─────────────────────┐
│        LISTING BLOC               │
│  on<LoadListingsEvent>:           │
│  - Listen to getListingsStream()  │
│  - Emit ListingsLoaded state      │
└────────────┬─────────────────────┘
             │
┌────────────▼─────────────────────┐
│   ListingRepository              │
│   getListingsStream():           │
│   - Retorna Stream<List<Listing>>│
└────────────┬─────────────────────┘
             │
┌────────────▼──────────────────────────┐
│   ListingRemoteDataSource             │
│   getListingsStream():                │
│   - supabase.from('listings')        │
│     .stream()                         │
│     .map(transform to Model)          │
└────────────┬──────────────────────────┘
             │
             ▼
    Supabase Real-time
    (WebSocket Subscription)
             │
             ├─ SELECT * FROM listings
             │
             ▼
    ┌────────────────────┐
    │ New listing added? │
    └────────┬───────────┘
             │
    ┌────────▼───────────────┐
    │ Stream emits new data  │
    │ to BLoC                │
    └────────┬───────────────┘
             │
    emit ListingsLoaded(newListings)
             │
             ▼
        UI Rebuilds
        with new listings
```

---

## Resumen

La arquitectura de **HAUS** proporciona:

✅ **Separación de Responsabilidades**: Cada capa tiene un propósito claro
✅ **Testabilidad**: Las capas de negocio están aisladas de frameworks
✅ **Mantenibilidad**: Fácil agregar nuevas features sin afectar existentes
✅ **Escalabilidad**: Estructura preparada para crecer
✅ **Reutilización**: Código modular y componible

---

**Última actualización**: Enero 2026
**Versión de la app**: 1.0.0
