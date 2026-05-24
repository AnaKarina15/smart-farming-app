import { INestApplication } from '@nestjs/common';
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
 * E2E - Sprint 5: Sesion persistente + Sincronizacion Offline-first.
 *
 * Cubre:
 * - Seguridad JWT de /sync/*
 * - POST /sync/batch con operaciones offline batch
 * - Idempotencia localId + userId + resourceType
 * - Inferencia de resourceType desde endpoint legacy de sync_queue
 * - Last-write-wins basado en clientUpdatedAt vs updatedAt/deletedAt
 * - GET /sync/since para pull incremental, incluyendo soft-deleted
 * - GET /sync/validate-token para validacion offline-friendly de sesion
 */
describe('Sprint 5 - Sync Offline-first (E2E)', () => {
  let app: INestApplication;
  let ctx: TestContext;
  let loteId: string;
  let cultivoId: string;

  const runId = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;

  beforeAll(async () => {
    app = await bootstrapTestApp();

    const token = await loginAsE2EUser(app);
    ctx = { app, token, apiPrefix: API_PREFIX };

    await limpiarTodosLosLotesE2E(ctx);

    loteId = await crearLotePrueba(ctx, 'Lote Sync Sprint 5', 0.1);
    cultivoId = await obtenerPrimerIdCatalogo(ctx, 'cultivos');
  }, 60000);

  afterAll(async () => {
    if (ctx) {
      await limpiarTodosLosLotesE2E(ctx);
    }

    if (app) {
      await app.close();
    }
  });

  function unwrap<T = any>(res: request.Response): T {
    return res.body?.data ?? res.body;
  }

  describe('Seguridad JWT', () => {
    it('POST /sync/batch sin token debe responder 401', async () => {
      const res = await request(app.getHttpServer()).post(`${API_PREFIX}/sync/batch`).send({
        items: [],
      });

      expect(res.status).toBe(401);
    });

    it('GET /sync/since sin token debe responder 401', async () => {
      const res = await request(app.getHttpServer()).get(`${API_PREFIX}/sync/since`).query({
        timestamp: new Date().toISOString(),
      });

      expect(res.status).toBe(401);
    });

    it('GET /sync/validate-token sin token debe responder 401', async () => {
      const res = await request(app.getHttpServer()).get(`${API_PREFIX}/sync/validate-token`);

      expect(res.status).toBe(401);
    });
  });

  describe('GET /sync/validate-token', () => {
    it('debe devolver informacion minima del usuario autenticado y vigencia del token', async () => {
      const res = await request(app.getHttpServer())
        .get(`${API_PREFIX}/sync/validate-token`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(200);

      const payload = unwrap(res);

      expect(payload.serverTime).toBeDefined();
      expect(payload.user).toBeDefined();
      expect(payload.user.id).toBeDefined();
      expect(payload.user.email).toBe('e2e-tester@agrofield.com');
      expect(payload.user.role).toBeDefined();

      expect(payload.token).toBeDefined();
      expect(payload.token.valid).toBe(true);
      expect(payload.token.expiresAt === null || typeof payload.token.expiresAt === 'string').toBe(
        true,
      );
      expect(
        payload.token.expiresInSeconds === null ||
          typeof payload.token.expiresInSeconds === 'number',
      ).toBe(true);
    });
  });

  describe('POST /sync/batch', () => {
    let sinceBeforeBatch: string;
    let siembraLocalId: string;
    let riegoLocalId: string;
    let siembraServerId: string;
    let riegoServerId: string;

    beforeAll(() => {
      sinceBeforeBatch = new Date(Date.now() - 1000).toISOString();
      siembraLocalId = `siembras-local-${runId}`;
      riegoLocalId = `riego-local-${runId}`;
    });

    it('debe crear un batch con siembra y riego en una sola llamada', async () => {
      const clientUpdatedAt = new Date().toISOString();

      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/sync/batch`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          deviceId: `device-e2e-${runId}`,
          items: [
            {
              localId: siembraLocalId,
              resourceType: 'siembras',
              operation: 'create',
              clientUpdatedAt,
              payload: {
                loteId,
                cultivoId,
                variedad: 'Criolla Sync E2E',
                fecha: clientUpdatedAt,
                cantidadSemillas: 3,
                unidad: 'kg',
                observaciones: 'Siembra creada offline desde E2E',
              },
            },
            {
              localId: riegoLocalId,
              method: 'POST',
              endpoint: '/api/v1/riego',
              clientUpdatedAt,
              payload: {
                loteId,
                tipo: 'goteo',
                duracionMinutos: 35,
                cantidadLitros: 220,
                humedad: 55,
                fecha: clientUpdatedAt,
                observaciones: 'Riego creado offline desde E2E',
              },
            },
          ],
        });

      expect(res.status).toBe(201);

      const payload = unwrap(res);

      expect(payload.serverTime).toBeDefined();
      expect(payload.summary.total).toBe(2);
      expect(payload.summary.created).toBe(2);
      expect(payload.summary.error).toBe(0);

      const siembraResult = payload.results.find((item: any) => item.localId === siembraLocalId);
      const riegoResult = payload.results.find((item: any) => item.localId === riegoLocalId);

      expect(siembraResult).toBeDefined();
      expect(siembraResult.status).toBe('created');
      expect(siembraResult.resourceType).toBe('siembras');
      expect(siembraResult.serverId).toBeDefined();

      expect(riegoResult).toBeDefined();
      expect(riegoResult.status).toBe('created');
      expect(riegoResult.resourceType).toBe('riego');
      expect(riegoResult.serverId).toBeDefined();

      siembraServerId = siembraResult.serverId;
      riegoServerId = riegoResult.serverId;
    });

    it('debe ser idempotente: repetir el mismo create devuelve duplicate sin duplicar', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/sync/batch`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          deviceId: `device-e2e-${runId}`,
          items: [
            {
              localId: siembraLocalId,
              resourceType: 'siembras',
              operation: 'create',
              clientUpdatedAt: new Date().toISOString(),
              payload: {
                loteId,
                cultivoId,
                variedad: 'Criolla Sync E2E duplicada',
                fecha: new Date().toISOString(),
                cantidadSemillas: 9,
                unidad: 'kg',
              },
            },
          ],
        });

      expect(res.status).toBe(201);

      const payload = unwrap(res);
      expect(payload.summary.total).toBe(1);
      expect(payload.summary.duplicate).toBe(1);

      expect(payload.results[0].localId).toBe(siembraLocalId);
      expect(payload.results[0].status).toBe('duplicate');
      expect(payload.results[0].serverId).toBe(siembraServerId);
    });

    it('debe rechazar por item un update viejo cuando servidor tiene version mas reciente', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/sync/batch`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          items: [
            {
              localId: siembraLocalId,
              resourceType: 'siembras',
              operation: 'update',
              clientUpdatedAt: '2000-01-01T00:00:00.000Z',
              payload: {
                observaciones: 'Update offline viejo que debe perder por LWW',
              },
            },
          ],
        });

      expect(res.status).toBe(201);

      const payload = unwrap(res);

      expect(payload.summary.total).toBe(1);
      expect(payload.summary.error).toBe(1);
      expect(payload.results[0].status).toBe('error');
      expect(payload.results[0].error).toContain('Conflicto last-write-wins');
    });

    it('debe aceptar update con clientUpdatedAt posterior', async () => {
      const futureClientUpdatedAt = new Date(Date.now() + 60_000).toISOString();

      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/sync/batch`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          items: [
            {
              localId: siembraLocalId,
              resourceType: 'siembras',
              operation: 'update',
              clientUpdatedAt: futureClientUpdatedAt,
              payload: {
                fecha: futureClientUpdatedAt,
                observaciones: 'Siembra actualizada desde sync E2E',
              },
            },
          ],
        });

      expect(res.status).toBe(201);

      const payload = unwrap(res);

      expect(payload.summary.total).toBe(1);
      expect(payload.summary.updated).toBe(1);
      expect(payload.results[0].status).toBe('updated');
      expect(payload.results[0].serverId).toBe(siembraServerId);
    });

    it('debe soft-deletear un recurso sincronizado', async () => {
      const futureClientUpdatedAt = new Date(Date.now() + 120_000).toISOString();

      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/sync/batch`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          items: [
            {
              localId: riegoLocalId,
              resourceType: 'riego',
              operation: 'delete',
              clientUpdatedAt: futureClientUpdatedAt,
              payload: {},
            },
          ],
        });

      expect(res.status).toBe(201);

      const payload = unwrap(res);

      expect(payload.summary.total).toBe(1);
      expect(payload.summary.deleted).toBe(1);
      expect(payload.results[0].status).toBe('deleted');
      expect(payload.results[0].serverId).toBe(riegoServerId);
    });

    it('GET /sync/since debe devolver cambios creados, actualizados y soft-deleted', async () => {
      const res = await request(app.getHttpServer())
        .get(`${API_PREFIX}/sync/since`)
        .query({ timestamp: sinceBeforeBatch })
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(200);

      const payload = unwrap(res);

      expect(payload.serverTime).toBeDefined();
      expect(payload.since).toBe(new Date(sinceBeforeBatch).toISOString());
      expect(payload.changes).toBeDefined();

      expect(Array.isArray(payload.changes.siembras)).toBe(true);
      expect(Array.isArray(payload.changes.riego)).toBe(true);
      expect(Array.isArray(payload.changes.fertilizacion)).toBe(true);
      expect(Array.isArray(payload.changes.hallazgos)).toBe(true);
      expect(Array.isArray(payload.changes.tratamientos)).toBe(true);
      expect(Array.isArray(payload.changes.observaciones)).toBe(true);
      expect(Array.isArray(payload.changes.estadoTerreno)).toBe(true);

      const siembra = payload.changes.siembras.find((item: any) => item.id === siembraServerId);
      const riego = payload.changes.riego.find((item: any) => item.id === riegoServerId);

      expect(siembra).toBeDefined();
      expect(siembra.id).toBe(siembraServerId);
      expect(siembra.loteId).toBe(loteId);
      expect(siembra.observaciones).toBe('Siembra actualizada desde sync E2E');

      expect(riego).toBeDefined();
      expect(riego.id).toBe(riegoServerId);
      expect(riego.deletedAt).toBeDefined();
    });

    it('GET /sync/since con timestamp invalido debe responder 400', async () => {
      const res = await request(app.getHttpServer())
        .get(`${API_PREFIX}/sync/since`)
        .query({ timestamp: 'no-es-fecha' })
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(400);
    });

    it('POST /sync/batch con item invalido debe responder error por item sin tumbar el endpoint', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/sync/batch`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          items: [
            {
              localId: `siembra-invalida-${runId}`,
              resourceType: 'siembras',
              operation: 'create',
              clientUpdatedAt: new Date().toISOString(),
              payload: {
                loteId,
                fecha: new Date().toISOString(),
              },
            },
          ],
        });

      expect(res.status).toBe(201);

      const payload = unwrap(res);

      expect(payload.summary.total).toBe(1);
      expect(payload.summary.error).toBe(1);
      expect(payload.results[0].status).toBe('error');
      expect(payload.results[0].error).toContain('Debe especificar cultivoId o cultivoOtro');
    });
  });
});
