import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { UserRole } from '../users/entities/user-role.enum';

import { CreateRiegoDto } from './dto/create-riego.dto';
import { ListRiegoQueryDto } from './dto/list-riego-query.dto';
import { RiegoResponseDto } from './dto/riego-response.dto';
import { UpdateRiegoDto } from './dto/update-riego.dto';
import { RiegoRepository } from './riego.repository';

@Injectable()
export class RiegoService {
  constructor(
    private readonly riegoRepo: RiegoRepository,
    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,
  ) {}

  // ════════════════════════════════════════════════════════
  // CREATE
  // ════════════════════════════════════════════════════════

  async create(dto: CreateRiegoDto, userId: string, userRole: string): Promise<RiegoResponseDto> {
    await this.assertLoteOwnership(dto.loteId, userId, userRole);

    const entity = this.riegoRepo.repo.create({
      loteId: dto.loteId,
      tipo: dto.tipo,
      duracionMinutos: dto.duracionMinutos ?? null,
      cantidadLitros: dto.cantidadLitros ?? null,
      fecha: new Date(dto.fecha),
      humedad: dto.humedad ?? null,
      observaciones: dto.observaciones ?? null,
      userId,
    });

    const saved = await this.riegoRepo.repo.save(entity);
    return this.findOne(saved.id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // FIND ALL
  // ════════════════════════════════════════════════════════

  async findAll(
    query: ListRiegoQueryDto,
    userId: string,
    userRole: string,
  ): Promise<{
    data: RiegoResponseDto[];
    total: number;
    page: number;
    limit: number;
  }> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const qb = this.riegoRepo.repo
      .createQueryBuilder('riego')
      .leftJoinAndSelect('riego.lote', 'lote')
      .orderBy('riego.fecha', 'DESC')
      .skip(skip)
      .take(limit);

    if (userRole !== UserRole.ADMINISTRADOR) {
      qb.andWhere('riego.userId = :userId', { userId });
    }

    if (query.loteId) {
      qb.andWhere('riego.loteId = :loteId', { loteId: query.loteId });
    }

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items.map(RiegoResponseDto.fromEntity),
      total,
      page,
      limit,
    };
  }

  // ════════════════════════════════════════════════════════
  // FIND ONE
  // ════════════════════════════════════════════════════════

  async findOne(id: string, userId: string, userRole: string): Promise<RiegoResponseDto> {
    const riego = await this.riegoRepo.repo.findOne({
      where: { id },
      relations: ['lote'],
    });

    if (!riego) {
      throw new NotFoundException(`Riego ${id} no encontrado`);
    }

    if (userRole !== UserRole.ADMINISTRADOR && riego.userId !== userId) {
      throw new ForbiddenException('No tienes acceso a este riego');
    }

    return RiegoResponseDto.fromEntity(riego);
  }

  // ════════════════════════════════════════════════════════
  // UPDATE
  // ════════════════════════════════════════════════════════

  async update(
    id: string,
    dto: UpdateRiegoDto,
    userId: string,
    userRole: string,
  ): Promise<RiegoResponseDto> {
    const riego = await this.riegoRepo.repo.findOne({ where: { id } });
    if (!riego) {
      throw new NotFoundException(`Riego ${id} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && riego.userId !== userId) {
      throw new ForbiddenException('No puedes modificar este riego');
    }

    Object.assign(riego, {
      ...(dto.tipo !== undefined && { tipo: dto.tipo }),
      ...(dto.duracionMinutos !== undefined && {
        duracionMinutos: dto.duracionMinutos ?? null,
      }),
      ...(dto.cantidadLitros !== undefined && {
        cantidadLitros: dto.cantidadLitros ?? null,
      }),
      ...(dto.fecha !== undefined && { fecha: new Date(dto.fecha) }),
      ...(dto.humedad !== undefined && { humedad: dto.humedad ?? null }),
      ...(dto.observaciones !== undefined && {
        observaciones: dto.observaciones ?? null,
      }),
    });

    await this.riegoRepo.repo.save(riego);
    return this.findOne(id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // DELETE (soft)
  // ════════════════════════════════════════════════════════

  async remove(id: string, userId: string, userRole: string): Promise<void> {
    const riego = await this.riegoRepo.repo.findOne({ where: { id } });
    if (!riego) {
      throw new NotFoundException(`Riego ${id} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && riego.userId !== userId) {
      throw new ForbiddenException('No puedes eliminar este riego');
    }
    await this.riegoRepo.repo.softDelete(id);
  }

  // ════════════════════════════════════════════════════════
  // UTILIDADES PRIVADAS
  // ════════════════════════════════════════════════════════

  private async assertLoteOwnership(
    loteId: string,
    userId: string,
    userRole: string,
  ): Promise<void> {
    const lote = await this.lotesRepo.findOne({ where: { id: loteId } });
    if (!lote) {
      throw new NotFoundException(`Lote ${loteId} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && lote.propietarioId !== userId) {
      throw new ForbiddenException('El lote no te pertenece');
    }
  }
}
