import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Fertilizacion } from './entities/fertilizacion.entity';

@Injectable()
export class FertilizacionRepository {
  constructor(
    @InjectRepository(Fertilizacion)
    public readonly repo: Repository<Fertilizacion>,
  ) {}
}
