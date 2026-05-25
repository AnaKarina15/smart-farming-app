import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { HistorialClima } from '../weather/entities/historial-clima.entity';
import { WeatherService } from '../weather/weather.service';
import { LecturaSensor } from '../sensores/entities/lectura-sensor.entity';
import { EstadoSensor, TipoSensor } from '../sensores/entities/sensor.entity';
import { Lote } from '../lotes/entities/lote.entity';
import { Estacion } from './entities/estacion.enum';

export interface ContextoClimaticoLote {
  humedadSuelo: number | null;
  fuenteHumedad: 'sensor' | 'open-meteo' | 'ninguna';
  llovioUltimos3Dias: boolean;
  lluviaProximas48h: boolean;
  estacionInferida: Estacion | null;
}

@Injectable()
export class ContextoClimaticoService {
  private readonly logger = new Logger(ContextoClimaticoService.name);

  constructor(
    @InjectRepository(LecturaSensor)
    private readonly lecturasRepo: Repository<LecturaSensor>,

    @InjectRepository(HistorialClima)
    private readonly historialRepo: Repository<HistorialClima>,

    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,

    private readonly weatherService: WeatherService,
  ) {}

  async getContextoParaLote(loteId: string): Promise<ContextoClimaticoLote> {
    const humedadSensor = await this.getUltimaHumedadSensor(loteId);
    const historial = await this.getUltimoHistorial(loteId);
    const llovioUltimos3Dias = await this.llovioUltimosDias(loteId, 3);
    const lluviaProximas48h = await this.hayLluviaProximas48h(loteId);

    const humedadOpenMeteo =
      historial?.humedadSuelo !== null && historial?.humedadSuelo !== undefined
        ? this.normalizarHumedad(Number(historial.humedadSuelo))
        : null;

    const humedadSuelo = humedadSensor ?? humedadOpenMeteo;
    const fuenteHumedad =
      humedadSensor !== null ? 'sensor' : humedadOpenMeteo !== null ? 'open-meteo' : 'ninguna';

    return {
      humedadSuelo,
      fuenteHumedad,
      llovioUltimos3Dias,
      lluviaProximas48h,
      estacionInferida: this.inferirEstacion(llovioUltimos3Dias, lluviaProximas48h),
    };
  }

  private async getUltimaHumedadSensor(loteId: string): Promise<number | null> {
    const lectura = await this.lecturasRepo
      .createQueryBuilder('lectura')
      .innerJoin('lectura.sensor', 'sensor')
      .where('lectura.loteId = :loteId', { loteId })
      .andWhere('sensor.tipo = :tipo', { tipo: TipoSensor.HUMEDAD_SUELO })
      .andWhere('sensor.estado = :estado', { estado: EstadoSensor.ACTIVO })
      .orderBy('lectura.medidoEn', 'DESC')
      .getOne();

    if (!lectura) return null;

    return this.normalizarHumedad(Number(lectura.valor));
  }

  private async getUltimoHistorial(loteId: string): Promise<HistorialClima | null> {
    return this.historialRepo.findOne({
      where: { loteId },
      order: { fecha: 'DESC' },
    });
  }

  private async llovioUltimosDias(loteId: string, dias: number): Promise<boolean> {
    const desde = new Date();
    desde.setDate(desde.getDate() - dias);

    const count = await this.historialRepo
      .createQueryBuilder('h')
      .where('h.loteId = :loteId', { loteId })
      .andWhere('h.fecha >= :desde', { desde: desde.toISOString().slice(0, 10) })
      .andWhere('h.precipitacionMm > 0')
      .getCount();

    return count > 0;
  }

  private async hayLluviaProximas48h(loteId: string): Promise<boolean> {
    const lote = await this.lotesRepo.findOne({ where: { id: loteId } });

    if (!lote?.latitud || !lote?.longitud) {
      return false;
    }

    try {
      const weather = await this.weatherService.getWeather(
        Number(lote.latitud),
        Number(lote.longitud),
        2,
      );

      return weather.pronostico.slice(0, 2).some((dia) => {
        return Number(dia.precipitacionMm) > 0.5 || Number(dia.probabilidadLluvia) >= 60;
      });
    } catch (error) {
      this.logger.warn(
        `No fue posible calcular pronostico 48h para lote ${loteId}: ${(error as Error).message}`,
      );
      return false;
    }
  }

  private inferirEstacion(
    llovioUltimos3Dias: boolean,
    lluviaProximas48h: boolean,
  ): Estacion | null {
    if (llovioUltimos3Dias || lluviaProximas48h) {
      return Estacion.LLUVIOSA;
    }

    return null;
  }

  private normalizarHumedad(value: number): number | null {
    if (!Number.isFinite(value)) return null;

    const porcentaje = value >= 0 && value <= 1 ? value * 100 : value;

    return Math.max(0, Math.min(100, Number(porcentaje.toFixed(2))));
  }
}
