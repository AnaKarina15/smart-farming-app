import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Lote } from './entities/lote.entity';

@Injectable()
export class LotesRepository {
  constructor(
    @InjectRepository(Lote)
    private readonly repo: Repository<Lote>,
  ) {}

  async findById(id: string): Promise<Lote | null> {
    return this.repo.findOne({ where: { id } });
  }

  async findByPropietario(propietarioId: string): Promise<Lote[]> {
    return this.repo.find({
      where: { propietarioId },
      order: { createdAt: 'DESC' },
    });
  }

  async create(data: Partial<Lote>): Promise<Lote> {
    const lote = this.repo.create(data);
    return this.repo.save(lote);
  }

  async update(id: string, data: Partial<Lote>): Promise<void> {
    await this.repo.update(id, data);
  }

  async delete(id: string): Promise<void> {
    await this.repo.delete(id);
  }

  async sumSuperficieByPropietario(propietarioId: string, excludeLoteId?: string): Promise<number> {
    const qb = this.repo
      .createQueryBuilder('lote')
      .select('COALESCE(SUM(lote.superficieHectareas), 0)', 'total')
      .where('lote.propietarioId = :propietarioId', { propietarioId });

    if (excludeLoteId) {
      qb.andWhere('lote.id != :excludeLoteId', { excludeLoteId });
    }

    const result = await qb.getRawOne<{ total: string }>();
    return Number(result?.total ?? 0);
  }

  async findAll(): Promise<Lote[]> {
    return this.repo.find({
      relations: ['propietario'],
      order: { createdAt: 'DESC' },
    });
  }
}
