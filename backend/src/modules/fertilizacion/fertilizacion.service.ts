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

import { CreateFertilizacionDto } from './dto/create-fertilizacion.dto';
import { FertilizacionResponseDto } from './dto/fertilizacion-response.dto';
import { ListFertilizacionQueryDto } from './dto/list-fertilizacion-query.dto';
import { UpdateFertilizacionDto } from './dto/update-fertilizacion.dto';
import { FertilizacionRepository } from './fertilizacion.repository';

@Injectable()
export class FertilizacionService {
  constructor(
    private readonly fertilizacionRepo: FertilizacionRepository,
    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,
  ) {}

  // ════════════════════════════════════════════════════════
  // CREATE
  // ════════════════════════════════════════════════════════

  async create(
    dto: CreateFertilizacionDto,
    userId: string,
    userRole: string,
  ): Promise<FertilizacionResponseDto> {
    if (!dto.fertilizanteId && !dto.fertilizanteOtro) {
      throw new BadRequestException(
        'Debe especificar fertilizanteId del catalogo o fertilizanteOtro como texto libre',
      );
    }

    await this.assertLoteOwnership(dto.loteId, userId, userRole);

    const entity = this.fertilizacionRepo.repo.create({
      loteId: dto.loteId,
      fertilizanteId: dto.fertilizanteId ?? null,
      fertilizanteOtro: dto.fertilizanteOtro ?? null,
      dosis: dto.dosis ?? null,
      unidad: dto.unidad ?? null,
      metodoAplicacion: dto.metodoAplicacion ?? null,
      fecha: new Date(dto.fecha),
      observaciones: dto.observaciones ?? null,
      userId,
    });

    const saved = await this.fertilizacionRepo.repo.save(entity);
    return this.findOne(saved.id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // FIND ALL
  // ════════════════════════════════════════════════════════

  async findAll(
    query: ListFertilizacionQueryDto,
    userId: string,
    userRole: string,
  ): Promise<{
    data: FertilizacionResponseDto[];
    total: number;
    page: number;
    limit: number;
  }> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const qb = this.fertilizacionRepo.repo
      .createQueryBuilder('fertilizacion')
      .leftJoinAndSelect('fertilizacion.lote', 'lote')
      .leftJoinAndSelect('fertilizacion.fertilizante', 'fertilizante')
      .orderBy('fertilizacion.fecha', 'DESC')
      .skip(skip)
      .take(limit);

    if (userRole !== UserRole.ADMINISTRADOR) {
      qb.andWhere('fertilizacion.userId = :userId', { userId });
    }

    if (query.loteId) {
      qb.andWhere('fertilizacion.loteId = :loteId', { loteId: query.loteId });
    }

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items.map(FertilizacionResponseDto.fromEntity),
      total,
      page,
      limit,
    };
  }

  // ════════════════════════════════════════════════════════
  // FIND ONE
  // ════════════════════════════════════════════════════════

  async findOne(id: string, userId: string, userRole: string): Promise<FertilizacionResponseDto> {
    const fert = await this.fertilizacionRepo.repo.findOne({
      where: { id },
      relations: ['lote', 'fertilizante'],
    });

    if (!fert) {
      throw new NotFoundException(`Fertilizacion ${id} no encontrada`);
    }

    if (userRole !== UserRole.ADMINISTRADOR && fert.userId !== userId) {
      throw new ForbiddenException('No tienes acceso a esta fertilizacion');
    }

    return FertilizacionResponseDto.fromEntity(fert);
  }

  // ════════════════════════════════════════════════════════
  // UPDATE
  // ════════════════════════════════════════════════════════

  async update(
    id: string,
    dto: UpdateFertilizacionDto,
    userId: string,
    userRole: string,
  ): Promise<FertilizacionResponseDto> {
    const fert = await this.fertilizacionRepo.repo.findOne({ where: { id } });
    if (!fert) {
      throw new NotFoundException(`Fertilizacion ${id} no encontrada`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && fert.userId !== userId) {
      throw new ForbiddenException('No puedes modificar esta fertilizacion');
    }

    const nuevoFertilizanteId =
      dto.fertilizanteId !== undefined ? dto.fertilizanteId : fert.fertilizanteId;
    const nuevoFertilizanteOtro =
      dto.fertilizanteOtro !== undefined ? dto.fertilizanteOtro : fert.fertilizanteOtro;
    if (!nuevoFertilizanteId && !nuevoFertilizanteOtro) {
      throw new BadRequestException(
        'Debe quedar fertilizanteId del catalogo o fertilizanteOtro como texto libre',
      );
    }

    Object.assign(fert, {
      ...(dto.fertilizanteId !== undefined && {
        fertilizanteId: dto.fertilizanteId ?? null,
      }),
      ...(dto.fertilizanteOtro !== undefined && {
        fertilizanteOtro: dto.fertilizanteOtro ?? null,
      }),
      ...(dto.dosis !== undefined && { dosis: dto.dosis ?? null }),
      ...(dto.unidad !== undefined && { unidad: dto.unidad ?? null }),
      ...(dto.metodoAplicacion !== undefined && {
        metodoAplicacion: dto.metodoAplicacion ?? null,
      }),
      ...(dto.fecha !== undefined && { fecha: new Date(dto.fecha) }),
      ...(dto.observaciones !== undefined && {
        observaciones: dto.observaciones ?? null,
      }),
    });

    await this.fertilizacionRepo.repo.save(fert);
    return this.findOne(id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // DELETE (soft)
  // ════════════════════════════════════════════════════════

  async remove(id: string, userId: string, userRole: string): Promise<void> {
    const fert = await this.fertilizacionRepo.repo.findOne({ where: { id } });
    if (!fert) {
      throw new NotFoundException(`Fertilizacion ${id} no encontrada`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && fert.userId !== userId) {
      throw new ForbiddenException('No puedes eliminar esta fertilizacion');
    }
    await this.fertilizacionRepo.repo.softDelete(id);
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
