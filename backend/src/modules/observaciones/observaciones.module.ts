import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { Observacion } from './entities/observacion.entity';
import { ObservacionesController } from './observaciones.controller';
import { ObservacionesRepository } from './observaciones.repository';
import { ObservacionesService } from './observaciones.service';

@Module({
  imports: [TypeOrmModule.forFeature([Observacion, Lote])],
  controllers: [ObservacionesController],
  providers: [ObservacionesService, ObservacionesRepository],
  exports: [ObservacionesService],
})
export class ObservacionesModule {}
