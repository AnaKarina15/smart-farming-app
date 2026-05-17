import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Siembra } from './entities/siembra.entity';

/**
 * Repository de Siembra.
 *
 * Expone el repositorio TypeORM para que el service tenga acceso
 * a queries complejas con joins.
 */
@Injectable()
export class SiembrasRepository {
  constructor(
    @InjectRepository(Siembra)
    public readonly repo: Repository<Siembra>,
  ) {}
}
