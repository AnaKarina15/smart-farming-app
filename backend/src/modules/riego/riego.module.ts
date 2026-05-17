import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { Riego } from './entities/riego.entity';
import { RiegoController } from './riego.controller';
import { RiegoRepository } from './riego.repository';
import { RiegoService } from './riego.service';

@Module({
  imports: [TypeOrmModule.forFeature([Riego, Lote])],
  controllers: [RiegoController],
  providers: [RiegoService, RiegoRepository],
  exports: [RiegoService],
})
export class RiegoModule {}
