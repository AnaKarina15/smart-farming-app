import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EstadoTerreno } from './entities/estado-terreno.entity';

@Injectable()
export class EstadoTerrenoRepository {
  constructor(
    @InjectRepository(EstadoTerreno)
    public readonly repo: Repository<EstadoTerreno>,
  ) {}
}
