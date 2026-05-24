import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { UserRole } from '@/modules/users/entities/user-role.enum';

import { CreateLoteDto } from './dto/create-lote.dto';
import { LoteResponseDto } from './dto/lote-response.dto';
import { UpdateLoteDto } from './dto/update-lote.dto';
import { Lote } from './entities/lote.entity';
import { LotesRepository } from './lotes.repository';

const SUPERFICIE_MAXIMA_TOTAL = 5;

@Injectable()
export class LotesService {
  constructor(private readonly lotesRepo: LotesRepository) {}

  async create(propietarioId: string, dto: CreateLoteDto): Promise<LoteResponseDto> {
    const lote = await this.lotesRepo.create({ ...dto, propietarioId });
    return LoteResponseDto.fromEntity(lote);
  }

  /**
   * Lista TODOS los lotes del sistema (solo admin debe llamar esto).
   */
  async findAll(): Promise<LoteResponseDto[]> {
    const lotes = await this.lotesRepo.findAll();
    return lotes.map((lote) => LoteResponseDto.fromEntity(lote));
  }

  async findAllByPropietario(propietarioId: string): Promise<LoteResponseDto[]> {
    const lotes = await this.lotesRepo.findByPropietario(propietarioId);
    return lotes.map((lote) => LoteResponseDto.fromEntity(lote));
  }

  async findOne(id: string, propietarioId: string): Promise<LoteResponseDto> {
    const lote = await this.assertOwnership(id, propietarioId);
    return LoteResponseDto.fromEntity(lote);
  }

  /**
   * Admin puede ver cualquier lote sin restriccion de propiedad.
   */
  async findOneAdmin(id: string): Promise<LoteResponseDto> {
    const lote = await this.lotesRepo.findById(id);
    if (!lote) {
      throw new NotFoundException(`Lote con id ${id} no encontrado`);
    }
    return LoteResponseDto.fromEntity(lote);
  }

  async update(
    id: string,
    userId: string,
    dto: UpdateLoteDto,
    userRole: UserRole,
  ): Promise<LoteResponseDto> {
    // Admin bypasea verificacion de ownership
    if (userRole === UserRole.ADMINISTRADOR) {
      const lote = await this.lotesRepo.findById(id);
      if (!lote) {
        throw new NotFoundException(`Lote con id ${id} no encontrado`);
      }
    } else {
      await this.assertOwnership(id, userId);
    }

    await this.lotesRepo.update(id, dto);
    const updated = await this.lotesRepo.findById(id);
    return LoteResponseDto.fromEntity(updated!);
  }

  async remove(id: string, userId: string, userRole: UserRole): Promise<void> {
    // Admin bypasea verificacion de ownership
    if (userRole !== UserRole.ADMINISTRADOR) {
      await this.assertOwnership(id, userId);
    } else {
      const lote = await this.lotesRepo.findById(id);
      if (!lote) {
        throw new NotFoundException(`Lote con id ${id} no encontrado`);
      }
    }
    await this.lotesRepo.delete(id);
  }

  /**
   * Estadisticas globales de lotes (admin).
   */
  async getStats(): Promise<{
    totalLotes: number;
    superficieTotalHectareas: number;
    promedioPorProductor: number;
  }> {
    const lotes = await this.lotesRepo.findAll();
    const totalLotes = lotes.length;
    const superficieTotalHectareas = lotes.reduce(
      (sum, l) => sum + Number(l.superficieHectareas),
      0,
    );
    const propietariosUnicos = new Set(lotes.map((l) => l.propietarioId)).size;
    const promedioPorProductor = propietariosUnicos > 0 ? totalLotes / propietariosUnicos : 0;

    return {
      totalLotes,
      superficieTotalHectareas: Math.round(superficieTotalHectareas * 100) / 100,
      promedioPorProductor: Math.round(promedioPorProductor * 100) / 100,
    };
  }

  private async assertOwnership(id: string, propietarioId: string): Promise<Lote> {
    const lote = await this.lotesRepo.findById(id);
    if (!lote) {
      throw new NotFoundException(`Lote con id ${id} no encontrado`);
    }
    if (lote.propietarioId !== propietarioId) {
      throw new ForbiddenException('No tienes permiso para acceder a este lote');
    }
    return lote;
  }
}
