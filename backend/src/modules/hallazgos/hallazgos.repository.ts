import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Hallazgo } from './entities/hallazgo.entity';

@Injectable()
export class HallazgosRepository {
  constructor(
    @InjectRepository(Hallazgo)
    public readonly repo: Repository<Hallazgo>,
  ) {}
}
