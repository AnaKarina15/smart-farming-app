import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { Siembra } from '../siembras/entities/siembra.entity';
import { TipoSuelo } from '../catalogos/entities/tipo-suelo.entity';

import { EstadoTerreno } from './entities/estado-terreno.entity';
import { EstadoTerrenoController } from './estado-terreno.controller';
import { EstadoTerrenoRepository } from './estado-terreno.repository';
import { EstadoTerrenoService } from './estado-terreno.service';

@Module({
  imports: [TypeOrmModule.forFeature([EstadoTerreno, Lote, Siembra, TipoSuelo])],
  controllers: [EstadoTerrenoController],
  providers: [EstadoTerrenoService, EstadoTerrenoRepository],
  exports: [EstadoTerrenoService, EstadoTerrenoRepository],
})
export class EstadoTerrenoModule {}
