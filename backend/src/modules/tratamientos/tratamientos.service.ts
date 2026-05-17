import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Hallazgo } from '../hallazgos/entities/hallazgo.entity';
import { Lote } from '../lotes/entities/lote.entity';
import { UserRole } from '../users/entities/user-role.enum';

import { CreateTratamientoDto } from './dto/create-tratamiento.dto';
import { ListTratamientosQueryDto } from './dto/list-tratamientos-query.dto';
import { TratamientoResponseDto } from './dto/tratamiento-response.dto';
import { UpdateTratamientoDto } from './dto/update-tratamiento.dto';
import { TratamientosRepository } from './tratamientos.repository';

@Injectable()
export class TratamientosService {
  constructor(
    private readonly tratamientosRepo: TratamientosRepository,
    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,
    @InjectRepository(Hallazgo)
    private readonly hallazgosRepo: Repository<Hallazgo>,
  ) {}

  // ════════════════════════════════════════════════════════
  // CREATE
  // ════════════════════════════════════════════════════════

  async create(
    dto: CreateTratamientoDto,
    userId: string,
    userRole: string,
  ): Promise<TratamientoResponseDto> {
    await this.assertLoteOwnership(dto.loteId, userId, userRole);

    // Validacion: si se asocia un hallazgo, debe pertenecer al mismo lote
    if (dto.hallazgoId) {
      const hallazgo = await this.hallazgosRepo.findOne({
        where: { id: dto.hallazgoId },
      });
      if (!hallazgo) {
        throw new NotFoundException(`Hallazgo ${dto.hallazgoId} no encontrado`);
      }
      if (hallazgo.loteId !== dto.loteId) {
        throw new BadRequestException('El hallazgo asociado no pertenece al lote indicado');
      }
    }

    const entity = this.tratamientosRepo.repo.create({
      loteId: dto.loteId,
      hallazgoId: dto.hallazgoId ?? null,
      producto: dto.producto,
      dosis: dto.dosis ?? null,
      unidad: dto.unidad ?? null,
      metodoAplicacion: dto.metodoAplicacion ?? null,
      fecha: new Date(dto.fecha),
      observaciones: dto.observaciones ?? null,
      userId,
    });

    const saved = await this.tratamientosRepo.repo.save(entity);
    return this.findOne(saved.id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // FIND ALL
  // ════════════════════════════════════════════════════════

  async findAll(
    query: ListTratamientosQueryDto,
    userId: string,
    userRole: string,
  ): Promise<{
    data: TratamientoResponseDto[];
    total: number;
    page: number;
    limit: number;
  }> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const qb = this.tratamientosRepo.repo
      .createQueryBuilder('tratamiento')
      .leftJoinAndSelect('tratamiento.lote', 'lote')
      .leftJoinAndSelect('tratamiento.hallazgo', 'hallazgo')
      .orderBy('tratamiento.fecha', 'DESC')
      .skip(skip)
      .take(limit);

    if (userRole !== UserRole.ADMINISTRADOR) {
      qb.andWhere('tratamiento.userId = :userId', { userId });
    }

    if (query.loteId) {
      qb.andWhere('tratamiento.loteId = :loteId', { loteId: query.loteId });
    }

    if (query.hallazgoId) {
      qb.andWhere('tratamiento.hallazgoId = :hallazgoId', {
        hallazgoId: query.hallazgoId,
      });
    }

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items.map(TratamientoResponseDto.fromEntity),
      total,
      page,
      limit,
    };
  }

  // ════════════════════════════════════════════════════════
  // FIND ONE
  // ════════════════════════════════════════════════════════

  async findOne(id: string, userId: string, userRole: string): Promise<TratamientoResponseDto> {
    const tratamiento = await this.tratamientosRepo.repo.findOne({
      where: { id },
      relations: ['lote', 'hallazgo'],
    });

    if (!tratamiento) {
      throw new NotFoundException(`Tratamiento ${id} no encontrado`);
    }

    if (userRole !== UserRole.ADMINISTRADOR && tratamiento.userId !== userId) {
      throw new ForbiddenException('No tienes acceso a este tratamiento');
    }

    return TratamientoResponseDto.fromEntity(tratamiento);
  }

  // ════════════════════════════════════════════════════════
  // UPDATE
  // ════════════════════════════════════════════════════════

  async update(
    id: string,
    dto: UpdateTratamientoDto,
    userId: string,
    userRole: string,
  ): Promise<TratamientoResponseDto> {
    const tratamiento = await this.tratamientosRepo.repo.findOne({
      where: { id },
    });
    if (!tratamiento) {
      throw new NotFoundException(`Tratamiento ${id} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && tratamiento.userId !== userId) {
      throw new ForbiddenException('No puedes modificar este tratamiento');
    }

    // Validacion: si se cambia el hallazgo, verificar que pertenezca al lote
    if (dto.hallazgoId !== undefined && dto.hallazgoId !== null) {
      const hallazgo = await this.hallazgosRepo.findOne({
        where: { id: dto.hallazgoId },
      });
      if (!hallazgo) {
        throw new NotFoundException(`Hallazgo ${dto.hallazgoId} no encontrado`);
      }
      if (hallazgo.loteId !== tratamiento.loteId) {
        throw new BadRequestException('El hallazgo no pertenece al mismo lote del tratamiento');
      }
    }

    Object.assign(tratamiento, {
      ...(dto.hallazgoId !== undefined && {
        hallazgoId: dto.hallazgoId ?? null,
      }),
      ...(dto.producto !== undefined && { producto: dto.producto }),
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

    await this.tratamientosRepo.repo.save(tratamiento);
    return this.findOne(id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // DELETE (soft)
  // ════════════════════════════════════════════════════════

  async remove(id: string, userId: string, userRole: string): Promise<void> {
    const tratamiento = await this.tratamientosRepo.repo.findOne({
      where: { id },
    });
    if (!tratamiento) {
      throw new NotFoundException(`Tratamiento ${id} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && tratamiento.userId !== userId) {
      throw new ForbiddenException('No puedes eliminar este tratamiento');
    }
    await this.tratamientosRepo.repo.softDelete(id);
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
