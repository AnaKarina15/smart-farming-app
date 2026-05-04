# AgroField Backend

Backend API REST de **AgroField**, plataforma digital de agricultura inteligente para pequeños productores del Magdalena (parcelas <5 ha).

> Proyecto académico — Arquitectura de Software, Universidad del Magdalena.
> Diseñado para producción real, siguiendo prácticas senior.

---

## Stack tecnológico

| Capa | Tecnología | Versión |
|---|---|---|
| Runtime | Node.js | 22 / 24 LTS |
| Lenguaje | TypeScript | 5.7 |
| Framework | NestJS | 11 |
| ORM | TypeORM | 0.3 |
| Base de datos | PostgreSQL | 16 (Docker) |
| Autenticación | JWT + Passport + Argon2id | — |
| Validación | class-validator + Joi (env) | — |
| Documentación | Swagger / OpenAPI | 11 |
| Logging | Winston | 3 |
| Seguridad | Helmet + Throttler + CORS | — |
| Testing | Jest | 29 |

---

## Requisitos previos

- Node.js >= 22 LTS (verificado: `node --version`)
- Docker Desktop corriendo
- Git

---

## Arranque rápido

```powershell
# 1. Instalar dependencias
npm install

# 2. Crear archivo .env (ya viene con valores de desarrollo)
Copy-Item .env.example .env

# 3. Levantar PostgreSQL en Docker
docker compose up -d

# 4. Esperar ~10 segundos a que PostgreSQL termine de iniciar
Start-Sleep -Seconds 10

# 5. Ejecutar migraciones (crea las tablas users y lotes)
npm run migration:run

# 6. Arrancar el servidor en modo desarrollo
npm run start:dev
```

Una vez arrancado:

- API: http://localhost:3000/api/v1
- Swagger UI: http://localhost:3000/api/docs
- Health check: http://localhost:3000/api/v1/health
- pgAdmin: http://localhost:5050 (admin@agrofield.local / admin)

---

## Estructura del proyecto

Organización **por feature/módulo** (convención oficial NestJS):

```
src/
├── main.ts                          Bootstrap (Helmet, CORS, Swagger, validación global)
├── app.module.ts                    Módulo raíz
├── config/                          Configuración tipada (app, database, jwt, swagger)
├── common/                          Código transversal
│   ├── decorators/                  @Public, @CurrentUser, @Roles
│   ├── filters/                     HttpExceptionFilter (respuestas de error consistentes)
│   ├── guards/                      JwtAuthGuard, RolesGuard
│   ├── interceptors/                TransformInterceptor (envuelve respuestas exitosas)
│   └── utils/                       Winston logger
├── database/
│   ├── data-source.ts               DataSource standalone para CLI
│   ├── typeorm.config.ts            Factory de configuración TypeORM
│   └── migrations/                  Migraciones SQL versionadas
└── modules/
    ├── auth/                        Registro, login, refresh, logout (Argon2id + JWT rotación)
    ├── users/                       Gestión de usuarios (3 roles: productor, trabajador, gestor)
    ├── lotes/                       CRUD de parcelas (RF02, RF04 - max 5 ha total)
    └── health/                      Health check (DB ping)
```

Cada módulo sigue el patrón:

```
modules/<feature>/
├── entities/<feature>.entity.ts     Entidad TypeORM
├── dto/                             DTOs con class-validator + Swagger
├── <feature>.repository.ts          Acceso a datos
├── <feature>.service.ts             Lógica de negocio
├── <feature>.controller.ts          Endpoints REST
└── <feature>.module.ts              Composición del módulo
```

---

## Endpoints disponibles (prototipo del lunes)

### Auth (públicos)
- `POST /api/v1/auth/register` — Registro de Pequeño Productor
- `POST /api/v1/auth/login` — Login
- `POST /api/v1/auth/refresh` — Renovar tokens
- `POST /api/v1/auth/logout` — Cerrar sesión (requiere JWT)

### Users (autenticados)
- `GET /api/v1/users/me` — Perfil del usuario autenticado

### Lotes (autenticados)
- `POST /api/v1/lotes` — Crear lote (RF04)
- `GET /api/v1/lotes` — Listar lotes del productor
- `GET /api/v1/lotes/:id` — Detalle de un lote
- `PATCH /api/v1/lotes/:id` — Actualizar lote
- `DELETE /api/v1/lotes/:id` — Eliminar lote

### Health (público)
- `GET /api/v1/health` — Estado de la aplicación + DB

---

## Comandos útiles

```powershell
# Desarrollo
npm run start:dev              # Modo watch
npm run start:debug            # Con debugger
npm run lint                   # ESLint + autofix
npm run format                 # Prettier

# Base de datos
docker compose up -d           # Levantar PostgreSQL + pgAdmin
docker compose down            # Detener
docker compose logs -f         # Ver logs en vivo

# Migraciones
npm run migration:run          # Aplicar migraciones pendientes
npm run migration:revert       # Revertir última migración
npm run migration:generate -- src/database/migrations/MiNuevaMigracion

# Build de producción
npm run build
npm run start:prod

# Testing
npm test                       # Tests unitarios
npm run test:cov               # Con cobertura
npm run test:e2e               # Tests end-to-end
```

---

## Próximos módulos a implementar

Siguiendo la misma estructura, los próximos módulos cubrirán los procesos restantes de la Fase 1:

- `siembras/` — RF01-RF05 (Plantación)
- `riego/` — RF06-RF09 (Monitoreo y Riego)
- `fertilizacion/` — RF10-RF13 (Fertilización)
- `fitosanitario/` — RF14-RF18 (Manejo de Plagas)
- `clima/` — Integración Proveedor de Datos Climáticos
- `recomendaciones/` — Motor de reglas agronómicas
- `sync/` — Endpoint de sincronización offline-first (RNF01)

---

## Decisiones arquitectónicas clave

| Decisión | Justificación |
|---|---|
| **Argon2id** sobre bcrypt | Estándar OWASP 2026, resistente a ataques GPU |
| **JWT con rotación** (refresh hash en BD) | Detecta reuso de tokens (señal de compromiso) |
| **UUID** en lugar de auto-increment | Compatible con sincronización offline-first (cliente puede generar IDs) |
| **Helmet + Throttler + CORS** | Defensa en profundidad (RNF03 - Confidencialidad) |
| **Joi validation en startup** | App no arranca si hay variables de entorno mal configuradas |
| **Winston estructurado** | JSON en producción → integrable con ELK/Datadog |
| **Validación whitelist en DTOs** | Rechaza propiedades no declaradas (previene mass assignment) |

---

## Equipo

Grupo 1 - Arquitectura de Software - Universidad del Magdalena (2026)

- Botto Jiménez Yuranis
- Capataz Gamarra Jesús
- Castaño Mazenett Camila
- Rivera García Andrés
- Rivera Julio Ana Karina

Docente: Johan Alberto Robles Solano
