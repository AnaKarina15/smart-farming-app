import { HttpService } from '@nestjs/axios';
import { Injectable, Logger } from '@nestjs/common';
import { firstValueFrom } from 'rxjs';

import { WeatherResponseDto } from './dto/weather-response.dto';
import { WeatherRepository } from './weather.repository';

/**
 * Servicio de integracion climatica (Sprint 6).
 *
 * Estrategia offline-first del lado servidor:
 * 1. Consulta Open-Meteo (API publica, sin API key).
 * 2. Persiste el resultado en weather_cache por celda geografica.
 * 3. Si Open-Meteo no responde, sirve el ultimo dato cacheado en vez
 *    de fallar. La frescura del cache se informa al cliente.
 *
 * No requiere API key: Open-Meteo es gratuita para uso no comercial.
 */
@Injectable()
export class WeatherService {
  private readonly logger = new Logger(WeatherService.name);
  private readonly baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /** Horas que un dato de cache se considera "fresco". */
  private readonly CACHE_TTL_HORAS = 2;

  constructor(
    private readonly httpService: HttpService,
    private readonly weatherRepo: WeatherRepository,
  ) {}

  /**
   * Devuelve el clima de una ubicacion: actual + pronostico extendido.
   *
   * @param dias numero de dias de pronostico (1-7).
   */
  async getWeather(lat: number, lon: number, dias = 5): Promise<WeatherResponseDto> {
    const geoKey = this.buildGeoKey(lat, lon);
    const diasClamp = Math.min(Math.max(dias, 1), 7);

    // 1. Intentar servir cache fresco (evita golpear la API innecesariamente)
    const cache = await this.weatherRepo.findByGeoKey(geoKey);
    if (cache && this.cacheEsFresco(cache.obtenidoEn)) {
      return this.toResponse(cache, 'cache', false);
    }

    // 2. Consultar Open-Meteo
    try {
      const fresh = await this.fetchOpenMeteo(lat, lon, diasClamp);

      const saved = await this.weatherRepo.upsert({
        geoKey,
        latitud: lat,
        longitud: lon,
        actual: fresh.actual as unknown as Record<string, unknown>,
        pronostico: fresh.pronostico as unknown as Record<string, unknown>[],
        obtenidoEn: new Date(),
      });

      return this.toResponse(saved, 'open-meteo', false);
    } catch (error) {
      // 3. Fallback: si la API fallo pero hay cache (aunque viejo), servirlo
      this.logger.warn(
        `Open-Meteo no respondio para ${geoKey}: ${(error as Error).message}. ` +
          (cache ? 'Sirviendo cache.' : 'Sin cache disponible.'),
      );

      if (cache) {
        return this.toResponse(cache, 'cache', true);
      }

      // Sin cache y sin API: devolver estructura vacia pero valida
      return this.respuestaVacia(lat, lon);
    }
  }

  // ──────────────────────────────────────────────────────────
  // Helpers privados
  // ──────────────────────────────────────────────────────────

  /**
   * Llama a Open-Meteo y normaliza la respuesta al formato del proyecto.
   */
  private async fetchOpenMeteo(
    lat: number,
    lon: number,
    dias: number,
  ): Promise<Pick<WeatherResponseDto, 'actual' | 'pronostico'>> {
    const params = [
      `latitude=${lat}`,
      `longitude=${lon}`,
      'current=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation,soil_moisture_0_to_1cm',
      'hourly=precipitation_probability',
      'daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum',
      'timezone=auto',
      `forecast_days=${dias}`,
    ].join('&');

    const url = `${this.baseUrl}?${params}`;
    const response = await firstValueFrom(this.httpService.get(url, { timeout: 8000 }));
    const data = response.data ?? {};

    const current = data.current ?? {};
    const hourly = data.hourly ?? {};
    const daily = data.daily ?? {};

    const actual = {
      temperatura: this.num(current.temperature_2m),
      unidadTemperatura: 'C',
      probabilidadLluvia: this.num(hourly.precipitation_probability?.[0]),
      viento: this.num(current.wind_speed_10m),
      humedadRelativa: this.numOrNull(current.relative_humidity_2m),
      humedadSuelo: this.numOrNull(current.soil_moisture_0_to_1cm),
    };

    const fechas: string[] = daily.time ?? [];
    const pronostico = fechas.map((fecha, i) => ({
      fecha,
      tempMax: this.num(daily.temperature_2m_max?.[i]),
      tempMin: this.num(daily.temperature_2m_min?.[i]),
      probabilidadLluvia: this.num(daily.precipitation_probability_max?.[i]),
      precipitacionMm: this.num(daily.precipitation_sum?.[i]),
    }));

    return { actual, pronostico };
  }

  private buildGeoKey(lat: number, lon: number): string {
    return `${lat.toFixed(2)},${lon.toFixed(2)}`;
  }

  private cacheEsFresco(obtenidoEn: Date): boolean {
    const edadMs = Date.now() - new Date(obtenidoEn).getTime();
    return edadMs < this.CACHE_TTL_HORAS * 60 * 60 * 1000;
  }

  private toResponse(
    cache: { latitud: number; longitud: number; actual: any; pronostico: any; obtenidoEn: Date },
    fuente: 'open-meteo' | 'cache',
    desdeCacheFallback: boolean,
  ): WeatherResponseDto {
    return {
      latitud: Number(cache.latitud),
      longitud: Number(cache.longitud),
      actual: cache.actual,
      pronostico: cache.pronostico,
      obtenidoEn: new Date(cache.obtenidoEn).toISOString(),
      fuente,
      desdeCacheFallback,
    };
  }

  private respuestaVacia(lat: number, lon: number): WeatherResponseDto {
    return {
      latitud: lat,
      longitud: lon,
      actual: {
        temperatura: 0,
        unidadTemperatura: 'C',
        probabilidadLluvia: 0,
        viento: 0,
        humedadRelativa: null,
        humedadSuelo: null,
      },
      pronostico: [],
      obtenidoEn: new Date().toISOString(),
      fuente: 'cache',
      desdeCacheFallback: true,
    };
  }

  private num(value: unknown): number {
    const n = Number(value);
    return Number.isFinite(n) ? n : 0;
  }

  private numOrNull(value: unknown): number | null {
    if (value === null || value === undefined) return null;
    const n = Number(value);
    return Number.isFinite(n) ? n : null;
  }
}
