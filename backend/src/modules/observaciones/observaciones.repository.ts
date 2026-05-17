import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Observacion } from './entities/observacion.entity';

@Injectable()
export class ObservacionesRepository {
  constructor(
    @InjectRepository(Observacion)
    public readonly repo: Repository<Observacion>,
  ) {}
}
