import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';

import { AppModule } from '../../src/app.module';
import { HttpExceptionFilter } from '../../src/common/filters/http-exception.filter';
import { TransformInterceptor } from '../../src/common/interceptors/transform.interceptor';

/**
 * Helpers compartidos para los tests E2E del Sprint 3.
 *
 * Diseno:
 * - Los tests usan un usuario dedicado (e2e-tester@agrofield.com) en lugar
 *   del admin. Asi nunca tocan los datos manuales del admin y tienen su
 *   propio cupo de 5 ha para crear lotes.
 * - Cada suite limpia sus lotes al iniciar (por si un run anterior fallo)
 *   y al terminar.
 * - El bootstrap usa la MISMA configuracion que main.ts (filter global +
 *   interceptor global + validation pipe estricto).
 */

const E2E_USER_EMAIL = 'e2e-tester@agrofield.com';
const E2E_USER_PASSWORD = 'E2eTester1234';
const E2E_USER_NOMBRE = 'E2E Tester';

const API_PREFIX = '/api/v1';

export interface TestContext {
  app: INestApplication;
  token: string;
  apiPrefix: string;
}

export async function bootstrapTestApp(): Promise<INestApplication> {
  const moduleRef: TestingModule = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  const app = moduleRef.createNestApplication();

  app.setGlobalPrefix('api/v1');

  // MISMA configuracion que main.ts para que los responses sean iguales
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: false },
    }),
  );
  app.useGlobalFilters(new HttpExceptionFilter());
  app.useGlobalInterceptors(new TransformInterceptor());

  await app.init();
  return app;
}

/**
 * Hace login simple. El response tiene forma { statusCode, data: { accessToken, ... } }
 * por el TransformInterceptor global.
 */
async function login(
  app: INestApplication,
  email: string,
  password: string,
): Promise<string | null> {
  const res = await request(app.getHttpServer())
    .post(`${API_PREFIX}/auth/login`)
    .send({ email, password });

  if (res.status !== 200 && res.status !== 201) {
    return null;
  }
  return res.body?.data?.accessToken ?? null;
}

/**
 * Garantiza que existe el usuario E2E y devuelve su token.
 *
 * 1. Intenta login con e2e-tester@agrofield.com.
 * 2. Si no existe (401), lo registra via /auth/register y vuelve a intentar.
 * 3. Devuelve el token del user E2E.
 *
 * El user E2E NUNCA se borra. Sus datos (lotes, siembras, etc.) si.
 */
export async function loginAsE2EUser(app: INestApplication): Promise<string> {
  // Intento 1: login directo (caso comun en runs >= 2)
  let token = await login(app, E2E_USER_EMAIL, E2E_USER_PASSWORD);
  if (token) return token;

  // No existe -> registrarlo
  const registerRes = await request(app.getHttpServer())
    .post(`${API_PREFIX}/auth/register`)
    .send({
      nombreCompleto: E2E_USER_NOMBRE,
      email: E2E_USER_EMAIL,
      password: E2E_USER_PASSWORD,
    });

  // Si el user ya existe (duplicate key 23505) o cualquier otro error,
  // intentamos login una vez mas por si la creacion si paso pero el
  // response fallo.
  if (registerRes.status === 201 || registerRes.status === 200) {
    // Registro OK, el response trae el token directo
    const tokenDelRegister = registerRes.body?.data?.accessToken;
    if (tokenDelRegister) return tokenDelRegister;
  }

  // Fallback: reintentar login
  token = await login(app, E2E_USER_EMAIL, E2E_USER_PASSWORD);
  if (!token) {
    throw new Error(
      `Login E2E fallo. Register status: ${registerRes.status}, body: ${JSON.stringify(registerRes.body)}`,
    );
  }
  return token;
}

/**
 * Borra TODOS los lotes del usuario E2E.
 *
 * Como solo el user E2E ve sus lotes, esto libera todo su cupo de
 * hectareas para que los tests puedan crear nuevos. No toca lotes
 * del admin ni de otros usuarios.
 */
export async function limpiarTodosLosLotesE2E(ctx: TestContext): Promise<void> {
  try {
    const res = await request(ctx.app.getHttpServer())
      .get(`${ctx.apiPrefix}/lotes`)
      .set('Authorization', `Bearer ${ctx.token}`);

    const payload = res.body?.data ?? res.body;
    const lista = Array.isArray(payload) ? payload : (payload?.data ?? []);

    for (const lote of lista) {
      if (lote?.id) {
        await request(ctx.app.getHttpServer())
          .delete(`${ctx.apiPrefix}/lotes/${lote.id}`)
          .set('Authorization', `Bearer ${ctx.token}`);
      }
    }
  } catch {
    // ignorar errores de limpieza
  }
}

export async function crearLotePrueba(
  ctx: TestContext,
  nombre: string,
  superficieHectareas = 0.1,
): Promise<string> {
  const sufijo = Math.random().toString(36).substring(2, 8);
  const res = await request(ctx.app.getHttpServer())
    .post(`${ctx.apiPrefix}/lotes`)
    .set('Authorization', `Bearer ${ctx.token}`)
    .send({
      nombre: `[E2E] ${nombre} ${sufijo}`,
      descripcion: 'Lote auto-generado por test E2E',
      superficieHectareas,
    });

  if (res.status !== 201) {
    throw new Error(`Crear lote fallo (status ${res.status}): ${JSON.stringify(res.body)}`);
  }

  return res.body?.data?.id;
}

export async function borrarRecurso(
  ctx: TestContext,
  ruta: string,
  id: string | undefined,
): Promise<void> {
  if (!id) return;
  try {
    await request(ctx.app.getHttpServer())
      .delete(`${ctx.apiPrefix}/${ruta}/${id}`)
      .set('Authorization', `Bearer ${ctx.token}`);
  } catch {
    // ignorar
  }
}

export async function obtenerPrimerIdCatalogo(
  ctx: TestContext,
  catalogo: 'cultivos' | 'plagas' | 'fertilizantes' | 'municipios',
): Promise<string> {
  const res = await request(ctx.app.getHttpServer())
    .get(`${ctx.apiPrefix}/catalogos/${catalogo}`)
    .set('Authorization', `Bearer ${ctx.token}`);

  const payload = res.body?.data ?? res.body;
  const items = Array.isArray(payload) ? payload : (payload?.data ?? []);
  if (items.length === 0) {
    throw new Error(`Catalogo ${catalogo} vacio o respuesta inesperada`);
  }
  return items[0].id;
}

// Compat: alias para codigo legacy
export const loginAsAdmin = loginAsE2EUser;

export { API_PREFIX };