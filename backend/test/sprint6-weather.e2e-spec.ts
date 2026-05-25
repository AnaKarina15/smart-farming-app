import request from 'supertest';

import {
  API_PREFIX,
  TestContext,
  bootstrapTestApp,
  crearLotePrueba,
  limpiarTodosLosLotesE2E,
  loginAsE2EUser,
} from './helpers/test-setup';

/**
 * E2E - Sprint 6: Integracion climatica.
 *
 * Nota: estos tests dependen de la API publica Open-Meteo. Si no hay
 * internet, el modulo responde con fallback de cache; los tests validan
 * la forma de la respuesta y la seguridad, no valores meteorologicos exactos.
 */
describe('Sprint 6 - Weather (E2E)', () => {
  let ctx: TestContext;

  beforeAll(async () => {
    const app = await bootstrapTestApp();
    const token = await loginAsE2EUser(app);
    ctx = { app, token, apiPrefix: API_PREFIX };
    await limpiarTodosLosLotesE2E(ctx);
  }, 60000);

  afterAll(async () => {
    await limpiarTodosLosLotesE2E(ctx);
    await ctx.app.close();
  });

  describe('Seguridad', () => {
    it('GET /weather/current sin token debe responder 401', async () => {
      const res = await request(ctx.app.getHttpServer()).get(
        `${ctx.apiPrefix}/weather/current?lat=11.24&lon=-74.2`,
      );
      expect(res.status).toBe(401);
    });
  });

  describe('GET /weather/current', () => {
    it('debe devolver clima actual y pronostico para coordenadas validas', async () => {
      const res = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/weather/current?lat=11.24&lon=-74.2`)
        .set('Authorization', `Bearer ${ctx.token}`);

      expect(res.status).toBe(200);
      const data = res.body?.data ?? res.body;
      expect(data).toHaveProperty('actual');
      expect(data).toHaveProperty('pronostico');
      expect(data.actual).toHaveProperty('temperatura');
      expect(Array.isArray(data.pronostico)).toBe(true);
      expect(['open-meteo', 'cache']).toContain(data.fuente);
    }, 20000);

    it('debe responder 400 con coordenadas invalidas', async () => {
      const res = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/weather/current?lat=999&lon=-74.2`)
        .set('Authorization', `Bearer ${ctx.token}`);
      expect(res.status).toBe(400);
    });
  });

  describe('GET /weather/lote/:loteId', () => {
    it('debe responder 400 con un loteId que no es UUID', async () => {
      const res = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/weather/lote/no-es-uuid`)
        .set('Authorization', `Bearer ${ctx.token}`);
      expect(res.status).toBe(400);
    });

    it('debe responder 404 si el lote no tiene coordenadas', async () => {
      // crearLotePrueba crea el lote sin lat/lon
      const loteId = await crearLotePrueba(ctx, 'Lote sin coords');
      const res = await request(ctx.app.getHttpServer())
        .get(`${ctx.apiPrefix}/weather/lote/${loteId}`)
        .set('Authorization', `Bearer ${ctx.token}`);
      expect(res.status).toBe(404);
    });
  });
});
