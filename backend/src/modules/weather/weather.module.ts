import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Lote } from '@/modules/lotes/entities/lote.entity';

import { HistorialClima } from './entities/historial-clima.entity';
import { WeatherCache } from './entities/weather-cache.entity';
import { WeatherController } from './weather.controller';
import { WeatherLoteService } from './weather-lote.service';
import { WeatherRepository } from './weather.repository';
import { WeatherService } from './weather.service';
import { WeatherHistorialService } from './weather-historial.service';

/**
 * Modulo de integracion climatica (Sprint 6).
 *
 * - WeatherService: consulta Open-Meteo + cache resiliente en BD.
 * - WeatherLoteService: resuelve clima por lote validando propiedad.
 * - WeatherCache: tabla de cache para resiliencia offline-first.
 */
@Module({
  imports: [HttpModule, TypeOrmModule.forFeature([WeatherCache, HistorialClima, Lote])],
  controllers: [WeatherController],
  providers: [WeatherService, WeatherLoteService, WeatherHistorialService, WeatherRepository],
  exports: [WeatherService, WeatherLoteService, WeatherHistorialService],
})
export class WeatherModule {}
