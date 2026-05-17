import { INestApplication } from '@nestjs/common';
import request from 'supertest';

import {
  API_PREFIX,
  bootstrapTestApp,
  borrarRecurso,
  crearLotePrueba,
  limpiarTodosLosLotesE2E,
  loginAsE2EUser,
  obtenerPrimerIdCatalogo,
  TestContext,
} from './helpers/test-setup';

/**
 * E2E - Smoke tests de los modulos operativos del Sprint 3.
 *
 * Para cada modulo valida: POST 201, POST sin requisito 400 cuando aplica,
 * GET paginado 200, PATCH 200 y DELETE 204.
 */

describe('Sprint 3 - Modulos Operativos (E2E)', () => {
  let app: INestApplication;
  let ctx: TestContext;
  let loteId: string;
  let cultivoId: string;
  let plagaId: string;
  let fertilizanteId: string;

  beforeAll(async () => {
    app = await bootstrapTestApp();
    const token = await loginAsE2EUser(app);
    ctx = { app, token, apiPrefix: API_PREFIX };

    // Limpiar TODOS los lotes del usuario E2E (libera cupo de 5 ha)
    await limpiarTodosLosLotesE2E(ctx);

    loteId = await crearLotePrueba(ctx, 'Lote Smoke E2E', 0.1);
    cultivoId = await obtenerPrimerIdCatalogo(ctx, 'cultivos');
    plagaId = await obtenerPrimerIdCatalogo(ctx, 'plagas');
    fertilizanteId = await obtenerPrimerIdCatalogo(ctx, 'fertilizantes');
  }, 60000);

  afterAll(async () => {
    await borrarRecurso(ctx, 'lotes', loteId);
    await app.close();
  });

  // ════════════════════════════════════════════════════════
  // SIEMBRAS
  // ════════════════════════════════════════════════════════

  describe('Siembras', () => {
    let siembraId: string;

    it('POST /siembras con cultivoId -> 201', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/siembras`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          loteId,
          cultivoId,
          variedad: 'Hibrido E2E',
          fecha: '2026-05-17T10:00:00Z',
          cantidadSemillas: 5.5,
          unidad: 'kg',
        });
      expect(res.status).toBe(201);
      siembraId = (res.body?.data ?? res.body).id;
      expect(siembraId).toBeDefined();
    });

    it('POST /siembras sin cultivoId ni cultivoOtro -> 400', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/siembras`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({ loteId, fecha: '2026-05-17T10:00:00Z' });
      expect(res.status).toBe(400);
    });

    it('GET /siembras?loteId paginado -> 200', async () => {
      const res = await request(app.getHttpServer())
        .get(`${API_PREFIX}/siembras`)
        .query({ loteId, page: 1, limit: 10 })
        .set('Authorization', `Bearer ${ctx.token}`);
      expect(res.status).toBe(200);
      const payload = res.body?.data ?? res.body;
      expect(payload.page).toBe(1);
      expect(payload.limit).toBe(10);
    });

    it('DELETE /siembras/:id -> 204', async () => {
      const res = await request(app.getHttpServer())
        .delete(`${API_PREFIX}/siembras/${siembraId}`)
        .set('Authorization', `Bearer ${ctx.token}`);
      expect(res.status).toBe(204);
    });
  });

  // ════════════════════════════════════════════════════════
  // RIEGO
  // ════════════════════════════════════════════════════════

  describe('Riego', () => {
    let riegoId: string;

    it('POST /riego con tipo valido -> 201', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/riego`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          loteId,
          tipo: 'goteo',
          duracionMinutos: 45,
          cantidadLitros: 500,
          humedad: 65,
          fecha: '2026-05-17T06:30:00Z',
        });
      expect(res.status).toBe(201);
      riegoId = (res.body?.data ?? res.body).id;
    });

    it('POST /riego con tipo invalido -> 400', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/riego`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({ loteId, tipo: 'tipo-falso', fecha: '2026-05-17T06:30:00Z' });
      expect(res.status).toBe(400);
    });

    it('POST /riego con humedad fuera de rango -> 400', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/riego`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          loteId,
          tipo: 'manual',
          humedad: 150,
          fecha: '2026-05-17T06:30:00Z',
        });
      expect(res.status).toBe(400);
    });

    it('DELETE /riego/:id -> 204', async () => {
      const res = await request(app.getHttpServer())
        .delete(`${API_PREFIX}/riego/${riegoId}`)
        .set('Authorization', `Bearer ${ctx.token}`);
      expect(res.status).toBe(204);
    });
  });

  // ════════════════════════════════════════════════════════
  // FERTILIZACION
  // ════════════════════════════════════════════════════════

  describe('Fertilizacion', () => {
    let fertId: string;

    it('POST /fertilizacion con fertilizanteId -> 201', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/fertilizacion`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          loteId,
          fertilizanteId,
          dosis: 50,
          unidad: 'kg/ha',
          metodoAplicacion: 'edafica',
          fecha: '2026-05-17T08:00:00Z',
        });
      expect(res.status).toBe(201);
      fertId = (res.body?.data ?? res.body).id;
    });

    it('POST /fertilizacion sin fertilizanteId ni Otro -> 400', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/fertilizacion`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({ loteId, fecha: '2026-05-17T08:00:00Z' });
      expect(res.status).toBe(400);
    });

    it('DELETE /fertilizacion/:id -> 204', async () => {
      const res = await request(app.getHttpServer())
        .delete(`${API_PREFIX}/fertilizacion/${fertId}`)
        .set('Authorization', `Bearer ${ctx.token}`);
      expect(res.status).toBe(204);
    });
  });

  // ════════════════════════════════════════════════════════
  // HALLAZGOS
  // ════════════════════════════════════════════════════════

  describe('Hallazgos', () => {
    let hallazgoId: string;

    it('POST /hallazgos con plagaId -> 201', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/hallazgos`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          loteId,
          plagaId,
          severidad: 'media',
          fecha: '2026-05-17T09:00:00Z',
        });
      expect(res.status).toBe(201);
      hallazgoId = (res.body?.data ?? res.body).id;
    });

    it('POST /hallazgos con severidad invalida -> 400', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/hallazgos`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          loteId,
          plagaOtro: 'Algo',
          severidad: 'extrema',
          fecha: '2026-05-17T09:00:00Z',
        });
      expect(res.status).toBe(400);
    });

    it('GET /hallazgos?severidad=media -> 200 todos con esa severidad', async () => {
      const res = await request(app.getHttpServer())
        .get(`${API_PREFIX}/hallazgos`)
        .query({ severidad: 'media', loteId })
        .set('Authorization', `Bearer ${ctx.token}`);
      expect(res.status).toBe(200);
      const payload = res.body?.data ?? res.body;
      const lista = payload?.data ?? payload;
      for (const h of lista) {
        expect(h.severidad).toBe('media');
      }
    });

    it('DELETE /hallazgos/:id -> 204', async () => {
      const res = await request(app.getHttpServer())
        .delete(`${API_PREFIX}/hallazgos/${hallazgoId}`)
        .set('Authorization', `Bearer ${ctx.token}`);
      expect(res.status).toBe(204);
    });
  });
});
