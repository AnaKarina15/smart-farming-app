import request from 'supertest';

import {
  API_PREFIX,
  TestContext,
  bootstrapTestApp,
  crearLotePrueba,
  limpiarTodosLosLotesE2E,
  loginAsE2EUser,
  obtenerPrimerIdCatalogo,
} from './helpers/test-setup';

/**
 * Tests E2E del Sprint 4 — Sistema Experto de Recomendaciones.
 *
 * Cubre los dos conjuntos de endpoints del modulo recomendaciones:
 *
 *  1. ADMIN (/admin/reglas): CRUD del catalogo de reglas, protegido por
 *     RolesGuard (solo ADMINISTRADOR). El usuario E2E NO es admin, por lo
 *     que estos endpoints deben responder 403 para el.
 *
 *  2. PUBLICO (/recomendaciones): evaluar, aplicar e historial. Accesibles
 *     para cualquier productor autenticado sobre sus propios lotes.
 *
 * Diseno:
 *  - Usa el usuario dedicado e2e-tester@agrofield.com (no admin).
 *  - Limpia sus lotes al iniciar y al terminar.
 *  - Mismo bootstrap que main.ts (filter + interceptor + validation pipe).
 */
describe('Sprint 4 - Sistema Experto de Recomendaciones (E2E)', () => {
  let ctx: TestContext;

  beforeAll(async () => {
    const app = await bootstrapTestApp();
    const token = await loginAsE2EUser(app);
    ctx = { app, token, apiPrefix: API_PREFIX };
    await limpiarTodosLosLotesE2E(ctx);
  });

  afterAll(async () => {
    await limpiarTodosLosLotesE2E(ctx);
    await ctx.app.close();
  });

  // ════════════════════════════════════════════════════════
  // BLOQUE 1: Seguridad de los endpoints ADMIN
  // ════════════════════════════════════════════════════════
  describe('Seguridad /admin/reglas (RolesGuard)', () => {
    it('GET /admin/reglas debe responder 403 para un usuario NO admin', async () => {
      const res = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/admin/reglas`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(403);
    });

    it('POST /admin/reglas debe responder 403 para un usuario NO admin', async () => {
      const res = await request(ctx.app.getHttpServer())
        .post(`${ctx.apiPrefix}/admin/reglas`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({ nombre: 'Regla pirata' });

      expect(res.status).toBe(403);
    });

    it('GET /admin/reglas sin token debe responder 401', async () => {
      const res = await request(ctx.app.getHttpServer()).get(`${ctx.apiPrefix}/admin/reglas`);

      expect(res.status).toBe(401);
    });
  });

  // ════════════════════════════════════════════════════════
  // BLOQUE 2: Evaluar recomendaciones de un lote
  // ════════════════════════════════════════════════════════
  describe('GET /recomendaciones/lote/:loteId', () => {
    let loteId: string;

    beforeAll(async () => {
      loteId = await crearLotePrueba(ctx, 'Lote Sistema Experto');
    });

    it('debe devolver una lista (array) de recomendaciones para un lote propio', async () => {
      const res = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/recomendaciones/lote/${loteId}`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(200);
      const payload = res.body?.data ?? res.body;
      expect(Array.isArray(payload)).toBe(true);
    });

    it('cada recomendacion evaluada debe traer prioridad y fuente cientifica', async () => {
      const res = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/recomendaciones/lote/${loteId}`)
        .set('Authorization', `Bearer ${ctx.token}`);

      const payload = res.body?.data ?? res.body;
      const lista = Array.isArray(payload) ? payload : [];

      // Si el motor devolvio recomendaciones, validamos su forma.
      // La respuesta envuelve la regla: { regla: {...}, etiquetaPrioridad,
      // colorPrioridad, motivoMatch }.
      for (const reco of lista) {
        expect(reco).toHaveProperty('regla');
        expect(reco).toHaveProperty('motivoMatch');
        expect(reco.regla).toHaveProperty('prioridad');
        expect(reco.regla).toHaveProperty('fuenteCientifica');
        expect(typeof reco.regla.prioridad).toBe('number');
      }
    });

    it('debe responder 404 al evaluar un lote inexistente', async () => {
      const idFalso = '00000000-0000-0000-0000-000000000000';
      const res = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/recomendaciones/lote/${idFalso}`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect([403, 404]).toContain(res.status);
    });

    it('debe responder 400 con un loteId que no es UUID valido', async () => {
      const res = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/recomendaciones/lote/no-es-uuid`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(400);
    });
  });

  // ════════════════════════════════════════════════════════
  // BLOQUE 3: Flujo completo - detectar plaga y evaluar
  // ════════════════════════════════════════════════════════
  describe('Flujo: hallazgo de plaga -> evaluacion del motor', () => {
    let loteId: string;

    beforeAll(async () => {
      loteId = await crearLotePrueba(ctx, 'Lote Flujo Plaga');
    });

    it('al registrar un hallazgo de plaga, el motor debe poder evaluarse sin error', async () => {
      const plagaId = await obtenerPrimerIdCatalogo(ctx, 'plagas');

      // Registrar un hallazgo de plaga en el lote
      const hallazgoRes = await request(ctx.app.getHttpServer())
        .post(`${ctx.apiPrefix}/hallazgos`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          loteId,
          plagaId,
          fecha: '2026-05-20',
          severidad: 'alta',
          descripcion: 'Hallazgo generado por test E2E del Sprint 4',
        });

      // El hallazgo debe crearse (201). Si la forma del DTO difiere,
      // el test sigue validando que la evaluacion no rompa.
      expect([200, 201]).toContain(hallazgoRes.status);

      // Evaluar el lote ahora que tiene un hallazgo
      const evalRes = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/recomendaciones/lote/${loteId}`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(evalRes.status).toBe(200);
      const payload = evalRes.body?.data ?? evalRes.body;
      expect(Array.isArray(payload)).toBe(true);
    });
  });

  // ════════════════════════════════════════════════════════
  // BLOQUE 4: Historial de recomendaciones
  // ════════════════════════════════════════════════════════
  describe('GET /recomendaciones/historial/:loteId', () => {
    let loteId: string;

    beforeAll(async () => {
      loteId = await crearLotePrueba(ctx, 'Lote Historial');
    });

    it('debe devolver el historial (array) de un lote, vacio si no hay decisiones', async () => {
      const res = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/recomendaciones/historial/${loteId}`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(200);
      const payload = res.body?.data ?? res.body;
      expect(Array.isArray(payload)).toBe(true);
    });

    it('debe responder 400 con un loteId invalido', async () => {
      const res = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/recomendaciones/historial/loteId-malo`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(400);
    });
  });

  // ════════════════════════════════════════════════════════
  // BLOQUE 5: Aplicar recomendacion (audit log)
  // ════════════════════════════════════════════════════════
  describe('POST /recomendaciones/:reglaId/aplicar', () => {
    it('debe responder 400 con un reglaId que no es UUID', async () => {
      const res = await request(ctx.app.getHttpServer())
        .post(`${ctx.apiPrefix}/recomendaciones/reglaId-malo/aplicar`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({});

      expect(res.status).toBe(400);
    });

    it('debe rechazar (400) un body sin los campos requeridos', async () => {
      const reglaIdFalso = '00000000-0000-0000-0000-000000000000';
      const res = await request(ctx.app.getHttpServer())
        .post(`${ctx.apiPrefix}/recomendaciones/${reglaIdFalso}/aplicar`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({});

      // 400 por validacion del DTO, o 404 si valida primero la regla.
      expect([400, 404]).toContain(res.status);
    });
  });
});
