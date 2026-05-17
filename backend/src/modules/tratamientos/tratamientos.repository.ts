import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Tratamiento } from './entities/tratamiento.entity';

@Injectable()
export class TratamientosRepository {
  constructor(
    @InjectRepository(Tratamiento)
    public readonly repo: Repository<Tratamiento>,
  ) {}
}
