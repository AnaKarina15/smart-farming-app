import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { Fertilizacion } from './entities/fertilizacion.entity';
import { FertilizacionController } from './fertilizacion.controller';
import { FertilizacionRepository } from './fertilizacion.repository';
import { FertilizacionService } from './fertilizacion.service';

@Module({
  imports: [TypeOrmModule.forFeature([Fertilizacion, Lote])],
  controllers: [FertilizacionController],
  providers: [FertilizacionService, FertilizacionRepository],
  exports: [FertilizacionService],
})
export class FertilizacionModule {}
