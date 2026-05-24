import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { RecomendacionAplicada } from './entities/recomendacion-aplicada.entity';
import { Regla } from './entities/regla.entity';

/**
 * Repository ligero: expone los Repository<T> de TypeORM
 * para que el service haga queries complejas con QueryBuilder.
 */
@Injectable()
export class RecomendacionesRepository {
  constructor(
    @InjectRepository(Regla)
    public readonly reglas: Repository<Regla>,
    @InjectRepository(RecomendacionAplicada)
    public readonly aplicadas: Repository<RecomendacionAplicada>,
  ) {}
}
