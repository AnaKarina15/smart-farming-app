import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { UserRole } from '../users/entities/user-role.enum';
import { EstadoTerreno } from '../estado-terreno/entities/estado-terreno.entity';
import { Cultivo } from '../catalogos/entities/cultivo.entity';

import { CreateSiembraDto } from './dto/create-siembra.dto';
import { ListSiembrasQueryDto } from './dto/list-siembras-query.dto';
import { SiembraResponseDto } from './dto/siembra-response.dto';
import { UpdateSiembraDto } from './dto/update-siembra.dto';
import { Siembra } from './entities/siembra.entity';
import { SiembrasRepository } from './siembras.repository';

@Injectable()
export class SiembrasService {
  constructor(
    private readonly siembrasRepo: SiembrasRepository,
    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,
    @InjectRepository(EstadoTerreno)
    private readonly estadoTerrenoRepo: Repository<EstadoTerreno>,
    @InjectRepository(Cultivo)
    private readonly cultivosRepo: Repository<Cultivo>,
  ) {}

  // ════════════════════════════════════════════════════════
  // CREATE
  // ════════════════════════════════════════════════════════

  async create(
    dto: CreateSiembraDto,
    userId: string,
    userRole: string,
  ): Promise<SiembraResponseDto> {
    // Validacion: cultivoId O cultivoOtro (no ambos null)
    if (!dto.cultivoId && !dto.cultivoOtro) {
      throw new BadRequestException(
        'Debe especificar cultivoId del catalogo o cultivoOtro como texto libre',
      );
    }

    // Validacion: el lote debe existir y pertenecer al usuario (o ser admin)
    await this.assertLoteOwnership(dto.loteId, userId, userRole);

    const entity = this.siembrasRepo.repo.create({
      loteId: dto.loteId,
      cultivoId: dto.cultivoId ?? null,
      cultivoOtro: dto.cultivoOtro ?? null,
      variedad: dto.variedad ?? null,
      fecha: new Date(dto.fecha),
      cantidadSemillas: dto.cantidadSemillas ?? null,
      unidad: dto.unidad ?? null,
      distanciaEntreFilas: dto.distanciaEntreFilas ?? null,
      distanciaEntrePlantas: dto.distanciaEntrePlantas ?? null,
      observaciones: dto.observaciones ?? null,
      userId,
    });

    const saved = await this.siembrasRepo.repo.save(entity);

    try {
      const lote = await this.lotesRepo.findOne({ where: { id: dto.loteId } });
      if (lote) {
        if (dto.cultivoId) {
          const cultivo = await this.cultivosRepo.findOne({ where: { id: dto.cultivoId } });
          lote.cultivoActualId = dto.cultivoId;
          lote.cultivoActual = cultivo ? cultivo.nombre : null;
        } else {
          lote.cultivoActualId = null;
          lote.cultivoActual = dto.cultivoOtro ?? null;
        }
        await this.lotesRepo.save(lote);
      }
    } catch (e) {
      console.error('Error al actualizar el cultivo actual del lote:', e);
    }

    return this.findOne(saved.id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // FIND ALL (paginado, filtrado)
  // ════════════════════════════════════════════════════════

  async findAll(
    query: ListSiembrasQueryDto,
    userId: string,
    userRole: string,
  ): Promise<{
    data: SiembraResponseDto[];
    total: number;
    page: number;
    limit: number;
  }> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const qb = this.siembrasRepo.repo
      .createQueryBuilder('siembra')
      .leftJoinAndSelect('siembra.lote', 'lote')
      .leftJoinAndSelect('siembra.cultivo', 'cultivo')
      .orderBy('siembra.fecha', 'DESC')
      .skip(skip)
      .take(limit);

    // El no-admin solo ve sus siembras
    if (userRole !== UserRole.ADMINISTRADOR) {
      qb.andWhere('siembra.userId = :userId', { userId });
    }

    if (query.loteId) {
      qb.andWhere('siembra.loteId = :loteId', { loteId: query.loteId });
    }

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items.map(SiembraResponseDto.fromEntity),
      total,
      page,
      limit,
    };
  }

  // ════════════════════════════════════════════════════════
  // FIND ONE
  // ════════════════════════════════════════════════════════

