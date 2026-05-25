import { INestApplication } from '@nestjs/common';
import request from 'supertest';

import {
  API_PREFIX,
  TestContext,
  bootstrapTestApp,
  crearLotePrueba,
  limpiarTodosLosLotesE2E,
  loginAsE2EUser,
} from './helpers/test-setup';

describe('Sprint 6B - Sensores IoT (E2E)', () => {
  let app: INestApplication;
  let ctx: TestContext;
  let loteId: string;
  let sensorId: string;
  let lecturaId: string;

  const runId = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;

  beforeAll(async () => {
    app = await bootstrapTestApp();

    const token = await loginAsE2EUser(app);
    ctx = { app, token, apiPrefix: API_PREFIX };

    await limpiarTodosLosLotesE2E(ctx);
    loteId = await crearLotePrueba(ctx, 'Lote Sensores Sprint 6B', 0.1);
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
    it('POST /sensores sin token debe responder 401', async () => {
      const res = await request(app.getHttpServer()).post(`${API_PREFIX}/sensores`).send({
        nombre: 'Sensor sin auth',
        tipo: 'humedad_suelo',
        loteId,
        unidadMedida: '%',
      });

      expect(res.status).toBe(401);
    });

    it('GET /sensores sin token debe responder 401', async () => {
      const res = await request(app.getHttpServer()).get(`${API_PREFIX}/sensores`);
      expect(res.status).toBe(401);
    });
  });

  describe('CRUD sensores', () => {
    it('debe crear un sensor de humedad de suelo asociado al lote', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/sensores`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          nombre: `Sensor humedad ${runId}`,
          tipo: 'humedad_suelo',
          identificadorFisico: `BLE-${runId}`,
          loteId,
          estado: 'activo',
          unidadMedida: '%',
        });

      expect(res.status).toBe(201);

      const payload = unwrap(res);

      expect(payload.id).toBeDefined();
      expect(payload.nombre).toBe(`Sensor humedad ${runId}`);
      expect(payload.tipo).toBe('humedad_suelo');
      expect(payload.loteId).toBe(loteId);
      expect(payload.estado).toBe('activo');
      expect(payload.unidadMedida).toBe('%');
      expect(payload.identificadorFisico).toBe(`BLE-${runId}`);

      sensorId = payload.id;
    });

    it('debe listar sensores filtrando por loteId', async () => {
      const res = await request(app.getHttpServer())
        .get(`${API_PREFIX}/sensores`)
        .query({ loteId })
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(200);

      const payload = unwrap(res);

      expect(Array.isArray(payload.data)).toBe(true);
      expect(payload.total).toBeGreaterThanOrEqual(1);

      const sensor = payload.data.find((item: any) => item.id === sensorId);
      expect(sensor).toBeDefined();
    });

    it('debe obtener un sensor por ID', async () => {
      const res = await request(app.getHttpServer())
        .get(`${API_PREFIX}/sensores/${sensorId}`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(200);

      const payload = unwrap(res);

      expect(payload.id).toBe(sensorId);
      expect(payload.loteId).toBe(loteId);
    });

    it('debe actualizar metadatos del sensor', async () => {
      const res = await request(app.getHttpServer())
        .patch(`${API_PREFIX}/sensores/${sensorId}`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          nombre: `Sensor humedad actualizado ${runId}`,
          estado: 'activo',
        });

      expect(res.status).toBe(200);

      const payload = unwrap(res);

      expect(payload.id).toBe(sensorId);
      expect(payload.nombre).toBe(`Sensor humedad actualizado ${runId}`);
      expect(payload.estado).toBe('activo');
    });
  });

  describe('Lecturas de sensores', () => {
    it('debe registrar una lectura manual individual', async () => {
      const medidoEn = new Date().toISOString();

      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/sensores/${sensorId}/lecturas`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          valor: 42.5,
          unidad: '%',
          calidadSenal: 90,
          origen: 'manual',
          medidoEn,
          clientLocalId: `lectura-individual-${runId}`,
        });

      expect(res.status).toBe(201);

      const payload = unwrap(res);

      expect(payload.id).toBeDefined();
      expect(payload.sensorId).toBe(sensorId);
      expect(payload.loteId).toBe(loteId);
      expect(payload.valor).toBe(42.5);
      expect(payload.unidad).toBe('%');
      expect(payload.origen).toBe('manual');
      expect(payload.clientLocalId).toBe(`lectura-individual-${runId}`);

      lecturaId = payload.id;
    });

    it('debe devolver la ultima lectura del sensor', async () => {
      const res = await request(app.getHttpServer())
        .get(`${API_PREFIX}/sensores/${sensorId}/ultima`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(200);

      const payload = unwrap(res);

      expect(payload.id).toBe(lecturaId);
      expect(payload.sensorId).toBe(sensorId);
      expect(payload.valor).toBe(42.5);
    });

    it('debe listar historico paginado de lecturas', async () => {
      const res = await request(app.getHttpServer())
        .get(`${API_PREFIX}/sensores/${sensorId}/lecturas`)
        .query({ page: 1, limit: 10 })
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(200);

      const payload = unwrap(res);

      expect(Array.isArray(payload.data)).toBe(true);
      expect(payload.total).toBeGreaterThanOrEqual(1);

      const lectura = payload.data.find((item: any) => item.id === lecturaId);
      expect(lectura).toBeDefined();
    });

    it('debe registrar batch offline de lecturas e identificar duplicados por clientLocalId', async () => {
      const clientLocalId = `lectura-batch-${runId}`;
      const medidoEn = new Date(Date.now() + 1000).toISOString();

      const first = await request(app.getHttpServer())
        .post(`${API_PREFIX}/sensores/lecturas/batch`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          deviceId: `device-${runId}`,
          items: [
            {
              sensorId,
              valor: 44.25,
              unidad: '%',
              calidadSenal: 88,
              origen: 'simulado',
              medidoEn,
              clientLocalId,
            },
          ],
        });

      expect(first.status).toBe(201);

      const firstPayload = unwrap(first);

      expect(firstPayload.summary.total).toBe(1);
      expect(firstPayload.summary.created).toBe(1);
      expect(firstPayload.results[0].status).toBe('created');
      expect(firstPayload.results[0].lecturaId).toBeDefined();

      const duplicate = await request(app.getHttpServer())
        .post(`${API_PREFIX}/sensores/lecturas/batch`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          deviceId: `device-${runId}`,
          items: [
            {
              sensorId,
              valor: 99,
              unidad: '%',
              calidadSenal: 10,
              origen: 'simulado',
              medidoEn,
              clientLocalId,
            },
          ],
        });

      expect(duplicate.status).toBe(201);

      const duplicatePayload = unwrap(duplicate);

      expect(duplicatePayload.summary.total).toBe(1);
      expect(duplicatePayload.summary.duplicate).toBe(1);
      expect(duplicatePayload.results[0].status).toBe('duplicate');
      expect(duplicatePayload.results[0].lecturaId).toBe(firstPayload.results[0].lecturaId);
    });

    it('debe devolver error por item si el batch trae sensor inexistente', async () => {
      const res = await request(app.getHttpServer())
        .post(`${API_PREFIX}/sensores/lecturas/batch`)
        .set('Authorization', `Bearer ${ctx.token}`)
        .send({
          items: [
            {
              sensorId: '00000000-0000-4000-8000-000000000000',
              valor: 30,
              unidad: '%',
              origen: 'manual',
              medidoEn: new Date().toISOString(),
              clientLocalId: `lectura-error-${runId}`,
            },
          ],
        });

      expect(res.status).toBe(201);

      const payload = unwrap(res);

      expect(payload.summary.total).toBe(1);
      expect(payload.summary.error).toBe(1);
      expect(payload.results[0].status).toBe('error');
      expect(payload.results[0].error).toContain('Sensor');
    });
  });

  describe('Soft-delete', () => {
    it('debe eliminar logicamente el sensor', async () => {
      const res = await request(app.getHttpServer())
        .delete(`${API_PREFIX}/sensores/${sensorId}`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(204);
    });

    it('debe responder 404 al consultar sensor eliminado', async () => {
      const res = await request(app.getHttpServer())
        .get(`${API_PREFIX}/sensores/${sensorId}`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(404);
    });
  });
});
