# HAUS Mobil App 🏠

**HAUS** es una plataforma móvil revolucionaria diseñada para simplificar la búsqueda de compañeros de cuarto (roomies) y habitaciones disponibles. Utiliza algoritmos de inteligencia artificial y una arquitectura robusta para garantizar seguridad, compatibilidad y una experiencia de usuario premium.

---

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Módulos Principales](#-módulos-principales)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
- [Ejecución](#-ejecución)
- [Arquitectura](#-arquitectura)
- [Documentación Técnica Completa](#-documentación-técnica-completa)
- [Índice de Requisitos Técnicos](#-índice-de-requisitos-técnicos)
- [Guía Rápida](#-guía-rápida)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Testing](#-testing)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)

---

## ✨ Características

✅ **Autenticación segura** con Supabase Auth  
✅ **Matching inteligente** basado en 15+ factores de compatibilidad  
✅ **Chat en tiempo real** con WebSocket  
✅ **Publicación de habitaciones** con búsqueda avanzada  
✅ **Generación automática de contratos** en PDF  
✅ **Gestión de pagos y suscripciones**  
✅ **Notificaciones en tiempo real**  
✅ **Verificación de identidad**  
✅ **Interfaz responsiva y moderna**  
✅ **Soporte offline** (parcial)

---

## 🌟 Módulos Principales

### 1. 👤 Matching & Perfiles

- **Algoritmo de Compatibilidad**: Evaluación de 15+ factores de estilo de vida (ruido, limpieza, mascotas, horarios, etc.)
- **Perfiles Premium**: Interfaz inmersiva con efectos de glassmorphism y parallax
- **Onboarding Inteligente**: Proceso guiado para capturar preferencias precisas
- **Verificación de Identidad**: Validación de estudiantes/trabajadores

### 2. 🏠 Marketplace de Listings

- **Búsqueda Avanzada**: Filtros por ubicación, precio, amenidades y tipo de rol
- **Gestión de Propiedades**: Herramientas para hosts para publicar y gestionar habitaciones
- **Galería de Fotos**: Upload múltiple de imágenes
- **Mapas Integrados**: Visualización geoespacial

### 3. 💰 Fintech & Contratos

- **Contratos Automatizados**: Generación automática de contratos de renta en PDF
- **Gestión de Pagos**: Seguimiento de mensualidades y estados de pago
- **Planes de Suscripción**: Diferentes tiers de características
- **Historial Financiero**: Registro detallado de transacciones

### 4. 💬 Comunicación

- **Chat en Tiempo Real**: Mensajería instantánea con Supabase Realtime
- **Notificaciones Globales**: Alertas instantáneas para matches, mensajes y solicitudes
- **Lectura de Mensajes**: Indicadores de mensajes leídos
- **Soporte para Imágenes**: Envío de fotos en chat

### 5. 🔐 Autenticación (Auth)

- Sign up/Sign in con email y password
- Recuperación de contraseña
- Verificación de email
- Gestión de sesión segura

### 6. 🔔 Notificaciones

- Notificaciones en tiempo real
- Alertas de nuevos matches
- Avisos de mensajes recibidos
- Recordatorios de pagos

### 7. 💳 Financial

- Registro de pagos de renta
- Comisiones de la plataforma
- Historial de transacciones
- Estados de pago (pendiente/completado)

### 8. 📦 Subscription

- Planes básico, premium y enterprise
- Gestión de suscripciones
- Renovación automática
- Estadísticas de uso

### 9. 📍 Locations

- Geolocalización del usuario
- Historial de ubicaciones
- Búsqueda por cercanía

### 10. 🤝 Connections

- Gestión de conexiones entre usuarios
- Lista de contactos
- Matches confirmados

### 11. 🔍 Explore

- Descubrimiento de propiedades
- Filtros avanzados
- Guardados y favoritos

### 12. 📋 Requests

- Solicitudes de alquiler
- Aprobación/rechazo de requests
- Estados de solicitudes

### 13. 🎯 Onboarding

- Setup inicial del perfil
- Tour de la aplicación
- Configuración de preferencias

---

## 🔧 Requisitos

### Software Necesario

- **Flutter SDK**: 3.6.2 o superior
- **Dart**: 3.0 o superior
- **Android Studio** o **Xcode** (según plataforma)
- **Git**: Para control de versiones

### Hardware Mínimo

- **RAM**: 8GB mínimo
- **Espacio en disco**: 50GB libres
- **Conexión a internet**: Estable

### Cuentas Necesarias

- Cuenta de Supabase (para backend)
- Cuenta de GitHub (para control de versiones)
- Apple Developer account (si vas a publicar en iOS)
- Google Play Developer account (si vas a publicar en Android)

---

## 📥 Instalación

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/jmvillanueva-dev/HAUS-Mobil-App
cd HAUS-Mobil-App
```

### Paso 2: Instalar Dependencias

```bash
flutter pub get
```

### Paso 3: Generar Código (Build Runner)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ⚙️ Configuración

### Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:

```bash
cp .env.example .env
```

Edita el archivo `.env` con tus credenciales de Supabase:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon-key
```

### Configuración de Supabase

1. Crea un proyecto en [supabase.com](https://supabase.com)
2. Copia la URL y la API Key (anon/public)
3. Ejecuta los scripts SQL en orden desde la carpeta `database/`:

```bash
# En el SQL Editor de Supabase, ejecuta en orden:
01_auth_schema.sql
02_user_locations.sql
03_listing.sql
04_onboarding_profile.sql
05_chat.sql
06_chat_rls.sql
06_notifications.sql
07_user_preferences.sql
08_matching.sql
09_update_chat_for_matching.sql
10_fix_ambiguous_column.sql
... (continúa con todos los archivos)
```

4. Aplica las políticas RLS desde `database/RLS_policies.sql`

---

## 🚀 Ejecución

### En Emulador/Dispositivo

```bash
flutter run
```

### En dispositivo específico

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device-id>
```

### Modo Release

```bash
flutter run --release
```

---

## 🏗️ Arquitectura

El proyecto sigue los principios de **Clean Architecture** con 3 capas principales:

```
┌─────────────────────────────────────────────────────┐
│         PRESENTATION LAYER (UI)                     │
│  - Widgets/Pages                                    │
│  - BLoC (State Management)                          │
│  - Dependency Injection (GetIt + Injectable)        │
└─────────────────────────────────────────────────────┘
                         ▲
                         │
┌─────────────────────────────────────────────────────┐
│         DOMAIN LAYER (Lógica de Negocio)            │
│  - Entities (objetos de negocio)                    │
│  - Use Cases (casos de uso)                         │
│  - Repository Interfaces (contratos)                │
└─────────────────────────────────────────────────────┘
                         ▲
                         │
┌─────────────────────────────────────────────────────┐
│         DATA LAYER (Acceso a Datos)                 │
│  - Repository Implementations                       │
│  - DataSources (Remote/Local)                       │
│  - Models (DTOs)                                    │
└─────────────────────────────────────────────────────┘
                         ▲
                         │
                  ┌──────▼────────┐
                  │   SUPABASE    │
                  │ (Backend)     │
                  └───────────────┘
```

### Patrones de Diseño Utilizados

1. **BLoC Pattern**: State management reactivo
2. **Repository Pattern**: Abstracción del acceso a datos
3. **Either Pattern**: Manejo funcional de errores (Dartz)
4. **Factory Pattern**: Creación de objetos
5. **Observer Pattern**: Escucha de eventos en tiempo real

### Servicios Globales

- **Dependency Injection**: GetIt + Injectable
- **Navigation Service**: Manejo global de rutas
- **Avatar Service**: Gestión de imágenes de perfil
- **PDF Generator**: Generación de contratos
- **Global Message Listener**: Escucha de mensajes en tiempo real

---

## 📚 Documentación Técnica Completa

Toda la documentación técnica está organizada en la carpeta `docs/`:

| Documento | Descripción |
|-----------|-------------|
| [📐 ARQUITECTURA.md](docs/ARQUITECTURA.md) | Arquitectura del sistema, diagramas de componentes, patrones de diseño |
| [🗄️ MODELO_DATOS.md](docs/MODELO_DATOS.md) | Diagrama ER, 13 tablas, relaciones, RPCs, RLS policies |
| [🔌 API.md](docs/API.md) | Documentación de API: 20+ endpoints, parámetros, respuestas, ejemplos |
| [🚀 DESPLIEGUE.md](docs/DESPLIEGUE.md) | Manual de despliegue: setup local, builds Android/iOS/Web, troubleshooting |
| [📦 GITHUB_REPOSITORY.md](docs/GITHUB_REPOSITORY.md) | Información del repositorio, branching strategy, commits, PRs |
| [💼 MODELO_NEGOCIO.md](docs/MODELO_NEGOCIO.md) | Business Model Canvas completo |
| [📊 ANALISIS_COMPETENCIA.md](docs/ANALISIS_COMPETENCIA.md) | Análisis competitivo y posicionamiento |

---

## 📑 Índice de Requisitos Técnicos

### 1. Arquitectura del Sistema

**Documento:** [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md)

- **1.1** Introducción y Antecedentes
- **1.2** Diagrama de Componentes y Servicios
  - 1.2.1 Componentes Principales
  - 1.2.2 Servicios Clave
  - 1.2.3 Patrones de Diseño
  - 1.2.4 Capas de Arquitectura
- **1.3** Flujos de Datos Explicados
  - 1.3.1 Flujo de Autenticación
  - 1.3.2 Flujo de Listings Real-time
  - 1.3.3 Flujo de Matching
- **1.4** Módulos del Proyecto (13 features)

### 2. Modelo de Datos

**Documento:** [docs/MODELO_DATOS.md](docs/MODELO_DATOS.md)

- **2.1** Introducción y Estructura
- **2.2** Diagrama ER (Entity-Relationship)
- **2.3** Entidades Principales
  - 2.3.1 Tablas de Autenticación y Perfiles
  - 2.3.2 Tablas de Listings y Propiedades
  - 2.3.3 Tablas de Social y Matching
  - 2.3.4 Tablas de Operaciones
- **2.4** Relaciones Entre Entidades
  - 2.4.1 Relaciones 1:1
  - 2.4.2 Relaciones 1:N
  - 2.4.3 Relaciones N:M
- **2.5** Funciones PostgreSQL (RPCs)
- **2.6** Row Level Security (RLS)
- **2.7** Índices de Optimización

### 3. Documentación de API

**Documento:** [docs/API.md](docs/API.md)

- **3.1** Introducción a la API
- **3.2** Endpoints de Autenticación
- **3.3** Endpoints de Profiles
- **3.4** Endpoints de Listings
- **3.5** Endpoints de Messages y Chat
- **3.6** Endpoints de User Interactions (Matching)
- **3.7** Endpoints de Listing Requests
- **3.8** Remote Procedure Calls (RPCs)
- **3.9** Real-time Subscriptions
- **3.10** Códigos de Error
- **3.11** Ejemplos de Uso en Flutter (50+ ejemplos)

### 4. Manual de Despliegue

**Documento:** [docs/DESPLIEGUE.md](docs/DESPLIEGUE.md)

- **4.1** Introducción y Prerequisitos
- **4.2** Setup Local Paso a Paso
- **4.3** Configuración de Supabase
- **4.4** Build para Android
- **4.5** Build para iOS
- **4.6** Build para Web
- **4.7** Troubleshooting
- **4.8** Checklist Pre-Producción

### 5. Repositorio GitHub

**URL:** https://github.com/jmvillanueva-dev/HAUS-Mobil-App

**Documento:** [docs/GITHUB_REPOSITORY.md](docs/GITHUB_REPOSITORY.md)

- **5.1** Información del Repositorio
- **5.2** Instrucciones de Clonación
- **5.3** Estructura de Carpetas
- **5.4** Ramas del Repositorio
- **5.5** Estándar de Commits
- **5.6** Pull Request Workflow

---

## ⚡ Guía Rápida

### Comandos Esenciales

```bash
# Clonar proyecto
git clone https://github.com/jmvillanueva-dev/HAUS-Mobil-App
cd HAUS-Mobil-App

# Instalar dependencias
flutter pub get

# Generar código
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar app
flutter run

# Ejecutar tests
flutter test

# Limpiar build
flutter clean

# Generar APK (Android)
flutter build apk

# Generar AAB (Play Store)
flutter build appbundle

# Generar IPA (iOS)
flutter build ios

# Generar Web
flutter build web
```

### Estructura de Features

Cada feature sigue esta estructura:

```
lib/features/{feature_name}/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

### Tecnologías Clave

| Categoría | Tecnología |
|-----------|-----------|
| **Framework** | Flutter 3.6.2+ |
| **Lenguaje** | Dart 3.0+ |
| **Backend** | Supabase (PostgreSQL, Auth, Realtime, Storage) |
| **State Management** | Flutter BLoC 8.1+ |
| **Dependency Injection** | GetIt 8.0+ + Injectable 2.5+ |
| **Funcional Programming** | Dartz 0.10+ (Either pattern) |
| **HTTP Client** | Dio 5.0+ |
| **Real-time** | Supabase Realtime (WebSocket) |
| **Local Storage** | SharedPreferences, Hive |
| **Navigation** | GoRouter |
| **Testing** | Mockito, Bloc Test |

---

## 📁 Estructura del Proyecto

```
HAUS-Mobil-App/
├── lib/
│   ├── main.dart                    # Entry point de la app
│   ├── injection_container.dart     # Setup de DI (GetIt + Injectable)
│   ├── core/                        # Código compartido global
│   │   ├── errors/                  # Excepciones y Failures
│   │   ├── usecases/                # UseCase base
│   │   ├── utils/                   # Utilidades
│   │   ├── services/                # Servicios globales
│   │   │   ├── navigation/          # Navigation Service
│   │   │   ├── avatar/              # Avatar Service
│   │   │   └── pdf/                 # PDF Generator
│   │   └── theme/                   # Tema de la app
│   └── features/                    # 13 módulos de features
│       ├── auth/                    # Autenticación
│       ├── profile/                 # Perfiles de usuario
│       ├── matching/                # Algoritmo de matching
│       ├── listings/                # Propiedades
│       ├── chat/                    # Mensajería
│       ├── requests/                # Solicitudes de alquiler
│       ├── notifications/           # Notificaciones
│       ├── financial/               # Gestión financiera
│       ├── subscription/            # Suscripciones
│       ├── locations/               # Geolocalización
│       ├── connections/             # Conexiones entre usuarios
│       ├── explore/                 # Exploración
│       └── onboarding/              # Setup inicial
│
├── database/                        # Scripts SQL de Supabase
│   ├── 00_init_extensions.sql
│   ├── 01_auth_schema.sql
│   ├── 02_user_locations.sql
│   ├── 03_listing.sql
│   ├── ... (24 archivos SQL)
│   ├── RLS_policies.sql             # Row Level Security
│   └── README.md
│
├── docs/                            # Documentación técnica
│   ├── ARQUITECTURA.md              # 3,500+ líneas
│   ├── MODELO_DATOS.md              # 2,800+ líneas
│   ├── API.md                       # 2,200+ líneas
│   ├── DESPLIEGUE.md                # 2,100+ líneas
│   ├── GITHUB_REPOSITORY.md         # 1,800+ líneas
│   ├── MODELO_NEGOCIO.md            # 2,000+ líneas
│   └── ANALISIS_COMPETENCIA.md      # 2,200+ líneas
│
├── android/                         # Configuración Android
├── ios/                             # Configuración iOS
├── web/                             # Configuración Web
├── test/                            # Tests unitarios
├── pubspec.yaml                     # Dependencias del proyecto
├── .env                             # Variables de entorno (no committed)
├── .env.example                     # Template de variables
└── README.md                        # Este archivo
```

---

## 🧪 Testing

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Tests con coverage
flutter test --coverage

# Test específico
flutter test test/features/auth/auth_test.dart
```

### Estructura de Tests

```
test/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── ... (otros features)
└── core/
```

---

## 🤝 Contribuir

### Workflow de Desarrollo

1. **Fork** el repositorio
2. Crea una rama para tu feature: `git checkout -b feature/nueva-funcionalidad`
3. Haz commits usando **Conventional Commits**:
   - `feat: agregar algoritmo de matching`
   - `fix: corregir bug en login`
   - `docs: actualizar README`
   - `style: formatear código`
   - `refactor: reorganizar estructura`
   - `test: agregar tests unitarios`
   - `chore: actualizar dependencias`
4. Push a tu rama: `git push origin feature/nueva-funcionalidad`
5. Crea un **Pull Request** a la rama `develop`

### Estrategia de Branches

| Rama | Propósito | Merge desde |
|------|----------|-------------|
| **main** | Producción estable | develop (solo PRs) |
| **develop** | Staging/Integración | feature/*, bugfix/* |
| **feature/** | Nuevas funcionalidades | develop |
| **bugfix/** | Correcciones de bugs | develop |
| **hotfix/** | Fixes urgentes | main |

### Estándares de Código

- Seguir el análisis estático de Flutter (`analysis_options.yaml`)
- Documentar funciones públicas
- Escribir tests para nueva lógica
- Mantener cobertura > 70%

---

## 📄 Licencia

MIT License

Copyright (c) 2025 HAUS Mobil App

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## 📞 Contacto y Soporte

- **Repositorio**: https://github.com/jmvillanueva-dev/HAUS-Mobil-App
- **Documentación Completa**: Ver carpeta `docs/`
- **Issues**: https://github.com/jmvillanueva-dev/HAUS-Mobil-App/issues

---

## 📊 Estadísticas del Proyecto

- **7 archivos de documentación** técnica y de negocio
- **24,000+ líneas** de documentación
- **80,000+ palabras** de contenido
- **13 módulos** de features
- **13 tablas** en base de datos
- **20+ endpoints** REST
- **6+ funciones** PostgreSQL (RPCs)
- **50+ ejemplos** de código Dart
- **75+ ejemplos** de código en general

---

## ✅ Verificación de Requisitos Técnicos (6.2)

| # | Requisito | Documento | Status |
|---|-----------|-----------|--------|
| 1 | Arquitectura del Sistema: Diagrama de componentes y servicios | [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) | ✅ |
| 2 | Modelo de Datos: Diagrama ER de la base de datos en Supabase | [docs/MODELO_DATOS.md](docs/MODELO_DATOS.md) | ✅ |
| 3 | Documentación de API: Endpoints, parámetros, respuestas | [docs/API.md](docs/API.md) | ✅ |
| 4 | Manual de Despliegue: Instrucciones para replicar el ambiente | [docs/DESPLIEGUE.md](docs/DESPLIEGUE.md) | ✅ |
| 5 | Enlace al repositorio Github: README con Instalación, configuración, ejecución | Este archivo + [docs/GITHUB_REPOSITORY.md](docs/GITHUB_REPOSITORY.md) | ✅ |

**Todos los requisitos técnicos cumplidos ✅**

---

<div align="center">

**Hecho con ❤️ por el equipo de HAUS**

</div>
