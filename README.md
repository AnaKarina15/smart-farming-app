markdown# AgroField - Plataforma de Agricultura Inteligente

Plataforma digital para pequenos productores del Magdalena con backend NestJS y frontend Flutter.

## Estructura del proyecto
agrofield/
├── backend/        # API REST en NestJS + PostgreSQL
└── frontend/       # App movil/web en Flutter

## Requisitos previos

Antes de empezar, instala:

| Software | Version | Descarga |
|----------|---------|----------|
| Node.js | v20+ | https://nodejs.org |
| Docker Desktop | Reciente | https://www.docker.com/products/docker-desktop |
| Flutter SDK | 3.27+ | https://docs.flutter.dev/get-started/install |
| Git | Reciente | https://git-scm.com |
| Java JDK | 17 | https://adoptium.net |

Verifica con:

```bash
node --version
docker --version
flutter --version
java -version
```

## Backend - Levantar la API

### 1. Entrar al backend

```bash
cd backend
```

### 2. Instalar dependencias

```bash
npm install
```

### 3. Configurar variables de entorno

Copia `.env.example` a `.env`:

```bash
# Windows PowerShell
Copy-Item .env.example .env

# Linux/Mac
cp .env.example .env
```

### 4. Levantar PostgreSQL en Docker

```bash
docker compose up -d
```

Esto levanta:
- PostgreSQL en `localhost:5432`
- pgAdmin en `localhost:5050` (admin@agrofield.local / admin)

### 5. Correr migraciones de la base de datos

```bash
npm run migration:run
```

### 6. Arrancar el servidor

```bash
npm run start:dev
```

Quedara en: http://localhost:3000

Swagger UI: http://localhost:3000/api/docs

## Frontend - Levantar la app

### 1. Entrar al frontend

```bash
cd frontend
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar URL del backend (si no es localhost:3000)

Edita `lib/core/network/api_endpoints.dart`:

```dart
static const String baseUrl = 'http://TU_HOST:3000/api/v1';
```

### 4. Correr la app

**En navegador (recomendado para desarrollo):**

```bash
flutter run -d chrome --web-port 8080
```

**En emulador Android:**

```bash
flutter run -d emulator-5554
```

Y cambia `baseUrl` a `http://10.0.2.2:3000/api/v1`

**En celular fisico Android:**

1. Conecta el celular por USB con depuracion activada
2. Cambia `baseUrl` a `http://IP_LOCAL_DE_TU_PC:3000/api/v1`
3. Corre `flutter run`

## Probar el sistema

### 1. Registrar un usuario

Abre la app en Chrome y crea una cuenta nueva.

### 2. Verificar en Swagger

Ve a http://localhost:3000/api/docs y haz login con el mismo usuario.

### 3. Verificar en pgAdmin

Abre http://localhost:5050:
- Email: admin@agrofield.local
- Password: admin

Conecta a:
- Host: agrofield-postgres
- Port: 5432
- DB: agrofield_db
- User: postgres
- Password: postgres

La tabla `users` mostrara los registros.

## Apagar todo

```bash
# En backend
Ctrl+C
docker compose down

# En frontend
q
```

## Solucion de problemas

### CORS error en navegador

Verifica que el backend este corriendo en `http://localhost:3000`.

### "Connection refused" desde celular

- Asegurate de que el PC y el celular esten en la MISMA red WiFi
- Cambia `baseUrl` con la IP local del PC (ej. 192.168.1.10)
- Verifica que el firewall de Windows permita el puerto 3000

### Docker no levanta

```bash
docker compose down -v
docker compose up -d
npm run migration:run
```

### Flutter pub get falla

```bash
flutter clean
flutter pub get
```

## Equipo

Universidad del Magdalena - Arquitectura de Software 2026

- Botto Jimenez Yuranis
- Capataz Gamarra Jesus
- Castano Mazenett Camila
- Rivera Garcia Andres
- Rivera Julio Ana Karina

Docente: Johan Alberto Robles Solano