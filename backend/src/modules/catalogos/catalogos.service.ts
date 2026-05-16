import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { FindOptionsWhere, ObjectLiteral, Repository } from 'typeorm';

import { CreateCultivoDto } from './dto/create-cultivo.dto';
import { CreateFertilizanteDto } from './dto/create-fertilizante.dto';
import { CreateMunicipioDto } from './dto/create-municipio.dto';
import { CreatePlagaDto } from './dto/create-plaga.dto';
import { CreateTipoSueloDto } from './dto/create-tipo-suelo.dto';
import { CultivoResponseDto } from './dto/cultivo-response.dto';
import { FertilizanteResponseDto } from './dto/fertilizante-response.dto';
import { MunicipioResponseDto } from './dto/municipio-response.dto';
import { PlagaResponseDto } from './dto/plaga-response.dto';
import { TipoSueloResponseDto } from './dto/tipo-suelo-response.dto';
import {
  UpdateCultivoDto,
  UpdateFertilizanteDto,
  UpdateMunicipioDto,
  UpdatePlagaDto,
  UpdateTipoSueloDto,
} from './dto/update-catalogo.dto';
import { Cultivo } from './entities/cultivo.entity';
import { Fertilizante } from './entities/fertilizante.entity';
import { Municipio } from './entities/municipio.entity';
import { Plaga } from './entities/plaga.entity';
import { TipoSuelo } from './entities/tipo-suelo.entity';
import { CatalogosRepository } from './catalogos.repository';

@Injectable()
export class CatalogosService {
  constructor(private readonly repo: CatalogosRepository) {}

  // ════════════════════════════════════════════════════════
  // MUNICIPIOS
  // ════════════════════════════════════════════════════════

  async findAllMunicipios(): Promise<MunicipioResponseDto[]> {
    const items = await this.repo.municipiosRepo.find({
      order: { nombre: 'ASC' },
    });
    return items.map(MunicipioResponseDto.fromEntity);
  }

  async findMunicipioById(id: string): Promise<MunicipioResponseDto> {
    const item = await this.repo.municipiosRepo.findOne({ where: { id } });
    if (!item) {
      throw new NotFoundException(`Municipio ${id} no encontrado`);
    }
    return MunicipioResponseDto.fromEntity(item);
  }

  async createMunicipio(dto: CreateMunicipioDto): Promise<MunicipioResponseDto> {
    await this.assertUniqueness(
      this.repo.municipiosRepo,
      { codigoDane: dto.codigoDane },
      'codigoDane',
    );
    await this.assertUniqueness(this.repo.municipiosRepo, { nombre: dto.nombre }, 'nombre');

    const entity = this.repo.municipiosRepo.create(dto);
    const saved = await this.repo.municipiosRepo.save(entity);
    return MunicipioResponseDto.fromEntity(saved);
  }

