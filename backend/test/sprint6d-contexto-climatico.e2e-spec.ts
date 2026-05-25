import { INestApplication } from '@nestjs/common';
import { DataSource } from 'typeorm';

import { ContextoClimaticoService } from '../src/modules/recomendaciones/contexto-climatico.service';
import { HistorialClima } from '../src/modules/weather/entities/historial-clima.entity';
import {
  LecturaSensor,
  OrigenLecturaSensor,
} from '../src/modules/sensores/entities/lectura-sensor.entity';
import { EstadoSensor, Sensor, TipoSensor } from '../src/modules/sensores/entities/sensor.entity';
import {
  API_PREFIX,
  TestContext,
  bootstrapTestApp,
  crearLotePrueba,
  limpiarTodosLosLotesE2E,
  loginAsE2EUser,
} from './helpers/test-setup';

describe('Sprint 6D - Contexto climatico para Sistema Experto (E2E)', () => {
  let app: INestApplication;
  let dataSource: DataSource;
  let contextoClimaticoService: ContextoClimaticoService;
  let ctx: TestContext;
  let loteId: string;

  beforeAll(async () => {
    app = await bootstrapTestApp();
    dataSource = app.get(DataSource);
    contextoClimaticoService = app.get(ContextoClimaticoService);

    const token = await loginAsE2EUser(app);
    ctx = { app, token, apiPrefix: API_PREFIX };

    await limpiarTodosLosLotesE2E(ctx);
    loteId = await crearLotePrueba(ctx, 'Lote Contexto Climatico Sprint 6D', 0.1);
  }, 60000);

  afterAll(async () => {
    if (ctx) {
      await limpiarTodosLosLotesE2E(ctx);
    }

    if (app) {
      await app.close();
    }
  });

  it('debe preferir ultima lectura de sensor activo sobre humedad de Open-Meteo/historial', async () => {
    const sensorRepo = dataSource.getRepository(Sensor);
    const lecturaRepo = dataSource.getRepository(LecturaSensor);
    const historialRepo = dataSource.getRepository(HistorialClima);

    const userId = await obtenerUserIdE2E();

    const sensor = await sensorRepo.save(
      sensorRepo.create({
        nombre: 'Sensor humedad contexto',
        tipo: TipoSensor.HUMEDAD_SUELO,
        identificadorFisico: `CTX-${Date.now()}`,
        loteId,
        userId,
        estado: EstadoSensor.ACTIVO,
        unidadMedida: '%',
        ultimaLecturaEn: new Date('2026-05-24T10:00:00.000Z'),
      }),
    );

    await lecturaRepo.save(
      lecturaRepo.create({
        sensorId: sensor.id,
        loteId,
        valor: 55.5,
        unidad: '%',
        calidadSenal: 95,
        origen: OrigenLecturaSensor.MANUAL,
        medidoEn: new Date('2026-05-24T10:00:00.000Z'),
        userId,
        clientLocalId: `ctx-lectura-${Date.now()}`,
      }),
    );

    await historialRepo.save(
      historialRepo.create({
        loteId,
        fecha: '2026-05-24',
        temperatura: 31,
        probabilidadLluvia: 80,
        precipitacionMm: 6,
        humedadSuelo: 0.25,
        humedadRelativa: 79,
        viento: 6,
        fuente: 'open-meteo',
        registradoEn: new Date('2026-05-24T12:00:00.000Z'),
      }),
    );

    const contexto = await contextoClimaticoService.getContextoParaLote(loteId);

    expect(contexto.humedadSuelo).toBe(55.5);
    expect(contexto.fuenteHumedad).toBe('sensor');
    expect(contexto.llovioUltimos3Dias).toBe(true);
  });

  it('debe usar humedad de historial/Open-Meteo si no hay sensor activo', async () => {
    await dataSource.getRepository(LecturaSensor).delete({ loteId });
    await dataSource.getRepository(Sensor).delete({ loteId });

    const historialRepo = dataSource.getRepository(HistorialClima);

    await historialRepo.save(
      historialRepo.create({
        loteId,
        fecha: '2026-05-25',
        temperatura: 32,
        probabilidadLluvia: 10,
        precipitacionMm: 0,
        humedadSuelo: 0.37,
        humedadRelativa: 70,
        viento: 5,
        fuente: 'open-meteo',
        registradoEn: new Date('2026-05-25T12:00:00.000Z'),
      }),
    );

    const contexto = await contextoClimaticoService.getContextoParaLote(loteId);

    expect(contexto.humedadSuelo).toBe(37);
    expect(contexto.fuenteHumedad).toBe('open-meteo');
  });

  async function obtenerUserIdE2E(): Promise<string> {
    const raw = Buffer.from(ctx.token.split('.')[1], 'base64').toString('utf8');
    const payload = JSON.parse(raw);

    return payload.sub;
  }
});
