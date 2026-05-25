import { INestApplication } from '@nestjs/common';
import { DataSource } from 'typeorm';
import request from 'supertest';

import { HistorialClima } from '../src/modules/weather/entities/historial-clima.entity';
import {
  API_PREFIX,
  TestContext,
  bootstrapTestApp,
  crearLotePrueba,
  limpiarTodosLosLotesE2E,
  loginAsE2EUser,
} from './helpers/test-setup';

describe('Sprint 6C - Historial climatico por lote (E2E)', () => {
  let app: INestApplication;
  let dataSource: DataSource;
  let ctx: TestContext;
  let loteId: string;

  beforeAll(async () => {
    app = await bootstrapTestApp();
    dataSource = app.get(DataSource);

    const token = await loginAsE2EUser(app);
    ctx = { app, token, apiPrefix: API_PREFIX };

    await limpiarTodosLosLotesE2E(ctx);
    loteId = await crearLotePrueba(ctx, 'Lote Historial Clima Sprint 6C', 0.1);

    await dataSource.getRepository(HistorialClima).save([
      dataSource.getRepository(HistorialClima).create({
        loteId,
        fecha: '2026-05-20',
        temperatura: 31.2,
        probabilidadLluvia: 65,
        precipitacionMm: 4.5,
        humedadSuelo: 0.42,
        humedadRelativa: 78,
        viento: 8.2,
        fuente: 'open-meteo',
        registradoEn: new Date('2026-05-20T12:00:00.000Z'),
      }),
      dataSource.getRepository(HistorialClima).create({
        loteId,
        fecha: '2026-05-21',
        temperatura: 30.7,
        probabilidadLluvia: 20,
        precipitacionMm: 0,
        humedadSuelo: 0.38,
        humedadRelativa: 73,
        viento: 7.1,
        fuente: 'open-meteo',
        registradoEn: new Date('2026-05-21T12:00:00.000Z'),
      }),
    ]);
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

  it('GET /weather/lote/:loteId/historial sin token debe responder 401', async () => {
    const res = await request(app.getHttpServer()).get(
      `${API_PREFIX}/weather/lote/${loteId}/historial`,
    );
    expect(res.status).toBe(401);
  });

  it('debe consultar historial climatico completo del lote', async () => {
    const res = await request(app.getHttpServer())
      .get(`${API_PREFIX}/weather/lote/${loteId}/historial`)
      .set('Authorization', `Bearer ${ctx.token}`);

    expect(res.status).toBe(200);

    const payload = unwrap(res);

    expect(Array.isArray(payload)).toBe(true);
    expect(payload.length).toBeGreaterThanOrEqual(2);

    const dia20 = payload.find((item: any) => item.fecha === '2026-05-20');

    expect(dia20).toBeDefined();
    expect(Number(dia20.temperatura)).toBe(31.2);
    expect(Number(dia20.precipitacionMm)).toBe(4.5);
    expect(dia20.fuente).toBe('open-meteo');
  });

  it('debe filtrar historial por rango desde/hasta', async () => {
    const res = await request(app.getHttpServer())
      .get(`${API_PREFIX}/weather/lote/${loteId}/historial`)
      .query({
        desde: '2026-05-21',
        hasta: '2026-05-21',
      })
      .set('Authorization', `Bearer ${ctx.token}`);

    expect(res.status).toBe(200);

    const payload = unwrap(res);

    expect(Array.isArray(payload)).toBe(true);
    expect(payload.length).toBe(1);
    expect(payload[0].fecha).toBe('2026-05-21');
    expect(Number(payload[0].precipitacionMm)).toBe(0);
  });

  it('debe responder 400 si loteId no es UUID', async () => {
    const res = await request(app.getHttpServer())
      .get(`${API_PREFIX}/weather/lote/no-es-uuid/historial`)
      .set('Authorization', `Bearer ${ctx.token}`);

    expect(res.status).toBe(400);
  });
});
