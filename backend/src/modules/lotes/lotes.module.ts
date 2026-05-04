import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Lote } from './entities/lote.entity';
import { LotesController } from './lotes.controller';
import { LotesRepository } from './lotes.repository';
import { LotesService } from './lotes.service';

@Module({
  imports: [TypeOrmModule.forFeature([Lote])],
  controllers: [LotesController],
  providers: [LotesService, LotesRepository],
  exports: [LotesService],
})
export class LotesModule {}
