# 📦 Información del Repositorio GitHub

## URL del Repositorio

```
https://github.com/jmvillanueva-dev/HAUS-Mobil-App
```

---

## Acceso al Repositorio

### Clonar el proyecto

```bash
# Clone using HTTPS (recomendado si no tienes SSH configurado)
git clone https://github.com/jmvillanueva-dev/HAUS-Mobil-App.git

# Clone using SSH (si tienes SSH key configurada)
git clone git@github.com:jmvillanueva-dev/HAUS-Mobil-App.git

# Clone with specific depth (más rápido para repos grandes)
git clone --depth 1 https://github.com/jmvillanueva-dev/HAUS-Mobil-App.git
```

### Navegar al directorio

```bash
cd HAUS-Mobil-App
```

---

## Estructura del Repositorio en GitHub

```
jmvillanueva-dev/HAUS-Mobil-App/
│
├── 📄 README.md                 # README principal (ACTUALIZADO)
├── 📄 README_NEW.md             # README completo con documentación
├── 📝 LICENSE                   # Licencia MIT
├── 📦 pubspec.yaml              # Dependencias Flutter
│
├── 📁 lib/                      # Código fuente
│   ├── core/                    # Servicios compartidos
│   ├── features/                # Módulos de features
│   ├── main.dart                # Punto de entrada
│   └── injection_container.dart # Inyección de dependencias
│
├── 📁 docs/                     # DOCUMENTACIÓN TÉCNICA (NUEVA)
│   ├── ARQUITECTURA.md          # Diagrama de componentes y capas
│   ├── MODELO_DATOS.md          # Diagrama ER y esquema BD
│   ├── API.md                   # Endpoints y RPCs
│   └── DESPLIEGUE.md            # Manual de instalación y despliegue
│
├── 📁 database/                 # Scripts de inicialización BD
│   ├── 00_init_extensions.sql
│   ├── 01_auth_schema.sql
│   ├── 02_user_locations.sql
│   └── ... (más scripts)
│
├── 📁 android/                  # Configuración Android
│   └── app/
│       ├── build.gradle
│       └── src/
│
├── 📁 ios/                      # Configuración iOS
│   ├── Runner.xcodeproj/
│   └── Runner.xcworkspace/
│
├── 📁 test/                     # Tests unitarios y de widget
│   └── widget_test.dart
│
├── 📁 build/                    # Artefactos de compilación (Git ignored)
│   └── ... (excluido de versionado)
│
└── 📁 .github/                  # Configuración de GitHub
    ├── workflows/               # CI/CD (si está configurado)
    └── ISSUE_TEMPLATE/          # Templates para issues
```

---

## Ramas Principales

### `main` (Rama Principal)
- **Propósito**: Código en producción
- **Protección**: Requiere Pull Request y review
- **Versión**: Release estable

### `develop` (Rama de Desarrollo)
- **Propósito**: Integración de features
- **Flujo**: Feature branches → develop → main

### `feature/*` (Ramas de Features)
- **Formato**: `feature/matching-algorithm`, `feature/chat-system`
- **Temporalidad**: Se eliminan después de merge

### `bugfix/*` (Ramas de Correcciones)
- **Formato**: `bugfix/login-issue`, `bugfix/crash-on-startup`
- **Temporalidad**: Se eliminan después de merge

---

## Workflows Git Recomendados

### Crear una nueva feature

```bash
# 1. Actualizar develop
git checkout develop
git pull origin develop

# 2. Crear rama de feature
git checkout -b feature/my-amazing-feature

# 3. Hacer cambios y commits
git add .
git commit -m "feat: add amazing feature"

# 4. Push a la rama remota
git push origin feature/my-amazing-feature

# 5. Abrir Pull Request en GitHub
# (Ir a https://github.com/jmvillanueva-dev/HAUS-Mobil-App/pulls)

# 6. Después del review y merge, eliminar rama local
git checkout develop
git pull origin develop
git branch -d feature/my-amazing-feature
```

### Sincronizar con cambios remotos

```bash
# Traer los últimos cambios
git fetch origin

# Ver diferencias
git log --oneline origin/main ^main

# Merge de cambios
git merge origin/main

# O pull (fetch + merge en uno)
git pull origin main
```

---

## Estándar de Commits

### Formato de Commit Message

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Tipos de Commit

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| `feat` | Nueva feature | `feat(matching): add compatibility algorithm` |
| `fix` | Corrección de bug | `fix(chat): fix message not showing` |
| `docs` | Documentación | `docs: update README` |
| `style` | Formato de código | `style: format code with dart format` |
| `refactor` | Refactorización | `refactor(auth): simplify login flow` |
| `test` | Tests | `test(auth): add login unit tests` |
| `chore` | Tareas mantenimiento | `chore: update dependencies` |

### Ejemplos

