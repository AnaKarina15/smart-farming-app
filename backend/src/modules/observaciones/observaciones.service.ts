import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { UserRole } from '../users/entities/user-role.enum';

import { CreateObservacionDto } from './dto/create-observacion.dto';
import { ListObservacionesQueryDto } from './dto/list-observaciones-query.dto';
import { ObservacionResponseDto } from './dto/observacion-response.dto';
import { UpdateObservacionDto } from './dto/update-observacion.dto';
import { ObservacionesRepository } from './observaciones.repository';

@Injectable()
export class ObservacionesService {
  constructor(
    private readonly observacionesRepo: ObservacionesRepository,
    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,
  ) {}

  // ════════════════════════════════════════════════════════
  // CREATE
  // ════════════════════════════════════════════════════════

  async create(
    dto: CreateObservacionDto,
    userId: string,
    userRole: string,
  ): Promise<ObservacionResponseDto> {
    await this.assertLoteOwnership(dto.loteId, userId, userRole);

    const entity = this.observacionesRepo.repo.create({
      loteId: dto.loteId,
      descripcion: dto.descripcion,
      tipo: dto.tipo ?? null,
      fecha: new Date(dto.fecha),
      userId,
    });

    const saved = await this.observacionesRepo.repo.save(entity);
    return this.findOne(saved.id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // FIND ALL
  // ════════════════════════════════════════════════════════

  async findAll(
    query: ListObservacionesQueryDto,
    userId: string,
    userRole: string,
  ): Promise<{
    data: ObservacionResponseDto[];
    total: number;
    page: number;
    limit: number;
  }> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const qb = this.observacionesRepo.repo
      .createQueryBuilder('observacion')
      .leftJoinAndSelect('observacion.lote', 'lote')
      .orderBy('observacion.fecha', 'DESC')
      .skip(skip)
      .take(limit);

    if (userRole !== UserRole.ADMINISTRADOR) {
      qb.andWhere('observacion.userId = :userId', { userId });
    }

    if (query.loteId) {
      qb.andWhere('observacion.loteId = :loteId', { loteId: query.loteId });
    }

    if (query.tipo) {
      qb.andWhere('observacion.tipo = :tipo', { tipo: query.tipo });
    }

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items.map(ObservacionResponseDto.fromEntity),
      total,
      page,
      limit,
    };
  }

  // ════════════════════════════════════════════════════════
  // FIND ONE
  // ════════════════════════════════════════════════════════

  async findOne(id: string, userId: string, userRole: string): Promise<ObservacionResponseDto> {
    const obs = await this.observacionesRepo.repo.findOne({
      where: { id },
      relations: ['lote'],
    });

    if (!obs) {
      throw new NotFoundException(`Observacion ${id} no encontrada`);
    }

    if (userRole !== UserRole.ADMINISTRADOR && obs.userId !== userId) {
      throw new ForbiddenException('No tienes acceso a esta observacion');
    }

    return ObservacionResponseDto.fromEntity(obs);
  }

  // ════════════════════════════════════════════════════════
  // UPDATE
  // ════════════════════════════════════════════════════════

  async update(
    id: string,
    dto: UpdateObservacionDto,
    userId: string,
    userRole: string,
  ): Promise<ObservacionResponseDto> {
    const obs = await this.observacionesRepo.repo.findOne({ where: { id } });
    if (!obs) {
      throw new NotFoundException(`Observacion ${id} no encontrada`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && obs.userId !== userId) {
      throw new ForbiddenException('No puedes modificar esta observacion');
    }

    Object.assign(obs, {
      ...(dto.descripcion !== undefined && { descripcion: dto.descripcion }),
      ...(dto.tipo !== undefined && { tipo: dto.tipo ?? null }),
      ...(dto.fecha !== undefined && { fecha: new Date(dto.fecha) }),
    });

    await this.observacionesRepo.repo.save(obs);
    return this.findOne(id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // DELETE (soft)
  // ════════════════════════════════════════════════════════

  async remove(id: string, userId: string, userRole: string): Promise<void> {
    const obs = await this.observacionesRepo.repo.findOne({ where: { id } });
    if (!obs) {
      throw new NotFoundException(`Observacion ${id} no encontrada`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && obs.userId !== userId) {
      throw new ForbiddenException('No puedes eliminar esta observacion');
    }
    await this.observacionesRepo.repo.softDelete(id);
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
