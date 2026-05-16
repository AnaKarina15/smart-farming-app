import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Cultivo } from './entities/cultivo.entity';
import { Fertilizante } from './entities/fertilizante.entity';
import { Municipio } from './entities/municipio.entity';
import { Plaga } from './entities/plaga.entity';
import { TipoSuelo } from './entities/tipo-suelo.entity';

/**
 * Repositorio unico para los 5 catalogos. Centraliza el acceso a datos
 * para evitar duplicar boilerplate de TypeORM en cada catalogo.
 *
 * Cada metodo respeta el filtro de soft-delete por defecto (TypeORM lo aplica
 * automaticamente cuando la entidad usa @DeleteDateColumn con find/findOne).
 */
@Injectable()
export class CatalogosRepository {
  constructor(
    @InjectRepository(Municipio)
    private readonly municipios: Repository<Municipio>,
    @InjectRepository(Cultivo)
    private readonly cultivos: Repository<Cultivo>,
    @InjectRepository(Plaga)
    private readonly plagas: Repository<Plaga>,
    @InjectRepository(Fertilizante)
    private readonly fertilizantes: Repository<Fertilizante>,
    @InjectRepository(TipoSuelo)
    private readonly tiposSuelo: Repository<TipoSuelo>,
  ) {}

  // Exponemos los repos para que el service haga queries especificas.
  get municipiosRepo(): Repository<Municipio> {
    return this.municipios;
  }

  get cultivosRepo(): Repository<Cultivo> {
    return this.cultivos;
  }

  get plagasRepo(): Repository<Plaga> {
    return this.plagas;
  }

  get fertilizantesRepo(): Repository<Fertilizante> {
    return this.fertilizantes;
  }

  get tiposSueloRepo(): Repository<TipoSuelo> {
    return this.tiposSuelo;
  }
}