```bash
# Feature
git commit -m "feat(listings): add search filters for price"

# Bugfix
git commit -m "fix(notifications): fix null pointer exception"

# Documentation
git commit -m "docs: add API documentation"

# Con descripción
git commit -m "feat(matching): implement compatibility scoring

- Added 15-factor compatibility calculation
- Implemented caching for performance
- Added unit tests for scoring algorithm"
```

---

## Configuración de Git

### Configuración local (por proyecto)

```bash
# Desde el directorio del proyecto
git config user.name "Tu Nombre"
git config user.email "tu.email@example.com"

# Verificar
git config --list --local
```

### Configuración global

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu.email@example.com"

# Verificar
git config --list
```

### Alias útiles

```bash
# Crear aliases en ~/.gitconfig o ~/.git-aliases

git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.log-oneline "log --oneline"
git config --global alias.log-graph "log --graph --oneline --all"

# Uso
git st      # equivalente a git status
git co main # equivalente a git checkout main
```

---

## Issues y Pull Requests

### Crear un Issue

1. Ir a **Issues** en el repositorio
2. Click en **New issue**
3. Seleccionar template:
   - 🐛 **Bug report**: Para reportar bugs
   - ✨ **Feature request**: Para solicitar nuevas features
   - 📚 **Documentation**: Para mejoras en documentación

### Crear un Pull Request

1. Hacer push de tu rama
2. Ir a **Pull requests**
3. Click en **New pull request**
4. Seleccionar:
   - **Base**: `develop` o `main`
   - **Compare**: Tu rama de feature
5. Completar el template con:
   - Descripción de cambios
   - Referencia a issues relacionados (#123)
   - Screenshot (si aplica)
   - Checklist de testing

---

## Protecciones de Rama

### Configuración recomendada para `main`

1. **Require pull request reviews before merging**
   - Mínimo 1 reviewer
   - Dismiss stale pull request approvals when new commits are pushed

2. **Require status checks to pass before merging**
   - Require branches to be up to date before merging
   - CI/CD checks (GitHub Actions)

3. **Require code reviews from code owners**
   - CODEOWNERS file

---

## Badges para README

### Build Status
```markdown
[![Flutter](https://img.shields.io/badge/Flutter-3.6.2%2B-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0.0%2B-blue)](https://dart.dev)
```

### License
```markdown
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
```

### Stats
```markdown
![GitHub stars](https://img.shields.io/github/stars/jmvillanueva-dev/HAUS-Mobil-App)
![GitHub forks](https://img.shields.io/github/forks/jmvillanueva-dev/HAUS-Mobil-App)
![GitHub issues](https://img.shields.io/github/issues/jmvillanueva-dev/HAUS-Mobil-App)
```

---

## Sincronización con Fork

Si trabajas desde un fork:

```bash
# Agregar upstream (solo la primera vez)
git remote add upstream https://github.com/jmvillanueva-dev/HAUS-Mobil-App.git

# Traer cambios del proyecto original
git fetch upstream

# Sincronizar tu rama local
git rebase upstream/main

# Hacer push a tu fork
git push origin main --force-with-lease
```

---

## CI/CD (GitHub Actions)

### Workflows configurados (si existen)

```bash
# Ver workflows disponibles
ls .github/workflows/
```

### Tipos de workflows útiles

1. **Test Workflow**
   - Ejecuta: `flutter test`
   - Trigger: En cada push y PR

2. **Build Workflow**
   - Ejecuta: `flutter build`
   - Genera: APK/AAB para testing

3. **Deploy Workflow**
   - Publish automático a App Stores
   - Trigger: En releases

---

## Comandos Git Útiles

```bash
# Ver estado
git status

# Ver diferencias
git diff
git diff --staged

# Ver historial
git log --oneline
git log --graph --all --oneline

# Deshacer cambios
git restore <file>              # Descartar cambios en archivo
git reset HEAD <file>           # Unstage
git revert <commit>             # Crear nuevo commit que deshace cambios

# Stash (guardar cambios temporalmente)
git stash
git stash list
git stash apply
git stash pop

# Rebase interactivo
git rebase -i HEAD~5            # Últimos 5 commits

# Cherry-pick (copiar un commit)
git cherry-pick <commit-hash>

# Crear etiquetas
git tag v1.0.0
git push origin --tags
```

---

## Seguridad

### Variables Sensibles

- **NUNCA** hacer commit de:
  - `.env` files
  - API keys
  - Private credentials
  - Keystore passwords

### Verificar antes de Push

```bash
# Escanear por secrets antes de push
git diff HEAD origin/main | grep -E "SUPABASE_|API_|PASSWORD"

# Limpieza de historial (si accidentalmente commiteaste un secret)
git filter-branch --tree-filter 'rm -f .env' --prune-empty HEAD
```

---

## Recursos Adicionales

- [Documentación oficial de Git](https://git-scm.com/doc)
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

---

**Última actualización**: Enero 2026  
**Repositorio**: https://github.com/jmvillanueva-dev/HAUS-Mobil-App