  async findOne(id: string, userId: string, userRole: string): Promise<SiembraResponseDto> {
    const siembra = await this.siembrasRepo.repo.findOne({
      where: { id },
      relations: ['lote', 'cultivo'],
    });

    if (!siembra) {
      throw new NotFoundException(`Siembra ${id} no encontrada`);
    }

    if (userRole !== UserRole.ADMINISTRADOR && siembra.userId !== userId) {
      throw new ForbiddenException('No tienes acceso a esta siembra');
    }

    return SiembraResponseDto.fromEntity(siembra);
  }

  // ════════════════════════════════════════════════════════
  // UPDATE
  // ════════════════════════════════════════════════════════

  async update(
    id: string,
    dto: UpdateSiembraDto,
    userId: string,
    userRole: string,
  ): Promise<SiembraResponseDto> {
    const siembra = await this.siembrasRepo.repo.findOne({ where: { id } });
    if (!siembra) {
      throw new NotFoundException(`Siembra ${id} no encontrada`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && siembra.userId !== userId) {
      throw new ForbiddenException('No puedes modificar esta siembra');
    }

    // Validacion: si quedan cultivoId Y cultivoOtro vacios, falla
    const nuevoCultivoId = dto.cultivoId !== undefined ? dto.cultivoId : siembra.cultivoId;
    const nuevoCultivoOtro = dto.cultivoOtro !== undefined ? dto.cultivoOtro : siembra.cultivoOtro;
    if (!nuevoCultivoId && !nuevoCultivoOtro) {
      throw new BadRequestException(
        'Debe quedar cultivoId del catalogo o cultivoOtro como texto libre',
      );
    }

    Object.assign(siembra, {
      ...(dto.cultivoId !== undefined && { cultivoId: dto.cultivoId ?? null }),
      ...(dto.cultivoOtro !== undefined && {
        cultivoOtro: dto.cultivoOtro ?? null,
      }),
      ...(dto.variedad !== undefined && { variedad: dto.variedad ?? null }),
      ...(dto.fecha !== undefined && { fecha: new Date(dto.fecha) }),
      ...(dto.cantidadSemillas !== undefined && {
        cantidadSemillas: dto.cantidadSemillas ?? null,
      }),
      ...(dto.unidad !== undefined && { unidad: dto.unidad ?? null }),
      ...(dto.distanciaEntreFilas !== undefined && {
        distanciaEntreFilas: dto.distanciaEntreFilas ?? null,
      }),
      ...(dto.distanciaEntrePlantas !== undefined && {
        distanciaEntrePlantas: dto.distanciaEntrePlantas ?? null,
      }),
      ...(dto.observaciones !== undefined && {
        observaciones: dto.observaciones ?? null,
      }),
    });

    await this.siembrasRepo.repo.save(siembra);

    try {
      const lote = await this.lotesRepo.findOne({ where: { id: siembra.loteId } });
      if (lote) {
        if (siembra.cultivoId) {
          const cultivo = await this.cultivosRepo.findOne({ where: { id: siembra.cultivoId } });
          lote.cultivoActualId = siembra.cultivoId;
          lote.cultivoActual = cultivo ? cultivo.nombre : null;
        } else {
          lote.cultivoActualId = null;
          lote.cultivoActual = siembra.cultivoOtro ?? null;
        }
        await this.lotesRepo.save(lote);
      }
    } catch (e) {
      console.error('Error al actualizar el cultivo actual del lote en update:', e);
    }

    return this.findOne(id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // DELETE (soft)
  // ════════════════════════════════════════════════════════

  async remove(id: string, userId: string, userRole: string): Promise<void> {
    const siembra = await this.siembrasRepo.repo.findOne({ where: { id } });
    if (!siembra) {
      throw new NotFoundException(`Siembra ${id} no encontrada`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && siembra.userId !== userId) {
      throw new ForbiddenException('No puedes eliminar esta siembra');
    }

    try {
      await this.estadoTerrenoRepo.softDelete({ siembraId: id });
    } catch (e) {
      console.error('Error soft-deleting estado terreno:', e);
    }

    try {
      const lote = await this.lotesRepo.findOne({ where: { id: siembra.loteId } });
      if (lote) {
        lote.cultivoActualId = null;
        lote.cultivoActual = null;
        await this.lotesRepo.save(lote);
      }
    } catch (e) {
      console.error('Error al limpiar el cultivo actual del lote en remove:', e);
    }

    await this.siembrasRepo.repo.softDelete(id);
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
