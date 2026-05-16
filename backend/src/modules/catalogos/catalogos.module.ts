import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { CatalogosController } from './catalogos.controller';
import { CatalogosRepository } from './catalogos.repository';
import { CatalogosService } from './catalogos.service';
import { Cultivo } from './entities/cultivo.entity';
import { Fertilizante } from './entities/fertilizante.entity';
import { Municipio } from './entities/municipio.entity';
import { Plaga } from './entities/plaga.entity';
import { TipoSuelo } from './entities/tipo-suelo.entity';

/**
 * Modulo de catalogos del dominio agricola del Magdalena.
 *
 * Expone los catalogos como recursos REST y los hace disponibles
 * para otros modulos que necesiten relacionar entidades (ej: Lotes
 * con Cultivos, Siembras con Cultivos, Fertilizaciones con Fertilizantes).
 */
@Module({
  imports: [TypeOrmModule.forFeature([Municipio, Cultivo, Plaga, Fertilizante, TipoSuelo])],
  controllers: [CatalogosController],
  providers: [CatalogosRepository, CatalogosService],
  exports: [CatalogosService, TypeOrmModule],
})
export class CatalogosModule {}
