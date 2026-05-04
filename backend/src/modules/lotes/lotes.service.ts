import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { CreateLoteDto } from './dto/create-lote.dto';
import { LoteResponseDto } from './dto/lote-response.dto';
import { UpdateLoteDto } from './dto/update-lote.dto';
import { Lote } from './entities/lote.entity';
import { LotesRepository } from './lotes.repository';

const SUPERFICIE_MAXIMA_TOTAL = 5;

@Injectable()
export class LotesService {
  constructor(private readonly lotesRepo: LotesRepository) {}

  /**
   * Crea un lote. Valida que la superficie total del productor no exceda 5 hectareas
   * (restriccion de negocio definida en Fase 1).
   */
  async create(propietarioId: string, dto: CreateLoteDto): Promise<LoteResponseDto> {
    const totalActual = await this.lotesRepo.sumSuperficieByPropietario(propietarioId);
    if (totalActual + dto.superficieHectareas > SUPERFICIE_MAXIMA_TOTAL) {
      throw new BadRequestException(
        `La superficie total no puede exceder ${SUPERFICIE_MAXIMA_TOTAL} hectareas. ` +
          `Actual: ${totalActual}, intentando agregar: ${dto.superficieHectareas}`,
      );
    }

    const lote = await this.lotesRepo.create({ ...dto, propietarioId });
    return LoteResponseDto.fromEntity(lote);
  }

  async findAllByPropietario(propietarioId: string): Promise<LoteResponseDto[]> {
    const lotes = await this.lotesRepo.findByPropietario(propietarioId);
    return lotes.map((lote) => LoteResponseDto.fromEntity(lote));
  }

  async findOne(id: string, propietarioId: string): Promise<LoteResponseDto> {
    const lote = await this.assertOwnership(id, propietarioId);
    return LoteResponseDto.fromEntity(lote);
  }

  async update(
    id: string,
    propietarioId: string,
    dto: UpdateLoteDto,
  ): Promise<LoteResponseDto> {
    await this.assertOwnership(id, propietarioId);

    if (dto.superficieHectareas !== undefined) {
      const totalActual = await this.lotesRepo.sumSuperficieByPropietario(propietarioId, id);
      if (totalActual + dto.superficieHectareas > SUPERFICIE_MAXIMA_TOTAL) {
        throw new BadRequestException(
          `La superficie total no puede exceder ${SUPERFICIE_MAXIMA_TOTAL} hectareas`,
        );
      }
    }

    await this.lotesRepo.update(id, dto);
    const updated = await this.lotesRepo.findById(id);
    return LoteResponseDto.fromEntity(updated!);
  }

  async remove(id: string, propietarioId: string): Promise<void> {
    await this.assertOwnership(id, propietarioId);
    await this.lotesRepo.delete(id);
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
