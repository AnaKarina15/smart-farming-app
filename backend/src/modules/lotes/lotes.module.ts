import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { EstadoTerreno } from '../estado-terreno/entities/estado-terreno.entity';
import { Fertilizacion } from '../fertilizacion/entities/fertilizacion.entity';
import { Hallazgo } from '../hallazgos/entities/hallazgo.entity';
import { Observacion } from '../observaciones/entities/observacion.entity';
import { Riego } from '../riego/entities/riego.entity';
import { Siembra } from '../siembras/entities/siembra.entity';
import { Tratamiento } from '../tratamientos/entities/tratamiento.entity';
import { Lote } from './entities/lote.entity';
import { LotesController } from './lotes.controller';
import { LotesRepository } from './lotes.repository';
import { LotesService } from './lotes.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Lote,
      Siembra,
      Riego,
      Fertilizacion,
      Hallazgo,
      Tratamiento,
      Observacion,
      EstadoTerreno,
    ]),
  ],
  controllers: [LotesController],
  providers: [LotesService, LotesRepository],
  exports: [LotesService],
})
export class LotesModule {}
