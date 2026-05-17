import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { Hallazgo } from './entities/hallazgo.entity';
import { HallazgosController } from './hallazgos.controller';
import { HallazgosRepository } from './hallazgos.repository';
import { HallazgosService } from './hallazgos.service';

@Module({
  imports: [TypeOrmModule.forFeature([Hallazgo, Lote])],
  controllers: [HallazgosController],
  providers: [HallazgosService, HallazgosRepository],
  exports: [HallazgosService],
})
export class HallazgosModule {}
