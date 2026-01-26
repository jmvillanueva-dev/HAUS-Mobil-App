# 📦 Manual de Despliegue

## Índice
1. [Requisitos Previos](#requisitos-previos)
2. [Setup Local (Desarrollo)](#setup-local-desarrollo)
3. [Configuración de Supabase](#configuración-de-supabase)
4. [Despliegue en Android](#despliegue-en-android)
5. [Despliegue en iOS](#despliegue-en-ios)
6. [Despliegue en Web](#despliegue-en-web)
7. [Troubleshooting](#troubleshooting)
8. [Checklist de Pre-producción](#checklist-de-pre-producción)

---

## Requisitos Previos

### Software Requerido

1. **Flutter SDK** ^3.6.2
   - Descargar desde: https://flutter.dev/docs/get-started/install
   - Verificar: `flutter --version`

2. **Dart SDK** (incluido en Flutter)
   - Verificar: `dart --version`

3. **Git** 2.30+
   - Descargar desde: https://git-scm.com/

4. **Android Studio** (para Android)
   - Descargar desde: https://developer.android.com/studio
   - Incluye: Android SDK, emulador

5. **Xcode** (para iOS - solo macOS)
   - Descargar desde: Mac App Store
   - Requisito mínimo: macOS 12.0+

6. **Visual Studio Code** (recomendado)
   - Descargar desde: https://code.visualstudio.com/
   - Instalar extensiones: Flutter, Dart

---

## Setup Local (Desarrollo)

### 1. Clonar el repositorio

```bash
git clone https://github.com/jmvillanueva-dev/HAUS-Mobil-App.git
cd HAUS-Mobil-App
```

### 2. Verificar dispositivos disponibles

```bash
flutter devices
```

**Expected output:**
```
1 connected device:

emulator-5554 • Android SDK built for x86 • android-x86 • Android 13 (API 33)
```

O conectar un dispositivo físico:
```bash
flutter devices
# Debe aparecer tu dispositivo físico
```

### 3. Instalar dependencias

```bash
flutter pub get
```

**Output esperado:**
```
Running "flutter pub get" in HAUS-Mobil-App...
Get: dependencies
Get: dev_dependencies
...
Resolving dependencies... 
✓ Got dependencies in 45s
```

### 4. Generar código inyectable

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Output esperado:**
```
Running "flutter pub run build_runner build"...
...
✓ Built 42 `.dart` files.
...
Build complete
```

### 5. Configurar variables de entorno

Crear archivo `.env` en la raíz del proyecto:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Web Base URL (para verificación de email, reset de contraseña)
WEB_BASE_URL=https://your-domain.com
```

**⚠️ IMPORTANTE**: No commitear `.env` a Git. Agregar a `.gitignore`:
```
.env
.env.local
```

### 6. Ejecutar la app en desarrollo

#### En emulador Android:
```bash
flutter run -d emulator-5554
```

#### En dispositivo físico:
```bash
flutter run
```

#### En web (experimental):
```bash
flutter run -d chrome
```

**Output esperado:**
```
Launching lib/main.dart on Android SDK built for x86...
...
🔨 Building app for Android...
✓ Built build/app/outputs/flutter-app-debug.apk...
Installing build/app/outputs/flutter-app-debug.apk...
✓ Installed build/app/outputs/flutter-app-debug.apk...
Launching lib/main.dart on emulator...
✓ App launched on Android device (emulator-5554).
```

---

## Configuración de Supabase

### 1. Crear proyecto en Supabase

1. Ir a https://supabase.com/dashboard
2. Hacer login o registrarse
3. Crear nuevo proyecto
4. Seleccionar región (preferentemente cercana al público objetivo)
5. Generar contraseña segura para el DB

**Tiempo de creación**: ~2-3 minutos

### 2. Obtener credenciales

En el dashboard del proyecto:
- **Project URL**: https://your-project-id.supabase.co
- **Anon Key**: visible en Settings → API

Agregar estas credenciales al archivo `.env`

### 3. Ejecutar scripts de inicialización de BD

1. Ir a **SQL Editor** en Supabase
2. Ejecutar los scripts en orden numérico de la carpeta `database/`:

```bash
# Orden de ejecución:
00_init_extensions.sql      # Extensiones PostgreSQL
01_auth_schema.sql          # Tabla profiles
02_user_locations.sql       # Ubicaciones de usuarios
03_listing.sql              # Publicaciones de habitaciones
04_onboarding_profile.sql   # Onboarding data
05_chat.sql                 # Conversaciones y mensajes
05_enable_realtime.sql      # Habilitar Realtime
06_chat_rls.sql             # Políticas de seguridad chat
06_notifications.sql        # Sistema de notificaciones
07_user_preferences.sql     # Preferencias de estilo de vida
08_matching.sql             # Interacciones y matching
... (continuar hasta el final)
```

**Importante**: Ejecutar **en orden numérico**. Algunos scripts tienen dependencias.

### 4. Verificar políticas de RLS

En **Authentication → Policies**, verificar que existan políticas para:
- profiles (select own, update own)
- listings (select own + public available)
- conversations (select own)
- messages (select/insert own)
- notifications (select own)

### 5. Configurar Storage (para avatares)

1. Ir a **Storage** en Supabase
2. Crear bucket: `avatars`
3. Configurar permisos públicos para SELECT, pero restringir INSERT/UPDATE a usuarios autenticados

**Política de seguridad recomendada:**
```sql
-- Permitir que usuarios suban solo sus avatares
CREATE POLICY "Users can upload their own avatars"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Permitir lectura pública
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

---

## Despliegue en Android

### 1. Configurar Android Studio

```bash
flutter config --android-studio-dir="/path/to/Android/Studio"
```

### 2. Generar keystore (firma digital)

Necesario para publicar en Play Store.

```bash
keytool -genkey -v -keystore ~/haus_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias haus_key
```

**Preguntas interactivas:**
- Contraseña del keystore: ___(Guardar seguro)___
- Nombre: Juan Villanueva
- Organización: HAUS
- Ciudad: Medellín
- País: CO
- Alias: haus_key

### 3. Configurar firma en app

Crear `android/key.properties`:

```properties
storePassword=<contraseña-keystore>
keyPassword=<contraseña-alias>
keyAlias=haus_key
storeFile=<ruta-absoluta>/haus_key.jks
```

Editar `android/app/build.gradle`:

```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 4. Construir APK/AAB

#### APK (para testing):
```bash
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-app-release.apk`

#### AAB (para Play Store):
```bash
flutter build appbundle --release
```

**Output**: `build/app/outputs/app-release.aab`

### 5. Publicar en Google Play Store

1. Ir a https://play.google.com/console
2. Crear aplicación nueva
3. Subir AAB en **Internal testing → Releases**
4. Configurar:
   - Store listing (descripción, screenshots)
   - Pricing and distribution
   - Content rating
5. Revisar y publicar

**Tiempo de revisión**: 2-4 horas

---

## Despliegue en iOS

### 1. Configurar certificados

Requiere macOS y una cuenta de Apple Developer ($99/año).

```bash
cd ios
pod repo update
cd ..
```

### 2. Configurar código de firma

En Xcode:
1. Abrir `ios/Runner.xcworkspace`
2. Seleccionar target "Runner"
3. En "Build Settings" → Signing:
   - Team ID: Tu ID de equipo de Apple
   - Provisioning Profile: Seleccionar perfil

### 3. Construir para iOS

```bash
flutter build ios --release
```

### 4. Crear archivo IPA

```bash
cd build/ios/iphoneos
mkdir Payload
cp -r Runner.app Payload/
zip -r app.ipa Payload/
cd ../../../
```

**Output**: `build/ios/iphoneos/app.ipa`

### 5. Publicar en App Store

1. Ir a https://appstoreconnect.apple.com
2. Crear nueva app
3. Usar **Transporter** para subir IPA:
   ```bash
   xcrun altool --upload-app -f build/ios/iphoneos/app.ipa -t ios -u email@apple.com -p app-specific-password
   ```

**Tiempo de revisión**: 24-48 horas

---

## Despliegue en Web

### 1. Construir para web

```bash
flutter build web --release
```

**Output**: `build/web/`

### 2. Deploying en Firebase Hosting (recomendado)

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar proyecto
firebase init hosting

# Publicar
firebase deploy
```

### 3. Alternativa: Vercel

```bash
npm i -g vercel
vercel --prod
```

---

## Troubleshooting

### Error: "Flutter command not found"

**Solución:**
```bash
# Agregar Flutter al PATH
export PATH="$PATH:/ruta/al/flutter/bin"

# O agregar permanentemente en ~/.bashrc o ~/.zshrc
echo 'export PATH="$PATH:/ruta/al/flutter/bin"' >> ~/.bashrc
```

### Error: "No devices found"

```bash
# Encender emulador
emulator -list-avds  # Listar emuladores
emulator -avd emulator_name  # Encender

# O conectar dispositivo físico
adb devices  # Listar dispositivos conectados
```

### Error: "Gradle build failed"

```bash
# Limpiar caché
flutter clean

# Intentar de nuevo
flutter pub get
flutter run
```

### Error: "Pod install error" (iOS)

```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
```

### Error: "Supabase connection refused"

1. Verificar que SUPABASE_URL y SUPABASE_ANON_KEY son correctos
2. Verificar que el proyecto Supabase está activo
3. Verificar conexión a internet
4. Revisar logs en Supabase Dashboard

### Error: "RLS policy denied"

Las políticas de seguridad podrían estar bloqueando las operaciones. Verificar en el SQL Editor de Supabase.

---

## Checklist de Pre-producción

- [ ] Credenciales de Supabase correctas y seguras
- [ ] Todos los scripts de DB ejecutados en orden
- [ ] Política de RLS configuradas correctamente
- [ ] Storage buckets creados y securizados
- [ ] Variables de entorno (.env) NO commiteadas a Git
- [ ] Keystore Android guardado en lugar seguro
- [ ] Certificados Apple válidos y no expirados
- [ ] Tests ejecutados exitosamente: `flutter test`
- [ ] App funcionando en emulador/device
- [ ] Logs del servidor sin errores
- [ ] Privacidad y política de términos listos
- [ ] Screenshots y descripción de la app preparados
- [ ] Rating y comentarios preparados para responder
- [ ] Monitoreo de errores configurado (Sentry, Firebase Crashlytics)

---

## Comandos Útiles de Desarrollo

```bash
# Limpiar y rebuilds
flutter clean
flutter pub get

# Generar código
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar con hot reload
flutter run

# Ejecutar tests
flutter test

# Análisis de código
flutter analyze

# Generar APK/AAB
flutter build apk --release
flutter build appbundle --release

# Generar web
flutter build web --release

# Ver logs
flutter logs

# Ver versiones instaladas
flutter doctor -v
```

---

## Monitoreo en Producción

### Firebase Crashlytics (recomendado)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  await Firebase.initializeApp();
  
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };
  
  runApp(const HausApp());
}
```

### Sentry

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) => options.dsn = 'https://your-sentry-dsn@sentry.io/project-id',
  );
  
  runApp(const HausApp());
}
```

---

**Última actualización**: Enero 2026
**Versión de documentación**: 1.0
**Flutter SDK mínimo**: 3.6.2
