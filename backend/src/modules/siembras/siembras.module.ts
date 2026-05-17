import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { Siembra } from './entities/siembra.entity';
import { SiembrasController } from './siembras.controller';
import { SiembrasRepository } from './siembras.repository';
import { SiembrasService } from './siembras.service';

@Module({
  imports: [TypeOrmModule.forFeature([Siembra, Lote])],
  controllers: [SiembrasController],
  providers: [SiembrasService, SiembrasRepository],
  exports: [SiembrasService],
})
export class SiembrasModule {}
