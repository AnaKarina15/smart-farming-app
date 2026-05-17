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

import { CreateHallazgoDto } from './dto/create-hallazgo.dto';
import { HallazgoResponseDto } from './dto/hallazgo-response.dto';
import { ListHallazgosQueryDto } from './dto/list-hallazgos-query.dto';
import { UpdateHallazgoDto } from './dto/update-hallazgo.dto';
import { HallazgosRepository } from './hallazgos.repository';

@Injectable()
export class HallazgosService {
  constructor(
    private readonly hallazgosRepo: HallazgosRepository,
    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,
  ) {}

  // ════════════════════════════════════════════════════════
  // CREATE
  // ════════════════════════════════════════════════════════

  async create(
    dto: CreateHallazgoDto,
    userId: string,
    userRole: string,
  ): Promise<HallazgoResponseDto> {
    if (!dto.plagaId && !dto.plagaOtro) {
      throw new BadRequestException(
        'Debe especificar plagaId del catalogo o plagaOtro como texto libre',
      );
    }

    await this.assertLoteOwnership(dto.loteId, userId, userRole);

    const entity = this.hallazgosRepo.repo.create({
      loteId: dto.loteId,
      plagaId: dto.plagaId ?? null,
      plagaOtro: dto.plagaOtro ?? null,
      severidad: dto.severidad,
      descripcion: dto.descripcion ?? null,
      fotoPath: dto.fotoPath ?? null,
      fecha: new Date(dto.fecha),
      userId,
    });

    const saved = await this.hallazgosRepo.repo.save(entity);
    return this.findOne(saved.id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // FIND ALL
  // ════════════════════════════════════════════════════════

  async findAll(
    query: ListHallazgosQueryDto,
    userId: string,
    userRole: string,
  ): Promise<{
    data: HallazgoResponseDto[];
    total: number;
    page: number;
    limit: number;
  }> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const qb = this.hallazgosRepo.repo
      .createQueryBuilder('hallazgo')
      .leftJoinAndSelect('hallazgo.lote', 'lote')
      .leftJoinAndSelect('hallazgo.plaga', 'plaga')
      .orderBy('hallazgo.fecha', 'DESC')
      .skip(skip)
      .take(limit);

    if (userRole !== UserRole.ADMINISTRADOR) {
      qb.andWhere('hallazgo.userId = :userId', { userId });
    }

    if (query.loteId) {
      qb.andWhere('hallazgo.loteId = :loteId', { loteId: query.loteId });
    }

    if (query.severidad) {
      qb.andWhere('hallazgo.severidad = :severidad', {
        severidad: query.severidad,
      });
    }

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items.map(HallazgoResponseDto.fromEntity),
      total,
      page,
      limit,
    };
  }

  // ════════════════════════════════════════════════════════
  // FIND ONE
  // ════════════════════════════════════════════════════════

  async findOne(id: string, userId: string, userRole: string): Promise<HallazgoResponseDto> {
    const hallazgo = await this.hallazgosRepo.repo.findOne({
      where: { id },
      relations: ['lote', 'plaga'],
    });

    if (!hallazgo) {
      throw new NotFoundException(`Hallazgo ${id} no encontrado`);
    }

    if (userRole !== UserRole.ADMINISTRADOR && hallazgo.userId !== userId) {
      throw new ForbiddenException('No tienes acceso a este hallazgo');
    }

    return HallazgoResponseDto.fromEntity(hallazgo);
  }

  // ════════════════════════════════════════════════════════
  // UPDATE
  // ════════════════════════════════════════════════════════

  async update(
    id: string,
    dto: UpdateHallazgoDto,
    userId: string,
    userRole: string,
  ): Promise<HallazgoResponseDto> {
    const hallazgo = await this.hallazgosRepo.repo.findOne({ where: { id } });
    if (!hallazgo) {
      throw new NotFoundException(`Hallazgo ${id} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && hallazgo.userId !== userId) {
      throw new ForbiddenException('No puedes modificar este hallazgo');
    }

    const nuevoPlagaId = dto.plagaId !== undefined ? dto.plagaId : hallazgo.plagaId;
    const nuevoPlagaOtro = dto.plagaOtro !== undefined ? dto.plagaOtro : hallazgo.plagaOtro;
    if (!nuevoPlagaId && !nuevoPlagaOtro) {
      throw new BadRequestException(
        'Debe quedar plagaId del catalogo o plagaOtro como texto libre',
      );
    }

    Object.assign(hallazgo, {
      ...(dto.plagaId !== undefined && { plagaId: dto.plagaId ?? null }),
      ...(dto.plagaOtro !== undefined && { plagaOtro: dto.plagaOtro ?? null }),
      ...(dto.severidad !== undefined && { severidad: dto.severidad }),
      ...(dto.descripcion !== undefined && {
        descripcion: dto.descripcion ?? null,
      }),
      ...(dto.fotoPath !== undefined && { fotoPath: dto.fotoPath ?? null }),
      ...(dto.fecha !== undefined && { fecha: new Date(dto.fecha) }),
    });

    await this.hallazgosRepo.repo.save(hallazgo);
    return this.findOne(id, userId, userRole);
  }

  // ════════════════════════════════════════════════════════
  // DELETE (soft)
  // ════════════════════════════════════════════════════════

  async remove(id: string, userId: string, userRole: string): Promise<void> {
    const hallazgo = await this.hallazgosRepo.repo.findOne({ where: { id } });
    if (!hallazgo) {
      throw new NotFoundException(`Hallazgo ${id} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && hallazgo.userId !== userId) {
      throw new ForbiddenException('No puedes eliminar este hallazgo');
    }
    await this.hallazgosRepo.repo.softDelete(id);
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
