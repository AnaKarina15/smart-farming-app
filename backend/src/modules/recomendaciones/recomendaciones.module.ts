import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Hallazgo } from '../hallazgos/entities/hallazgo.entity';
import { Lote } from '../lotes/entities/lote.entity';
import { Riego } from '../riego/entities/riego.entity';
import { Siembra } from '../siembras/entities/siembra.entity';

import { RecomendacionAplicada } from './entities/recomendacion-aplicada.entity';
import { Regla } from './entities/regla.entity';
import { RecomendacionesController } from './recomendaciones.controller';
import { RecomendacionesRepository } from './recomendaciones.repository';
import { RecomendacionesService } from './recomendaciones.service';
import { LecturaSensor } from '../sensores/entities/lectura-sensor.entity';
import { Sensor } from '../sensores/entities/sensor.entity';
import { HistorialClima } from '../weather/entities/historial-clima.entity';
import { WeatherModule } from '../weather/weather.module';
import { ContextoClimaticoService } from './contexto-climatico.service';

/**
 * Modulo del Sistema Experto de Recomendaciones (Sprint 4).
 *
 * Importa las entidades operativas (Lote, Siembra, Hallazgo, Riego)
 * porque el motor necesita consultarlas para construir el contexto
 * del lote antes de evaluar las reglas IF-THEN.
 */
@Module({
  imports: [
    WeatherModule,
    TypeOrmModule.forFeature([
      // Entidades propias del modulo
      Regla,
      RecomendacionAplicada,
      // Entidades externas que el motor necesita leer
      Lote,
      Siembra,
      Hallazgo,
      Riego,
      Sensor,
      LecturaSensor,
      HistorialClima,
    ]),
  ],
  controllers: [RecomendacionesController],
  providers: [RecomendacionesService, RecomendacionesRepository, ContextoClimaticoService],
  exports: [RecomendacionesService],
})
export class RecomendacionesModule {}
