import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { WeatherCache } from './entities/weather-cache.entity';

/**
 * Acceso a la tabla weather_cache. Encapsula la lectura/escritura del
 * cache climatico para que el servicio no dependa directamente del ORM.
 */
@Injectable()
export class WeatherRepository {
  constructor(
    @InjectRepository(WeatherCache)
    private readonly repo: Repository<WeatherCache>,
  ) {}

  findByGeoKey(geoKey: string): Promise<WeatherCache | null> {
    return this.repo.findOne({ where: { geoKey } });
  }

  /**
   * Inserta o actualiza el cache de una celda geografica (upsert por geoKey).
   */
  async upsert(data: Partial<WeatherCache>): Promise<WeatherCache> {
    const existing = await this.repo.findOne({ where: { geoKey: data.geoKey } });
    const entity = existing ? Object.assign(existing, data) : this.repo.create(data);
    return this.repo.save(entity);
  }
}
