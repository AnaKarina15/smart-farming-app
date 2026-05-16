# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Smart-farming-app is a full-stack agricultural management platform for small-scale producers (<5 ha) in the Magdalena region. It is a monorepo with two workspaces:

- `backend/` — NestJS 11 REST API (TypeScript 5.7, PostgreSQL 16)
- `frontend/` — Flutter mobile/web app (Dart, offline-first)

Academic context: Universidad del Magdalena, Arquitectura de Software 2026.

---

## Backend Commands (run from `backend/`)

```bash
# Infrastructure
npm run docker:up          # Start PostgreSQL (port 5433) + pgAdmin (port 5050)
npm run docker:down        # Stop containers
npm run docker:logs        # Stream container logs

# Database
npm run migration:run      # Apply pending migrations
npm run migration:revert   # Undo last migration
npm run migration:generate -- src/database/migrations/MyMigration  # Create migration
npm run seed               # Run seeds

# Development
npm run start:dev          # Hot-reload dev server → http://localhost:3000
npm run start:debug        # Debugger + watch mode
npm run lint               # ESLint + autofix
npm run format             # Prettier

# Testing
npm test                   # Jest unit tests
npm run test:watch         # Watch mode
npm run test:cov           # Coverage report
npm run test:e2e           # End-to-end tests
```

Swagger UI is available at **http://localhost:3000/api/docs** in dev mode.

pgAdmin UI is at **http://localhost:5050** (admin@agrofield.local / admin).

---

## Frontend Commands (run from `frontend/`)

```bash
flutter pub get                          # Install dependencies
flutter run                              # Run on connected device/emulator
flutter run -d chrome --web-port 8080    # Web browser
flutter run -d emulator-5554             # Specific Android emulator
flutter analyze                          # Static analysis / linting
flutter clean                            # Wipe build cache
```

**Network configuration** is set in `lib/core/network/api_endpoints.dart`. The base URL is selected at runtime by platform:
- Web → `http://localhost:3000/api/v1`
- Android emulator → `http://10.0.2.2:3000/api/v1`
- Physical device → hardcode the PC's LAN IP (`192.168.x.x:3000`)

---

## Backend Architecture

### Module layout

Each feature lives under `backend/src/modules/<feature>/` and contains:

```
<feature>/
├── entities/          # TypeORM entity class(es)
├── dto/               # CreateDto, UpdateDto, ResponseDto
├── <feature>.repository.ts
├── <feature>.service.ts
├── <feature>.controller.ts
└── <feature>.module.ts
```

Implemented modules: `auth`, `users`, `lotes`, `health`, `audit`, `weather`.

### Global pipeline (applies to every request)

Helmet → CORS → Compression → ThrottlerGuard (100 req/min) → ValidationPipe (whitelist + forbidNonWhitelisted) → JwtAuthGuard → `TransformInterceptor` (wraps all responses) → `HttpExceptionFilter` (standardizes errors).

Use the `@Public()` decorator to bypass JWT on specific routes.

### Authentication

- Argon2id password hashing (OWASP 2026 standard).
- Access + refresh JWT pair. Refresh hash stored in DB; token reuse is detected and triggers logout.
- `JwtStrategy` reads `Authorization: Bearer …` header; guard is applied globally.

### Database conventions

- PostgreSQL 16 via TypeORM 0.3. `synchronize: false` — changes go through migrations only.
- UUID primary keys on all entities (offline-friendly, client can pre-generate IDs).
- Soft-delete enabled via `deletedAt` / `@SoftDelete()` (preserves audit history).
- Passwords excluded from all queries (`select: false` on the column).
- TypeScript path aliases: `@/*`, `@common/*`, `@modules/*`, etc. (configured in `tsconfig.json`).

### Configuration

Environment variables are validated at startup with Joi (fails fast). Copy `.env.example` → `.env` before running. Registered configs: `appConfig`, `databaseConfig`, `jwtConfig`, `swaggerConfig`.

---

## Frontend Architecture

### State management

Provider 6 / ChangeNotifier. There is no BLoC or Redux. Services are injected manually in `main.dart` and exposed via `MultiProvider`.

```
AuthService → DioClient → backend
         ↘ TokenStorage (secure storage)
AuthProvider (ChangeNotifier) ← consumed by screens
```

### Directory layout

```
lib/
├── core/
│   ├── network/        # DioClient (JWT injection), ApiEndpoints
│   ├── storage/        # TokenStorage (JWT), DatabaseHelper (SQLite)
│   ├── theme/          # AppColors (green #0F5238), AppText (Lexend font)
│   └── services/       # WeatherService
├── data/
│   ├── models/         # AuthTokens, User, Lote (plain Dart classes)
│   ├── providers/      # AuthProvider (ChangeNotifier)
│   └── services/       # AuthService, LotesService, SyncService
└── presentation/
    ├── screens/        # One file per screen
    └── widgets/        # RuggedCard, RuggedButton, RuggedTextField,
                        # CustomAppBar, OfflineBanner, AgroBottomNav
```

### Offline-first pattern

SQLite (`sqflite`) stores data locally. `SyncService` detects network reconnection via `connectivity_plus` and uploads pending changes. `OfflineBanner` widget alerts the user when connectivity is lost.

### UI style

Material 3 with a rugged/neo-brutalist aesthetic (high contrast, thick borders, Lexend typeface). Designed for outdoor field use with gloves and bright sunlight. Do not soften this into standard Material defaults.

---

## Key Business Rules

- **Max 5 hectares** of total registered lotes per user (RF02, RF04).
- Coordinates stored with 7-decimal precision (lat/lng).
- User roles: `PEQUEÑO_PRODUCTOR`, `TRABAJADOR`, `GESTOR`, `ADMINISTRADOR`.
- Code comments, variable names, and domain terms are in **Spanish** — keep this convention.

---

## Development Environment Setup

1. `cd backend && npm install`
2. `npm run docker:up` — starts PostgreSQL on `localhost:5433`
3. `npm run migration:run`
4. `npm run start:dev`
5. `cd ../frontend && flutter pub get`
6. Adjust base URL in `api_endpoints.dart` if using a physical device, then `flutter run`
