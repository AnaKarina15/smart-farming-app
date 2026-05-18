import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { Siembra } from './entities/siembra.entity';
import { EstadoTerreno } from '../estado-terreno/entities/estado-terreno.entity';
import { Cultivo } from '../catalogos/entities/cultivo.entity';
import { SiembrasController } from './siembras.controller';
import { SiembrasRepository } from './siembras.repository';
import { SiembrasService } from './siembras.service';

@Module({
  imports: [TypeOrmModule.forFeature([Siembra, Lote, EstadoTerreno, Cultivo])],
  controllers: [SiembrasController],
  providers: [SiembrasService, SiembrasRepository],
  exports: [SiembrasService],
})
export class SiembrasModule {}
