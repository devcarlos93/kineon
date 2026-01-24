# 🎬 Kineon

Una aplicación Flutter moderna para películas y series, con recomendaciones impulsadas por IA.

## ✨ Características

- 🏠 **Inicio**: Explora películas y series en tendencia, populares y mejor valoradas
- 🔍 **Búsqueda**: Encuentra cualquier película o serie con filtros avanzados
- 🤖 **Asistente IA**: Obtén recomendaciones personalizadas conversando con la IA
- 📚 **Biblioteca**: Gestiona tu watchlist, favoritos, historial y listas personalizadas

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con la siguiente estructura:

```
lib/
├── core/                    # Componentes compartidos
│   ├── constants/           # Constantes de la app
│   ├── errors/              # Manejo de errores y excepciones
│   ├── network/             # Configuración de red y Supabase
│   ├── router/              # Configuración de navegación
│   ├── theme/               # Tema y estilos
│   └── widgets/             # Widgets reutilizables
│
├── features/                # Módulos por feature
│   ├── auth/                # Autenticación
│   ├── home/                # Pantalla principal
│   ├── search/              # Búsqueda
│   ├── ai/                  # Asistente IA
│   ├── library/             # Biblioteca del usuario
│   └── movie_details/       # Detalles de película/serie
│
└── main.dart               # Punto de entrada
```

Cada feature sigue el patrón:
```
feature/
├── data/
│   ├── datasources/        # Fuentes de datos (API, local)
│   ├── models/             # Modelos de datos
│   └── repositories/       # Implementación de repositorios
├── domain/
│   ├── entities/           # Entidades de dominio
│   ├── repositories/       # Interfaces de repositorios
│   └── usecases/          # Casos de uso
└── presentation/
    ├── providers/          # Providers de Riverpod
    ├── screens/            # Pantallas
    └── widgets/            # Widgets del feature
```

## 🛠️ Stack Tecnológico

- **Flutter 3.x** - Framework UI
- **Riverpod** - State Management
- **GoRouter** - Navegación
- **Supabase** - Backend (Auth, Database, Storage, Edge Functions)
- **TMDB API** - Datos de películas/series
- **OpenAI** - Recomendaciones IA

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter_riverpod: ^2.5.1      # State management
  go_router: ^14.2.0            # Routing
  supabase_flutter: ^2.5.9      # Backend
  cached_network_image: ^3.4.1  # Cache de imágenes
  flutter_animate: ^4.5.0       # Animaciones
  dartz: ^0.10.1               # Functional programming
```

## 🚀 Configuración

### 1. Requisitos previos

- Flutter SDK ^3.9.2
- Cuenta de Supabase
- API Key de TMDB
- API Key de OpenAI (opcional, para IA)

### 2. Clonar y configurar

```bash
# Clonar repositorio
git clone <repo-url>
cd kineon

# Instalar dependencias
flutter pub get
```

### 3. Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com)
2. Ejecuta el SQL de migración:
   ```bash
   # En Supabase SQL Editor, ejecuta:
   # supabase/migrations/00001_initial_schema.sql
   ```
3. Configura las Edge Functions:
   ```bash
   # Instala Supabase CLI
   npm install -g supabase
   
   # Despliega las funciones
   cd supabase
   supabase functions deploy tmdb-proxy
   supabase functions deploy ai-recommendations
   supabase functions deploy ai-chat
   ```
4. Configura los secrets:
   ```bash
   supabase secrets set TMDB_API_KEY=tu_api_key
   supabase secrets set OPENAI_API_KEY=tu_api_key
   ```

### 4. Ejecutar la app

```bash
# Desarrollo (reemplaza con tus valores)
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu_anon_key

# O crea un archivo .env y usa flutter_dotenv
```

## 🔐 Seguridad

- ✅ Las API keys de TMDB y OpenAI **nunca** se exponen al cliente
- ✅ Todo el acceso a APIs externas pasa por Edge Functions
- ✅ Row Level Security (RLS) habilitado en todas las tablas
- ✅ Autenticación segura con Supabase Auth
- ✅ Los tokens se pasan como variables de entorno en tiempo de compilación

## 📱 Capturas de Pantalla

*Próximamente*

## 🗺️ Roadmap

- [ ] Modo offline con caché local
- [ ] Notificaciones de nuevos estrenos
- [ ] Compartir listas con amigos
- [ ] Widget de iOS/Android
- [ ] Soporte para múltiples idiomas

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para detalles.

---

Desarrollado con ❤️ usando Flutter y Supabase
