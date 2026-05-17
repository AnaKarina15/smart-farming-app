import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Riego } from './entities/riego.entity';

@Injectable()
export class RiegoRepository {
  constructor(
    @InjectRepository(Riego)
    public readonly repo: Repository<Riego>,
  ) {}
}