  async updateMunicipio(id: string, dto: UpdateMunicipioDto): Promise<MunicipioResponseDto> {
    const entity = await this.repo.municipiosRepo.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Municipio ${id} no encontrado`);
    }
    Object.assign(entity, dto);
    const saved = await this.repo.municipiosRepo.save(entity);
    return MunicipioResponseDto.fromEntity(saved);
  }

  async deleteMunicipio(id: string): Promise<void> {
    const result = await this.repo.municipiosRepo.softDelete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Municipio ${id} no encontrado`);
    }
  }

  // ════════════════════════════════════════════════════════
  // CULTIVOS
  // ════════════════════════════════════════════════════════

  async findAllCultivos(): Promise<CultivoResponseDto[]> {
    const items = await this.repo.cultivosRepo.find({
      order: { nombre: 'ASC' },
    });
    return items.map(CultivoResponseDto.fromEntity);
  }

  async findCultivoById(id: string): Promise<CultivoResponseDto> {
    const item = await this.repo.cultivosRepo.findOne({ where: { id } });
    if (!item) {
      throw new NotFoundException(`Cultivo ${id} no encontrado`);
    }
    return CultivoResponseDto.fromEntity(item);
  }

  async createCultivo(dto: CreateCultivoDto): Promise<CultivoResponseDto> {
    await this.assertUniqueness(this.repo.cultivosRepo, { nombre: dto.nombre }, 'nombre');
    if (dto.nombreCientifico) {
      await this.assertUniqueness(
        this.repo.cultivosRepo,
        { nombreCientifico: dto.nombreCientifico },
        'nombreCientifico',
      );
    }
    const entity = this.repo.cultivosRepo.create(dto);
    const saved = await this.repo.cultivosRepo.save(entity);
    return CultivoResponseDto.fromEntity(saved);
  }

  async updateCultivo(id: string, dto: UpdateCultivoDto): Promise<CultivoResponseDto> {
    const entity = await this.repo.cultivosRepo.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Cultivo ${id} no encontrado`);
    }
    Object.assign(entity, dto);
    const saved = await this.repo.cultivosRepo.save(entity);
    return CultivoResponseDto.fromEntity(saved);
  }

  async deleteCultivo(id: string): Promise<void> {
    const result = await this.repo.cultivosRepo.softDelete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Cultivo ${id} no encontrado`);
    }
  }

  // ════════════════════════════════════════════════════════
  // PLAGAS
  // ════════════════════════════════════════════════════════

  async findAllPlagas(): Promise<PlagaResponseDto[]> {
    const items = await this.repo.plagasRepo.find({
      order: { nombre: 'ASC' },
    });
    return items.map(PlagaResponseDto.fromEntity);
  }

  async findPlagaById(id: string): Promise<PlagaResponseDto> {
    const item = await this.repo.plagasRepo.findOne({ where: { id } });
    if (!item) {
      throw new NotFoundException(`Plaga ${id} no encontrada`);
    }
    return PlagaResponseDto.fromEntity(item);
  }

  async createPlaga(dto: CreatePlagaDto): Promise<PlagaResponseDto> {
    await this.assertUniqueness(this.repo.plagasRepo, { nombre: dto.nombre }, 'nombre');
    if (dto.nombreCientifico) {
      await this.assertUniqueness(
        this.repo.plagasRepo,
        { nombreCientifico: dto.nombreCientifico },
        'nombreCientifico',
      );
    }
    const entity = this.repo.plagasRepo.create(dto);
    const saved = await this.repo.plagasRepo.save(entity);
    return PlagaResponseDto.fromEntity(saved);
  }

  async updatePlaga(id: string, dto: UpdatePlagaDto): Promise<PlagaResponseDto> {
    const entity = await this.repo.plagasRepo.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Plaga ${id} no encontrada`);
    }
    Object.assign(entity, dto);
    const saved = await this.repo.plagasRepo.save(entity);
    return PlagaResponseDto.fromEntity(saved);
  }

  async deletePlaga(id: string): Promise<void> {
    const result = await this.repo.plagasRepo.softDelete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Plaga ${id} no encontrada`);
    }
  }

  // ════════════════════════════════════════════════════════
  // FERTILIZANTES
  // ════════════════════════════════════════════════════════

  async findAllFertilizantes(): Promise<FertilizanteResponseDto[]> {
    const items = await this.repo.fertilizantesRepo.find({
      order: { nombre: 'ASC' },
    });
    return items.map(FertilizanteResponseDto.fromEntity);
  }

  async findFertilizanteById(id: string): Promise<FertilizanteResponseDto> {
    const item = await this.repo.fertilizantesRepo.findOne({ where: { id } });
    if (!item) {
      throw new NotFoundException(`Fertilizante ${id} no encontrado`);
    }
    return FertilizanteResponseDto.fromEntity(item);
  }

  async createFertilizante(dto: CreateFertilizanteDto): Promise<FertilizanteResponseDto> {
    await this.assertUniqueness(this.repo.fertilizantesRepo, { nombre: dto.nombre }, 'nombre');
    const entity = this.repo.fertilizantesRepo.create(dto);
    const saved = await this.repo.fertilizantesRepo.save(entity);
    return FertilizanteResponseDto.fromEntity(saved);
  }

  async updateFertilizante(
    id: string,
    dto: UpdateFertilizanteDto,
  ): Promise<FertilizanteResponseDto> {
    const entity = await this.repo.fertilizantesRepo.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Fertilizante ${id} no encontrado`);
    }
    Object.assign(entity, dto);
    const saved = await this.repo.fertilizantesRepo.save(entity);
    return FertilizanteResponseDto.fromEntity(saved);
  }

  async deleteFertilizante(id: string): Promise<void> {
    const result = await this.repo.fertilizantesRepo.softDelete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Fertilizante ${id} no encontrado`);
    }
  }

  // ════════════════════════════════════════════════════════
  // TIPOS DE SUELO
  // ════════════════════════════════════════════════════════

  async findAllTiposSuelo(): Promise<TipoSueloResponseDto[]> {
    const items = await this.repo.tiposSueloRepo.find({
      order: { nombre: 'ASC' },
    });
    return items.map(TipoSueloResponseDto.fromEntity);
  }

  async findTipoSueloById(id: string): Promise<TipoSueloResponseDto> {
    const item = await this.repo.tiposSueloRepo.findOne({ where: { id } });
    if (!item) {
      throw new NotFoundException(`Tipo de suelo ${id} no encontrado`);
    }
    return TipoSueloResponseDto.fromEntity(item);
  }

  async createTipoSuelo(dto: CreateTipoSueloDto): Promise<TipoSueloResponseDto> {
    await this.assertUniqueness(this.repo.tiposSueloRepo, { nombre: dto.nombre }, 'nombre');
    const entity = this.repo.tiposSueloRepo.create(dto);
    const saved = await this.repo.tiposSueloRepo.save(entity);
    return TipoSueloResponseDto.fromEntity(saved);
  }

  async updateTipoSuelo(id: string, dto: UpdateTipoSueloDto): Promise<TipoSueloResponseDto> {
    const entity = await this.repo.tiposSueloRepo.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Tipo de suelo ${id} no encontrado`);
    }
    Object.assign(entity, dto);
    const saved = await this.repo.tiposSueloRepo.save(entity);
    return TipoSueloResponseDto.fromEntity(saved);
  }

  async deleteTipoSuelo(id: string): Promise<void> {
    const result = await this.repo.tiposSueloRepo.softDelete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Tipo de suelo ${id} no encontrado`);
    }
  }

  // ════════════════════════════════════════════════════════
  // UTILIDADES PRIVADAS
  // ════════════════════════════════════════════════════════

  /**
   * Verifica unicidad generica para cualquier catalogo.
   * Lanza ConflictException si el registro ya existe.
   */
  private async assertUniqueness<T extends ObjectLiteral>(
    repository: Repository<T>,
    where: FindOptionsWhere<T>,
    fieldLabel: string,
  ): Promise<void> {
    const existing = await repository.findOne({ where });
    if (existing) {
      throw new ConflictException(`Ya existe un registro con el mismo ${fieldLabel}`);
    }
  }
}
