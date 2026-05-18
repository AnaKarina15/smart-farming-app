import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { UserRole } from '../users/entities/user-role.enum';
import { Siembra } from '../siembras/entities/siembra.entity';
import { TipoSuelo } from '../catalogos/entities/tipo-suelo.entity';

import { CreateEstadoTerrenoDto } from './dto/create-estado-terreno.dto';
import { ListEstadoTerrenoQueryDto } from './dto/list-estado-terreno-query.dto';
import { EstadoTerrenoResponseDto } from './dto/estado-terreno-response.dto';
import { UpdateEstadoTerrenoDto } from './dto/update-estado-terreno.dto';
import { EstadoTerrenoRepository } from './estado-terreno.repository';

@Injectable()
export class EstadoTerrenoService {
  constructor(
    private readonly estadoTerrenoRepo: EstadoTerrenoRepository,
    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,
    @InjectRepository(Siembra)
    private readonly siembrasRepo: Repository<Siembra>,
    @InjectRepository(TipoSuelo)
    private readonly tipoSueloRepo: Repository<TipoSuelo>,
  ) {}

  // ════════════════════════════════════════════════════════
  // CREATE
  // ════════════════════════════════════════════════════════

  async create(
    dto: CreateEstadoTerrenoDto,
    userId: string,
    userRole: string,
  ): Promise<EstadoTerrenoResponseDto> {
    await this.assertLoteOwnership(dto.loteId, userId, userRole);

    if (dto.siembraId) {
      const siembra = await this.siembrasRepo.findOne({ where: { id: dto.siembraId } });
      if (!siembra) {
        throw new NotFoundException(`Siembra ${dto.siembraId} no encontrada`);
      }
    }

    if (dto.tipoSueloId) {
      const tipoSuelo = await this.tipoSueloRepo.findOne({ where: { id: dto.tipoSueloId } });
      if (!tipoSuelo) {
        throw new NotFoundException(`Tipo de suelo ${dto.tipoSueloId} no encontrado`);
      }
    }

    const entity = this.estadoTerrenoRepo.repo.create({
      loteId: dto.loteId,
      siembraId: dto.siembraId ?? null,
      estado: dto.estado,
      tipoSueloId: dto.tipoSueloId ?? null,
      notas: dto.notas ?? null,
      userId,
      ...(dto.createdAt && { createdAt: new Date(dto.createdAt) }),
    });

    const saved = await this.estadoTerrenoRepo.repo.save(entity);
    return this.findOne(saved.id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // FIND ALL
  // ════════════════════════════════════════════════════════

  async findAll(
    query: ListEstadoTerrenoQueryDto,
    userId: string,
    userRole: string,
  ): Promise<{
    data: EstadoTerrenoResponseDto[];
    total: number;
    page: number;
    limit: number;
  }> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const qb = this.estadoTerrenoRepo.repo
      .createQueryBuilder('estadoTerreno')
      .leftJoinAndSelect('estadoTerreno.lote', 'lote')
      .orderBy('estadoTerreno.createdAt', 'DESC')
      .skip(skip)
      .take(limit);

    if (userRole !== UserRole.ADMINISTRADOR) {
      qb.andWhere('estadoTerreno.userId = :userId', { userId });
    }

    if (query.loteId) {
      qb.andWhere('estadoTerreno.loteId = :loteId', { loteId: query.loteId });
    }

    if (query.siembraId) {
      qb.andWhere('estadoTerreno.siembraId = :siembraId', { siembraId: query.siembraId });
    }

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items.map(EstadoTerrenoResponseDto.fromEntity),
      total,
      page,
      limit,
    };
  }

  // ════════════════════════════════════════════════════════
  // FIND ONE
  // ════════════════════════════════════════════════════════

  async findOne(id: string, userId: string, userRole: string): Promise<EstadoTerrenoResponseDto> {
    const item = await this.estadoTerrenoRepo.repo.findOne({
      where: { id },
      relations: ['lote'],
    });

    if (!item) {
      throw new NotFoundException(`Registro de estado de terreno ${id} no encontrado`);
    }

    if (userRole !== UserRole.ADMINISTRADOR && item.userId !== userId) {
      throw new ForbiddenException('No tienes acceso a este registro');
    }

    return EstadoTerrenoResponseDto.fromEntity(item);
  }

  // ════════════════════════════════════════════════════════
  // UPDATE
  // ════════════════════════════════════════════════════════

  async update(
    id: string,
    dto: UpdateEstadoTerrenoDto,
    userId: string,
    userRole: string,
  ): Promise<EstadoTerrenoResponseDto> {
    const item = await this.estadoTerrenoRepo.repo.findOne({ where: { id } });
    if (!item) {
      throw new NotFoundException(`Registro de estado de terreno ${id} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && item.userId !== userId) {
      throw new ForbiddenException('No puedes modificar este registro');
    }

    if (dto.siembraId !== undefined) {
      if (dto.siembraId) {
        const siembra = await this.siembrasRepo.findOne({ where: { id: dto.siembraId } });
        if (!siembra) {
          throw new NotFoundException(`Siembra ${dto.siembraId} no encontrada`);
        }
      }
      item.siembraId = dto.siembraId;
    }

    if (dto.tipoSueloId !== undefined) {
      if (dto.tipoSueloId) {
        const tipoSuelo = await this.tipoSueloRepo.findOne({ where: { id: dto.tipoSueloId } });
        if (!tipoSuelo) {
          throw new NotFoundException(`Tipo de suelo ${dto.tipoSueloId} no encontrado`);
        }
      }
      item.tipoSueloId = dto.tipoSueloId;
    }

    Object.assign(item, {
      ...(dto.estado !== undefined && { estado: dto.estado }),
      ...(dto.notas !== undefined && { notas: dto.notas }),
    });

    await this.estadoTerrenoRepo.repo.save(item);
    return this.findOne(id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // DELETE (soft)
  // ════════════════════════════════════════════════════════

  async remove(id: string, userId: string, userRole: string): Promise<void> {
    const item = await this.estadoTerrenoRepo.repo.findOne({ where: { id } });
    if (!item) {
      throw new NotFoundException(`Registro de estado de terreno ${id} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && item.userId !== userId) {
      throw new ForbiddenException('No puedes eliminar este registro');
    }
    await this.estadoTerrenoRepo.repo.softDelete(id);
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
