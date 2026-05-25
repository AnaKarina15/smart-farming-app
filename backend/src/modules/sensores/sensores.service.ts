import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectDataSource, InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { UserRole } from '../users/entities/user-role.enum';
import { BatchLecturaSensorItemDto, BatchLecturasSensorDto } from './dto/batch-lecturas-sensor.dto';
import { CreateLecturaSensorDto } from './dto/create-lectura-sensor.dto';
import { CreateSensorDto } from './dto/create-sensor.dto';
import {
  BatchLecturaSensorResultDto,
  LecturaSensorResponseDto,
} from './dto/lectura-sensor-response.dto';
import { ListLecturasSensorQueryDto } from './dto/list-lecturas-sensor-query.dto';
import { ListSensoresQueryDto } from './dto/list-sensores-query.dto';
import { SensorResponseDto } from './dto/sensor-response.dto';
import { UpdateSensorDto } from './dto/update-sensor.dto';
import { LecturaSensor } from './entities/lectura-sensor.entity';
import { EstadoSensor, Sensor } from './entities/sensor.entity';
import { SensoresRepository } from './sensores.repository';

@Injectable()
export class SensoresService {
  constructor(
    private readonly sensoresRepo: SensoresRepository,

    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,

    @InjectDataSource()
    private readonly dataSource: DataSource,
  ) {}

  async create(dto: CreateSensorDto, userId: string, userRole: string): Promise<SensorResponseDto> {
    await this.assertLoteOwnership(dto.loteId, userId, userRole);

    const sensor = this.sensoresRepo.sensores.create({
      nombre: dto.nombre,
      tipo: dto.tipo,
      identificadorFisico: dto.identificadorFisico ?? null,
      loteId: dto.loteId,
      userId,
      estado:
        dto.estado ?? (dto.identificadorFisico ? EstadoSensor.ACTIVO : EstadoSensor.SIN_EMPAREJAR),
      unidadMedida: dto.unidadMedida,
      ultimaLecturaEn: null,
    });

    return SensorResponseDto.fromEntity(await this.sensoresRepo.sensores.save(sensor));
  }

  async findAll(
    query: ListSensoresQueryDto,
    userId: string,
    userRole: string,
  ): Promise<{ data: SensorResponseDto[]; total: number; page: number; limit: number }> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const qb = this.sensoresRepo.sensores
      .createQueryBuilder('sensor')
      .leftJoinAndSelect('sensor.lote', 'lote')
      .orderBy('sensor.createdAt', 'DESC')
      .skip(skip)
      .take(limit);

    if (userRole !== UserRole.ADMINISTRADOR) {
      qb.andWhere('sensor.userId = :userId', { userId });
    }

    if (query.loteId) {
      qb.andWhere('sensor.loteId = :loteId', { loteId: query.loteId });
    }

    if (query.tipo) {
      qb.andWhere('sensor.tipo = :tipo', { tipo: query.tipo });
    }

    if (query.estado) {
      qb.andWhere('sensor.estado = :estado', { estado: query.estado });
    }

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items.map(SensorResponseDto.fromEntity),
      total,
      page,
      limit,
    };
  }

  async findOne(id: string, userId: string, userRole: string): Promise<SensorResponseDto> {
    const sensor = await this.findAccessibleSensor(id, userId, userRole);
    return SensorResponseDto.fromEntity(sensor);
  }

  async update(
    id: string,
    dto: UpdateSensorDto,
    userId: string,
    userRole: string,
  ): Promise<SensorResponseDto> {
    const sensor = await this.findAccessibleSensor(id, userId, userRole);

    if (dto.loteId !== undefined && dto.loteId !== sensor.loteId) {
      await this.assertLoteOwnership(dto.loteId, userId, userRole);
      sensor.loteId = dto.loteId;
    }

    Object.assign(sensor, {
      ...(dto.nombre !== undefined && { nombre: dto.nombre }),
      ...(dto.tipo !== undefined && { tipo: dto.tipo }),
      ...(dto.identificadorFisico !== undefined && {
        identificadorFisico: dto.identificadorFisico ?? null,
      }),
      ...(dto.estado !== undefined && { estado: dto.estado }),
      ...(dto.unidadMedida !== undefined && { unidadMedida: dto.unidadMedida }),
    });

    return SensorResponseDto.fromEntity(await this.sensoresRepo.sensores.save(sensor));
  }

  async remove(id: string, userId: string, userRole: string): Promise<void> {
    const sensor = await this.findAccessibleSensor(id, userId, userRole);
    await this.sensoresRepo.sensores.softDelete(sensor.id);
  }

  async createLectura(
    sensorId: string,
    dto: CreateLecturaSensorDto,
    userId: string,
    userRole: string,
  ): Promise<LecturaSensorResponseDto> {
    const saved = await this.dataSource.transaction((manager) =>
      this.createLecturaInternal(manager, sensorId, dto, userId, userRole),
    );

    return LecturaSensorResponseDto.fromEntity(saved);
  }

  async createLecturasBatch(
    dto: BatchLecturasSensorDto,
    userId: string,
    userRole: string,
  ): Promise<{
    serverTime: string;
    results: BatchLecturaSensorResultDto[];
    summary: Record<string, number>;
  }> {
    const results = await this.dataSource.transaction(async (manager) => {
      const batchResults: BatchLecturaSensorResultDto[] = [];

      for (const item of dto.items) {
        batchResults.push(await this.processBatchItem(manager, item, userId, userRole));
      }

      return batchResults;
    });

    return {
      serverTime: new Date().toISOString(),
      results,
      summary: this.buildBatchSummary(results),
    };
  }

  async findLecturas(
    sensorId: string,
    query: ListLecturasSensorQueryDto,
    userId: string,
    userRole: string,
  ): Promise<{ data: LecturaSensorResponseDto[]; total: number; page: number; limit: number }> {
    const sensor = await this.findAccessibleSensor(sensorId, userId, userRole);
    const page = query.page ?? 1;
    const limit = query.limit ?? 50;
    const skip = (page - 1) * limit;

    const qb = this.sensoresRepo.lecturas
      .createQueryBuilder('lectura')
      .where('lectura.sensorId = :sensorId', { sensorId: sensor.id })
      .orderBy('lectura.medidoEn', 'DESC')
      .skip(skip)
      .take(limit);

    if (query.desde) {
      qb.andWhere('lectura.medidoEn >= :desde', { desde: new Date(query.desde) });
    }

    if (query.hasta) {
      qb.andWhere('lectura.medidoEn <= :hasta', { hasta: new Date(query.hasta) });
    }

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items.map(LecturaSensorResponseDto.fromEntity),
      total,
      page,
      limit,
    };
  }

  async findUltimaLectura(
    sensorId: string,
    userId: string,
    userRole: string,
  ): Promise<LecturaSensorResponseDto | null> {
    const sensor = await this.findAccessibleSensor(sensorId, userId, userRole);
    const lectura = await this.sensoresRepo.lecturas.findOne({
      where: { sensorId: sensor.id },
      order: { medidoEn: 'DESC' },
    });

    return lectura ? LecturaSensorResponseDto.fromEntity(lectura) : null;
  }

  private async processBatchItem(
    manager: EntityManager,
    item: BatchLecturaSensorItemDto,
    userId: string,
    userRole: string,
  ): Promise<BatchLecturaSensorResultDto> {
    try {
      if (item.clientLocalId) {
        const duplicate = await this.sensoresRepo.findLecturaByClientLocalId(
          userId,
          item.sensorId,
          item.clientLocalId,
          manager,
        );

        if (duplicate) {
          return {
            clientLocalId: item.clientLocalId,
            sensorId: item.sensorId,
            lecturaId: duplicate.id,
            status: 'duplicate',
          };
        }
      }

      const saved = await this.createLecturaInternal(
        manager,
        item.sensorId,
        item,
        userId,
        userRole,
      );

      return {
        clientLocalId: item.clientLocalId ?? null,
        sensorId: item.sensorId,
        lecturaId: saved.id,
        status: 'created',
      };
    } catch (error) {
      return {
        clientLocalId: item.clientLocalId ?? null,
        sensorId: item.sensorId,
        status: 'error',
        error: this.errorMessage(error),
      };
    }
  }

  private async createLecturaInternal(
    manager: EntityManager,
    sensorId: string,
    dto: CreateLecturaSensorDto,
    userId: string,
    userRole: string,
  ): Promise<LecturaSensor> {
    const sensor = await this.findAccessibleSensor(sensorId, userId, userRole, manager);

    if (sensor.estado === EstadoSensor.INACTIVO) {
      throw new BadRequestException('No se pueden registrar lecturas en un sensor inactivo');
    }

    if (dto.clientLocalId) {
      const duplicate = await this.sensoresRepo.findLecturaByClientLocalId(
        userId,
        sensor.id,
        dto.clientLocalId,
        manager,
      );

      if (duplicate) {
        return duplicate;
      }
    }

    const medidoEn = new Date(dto.medidoEn);

    if (Number.isNaN(medidoEn.getTime())) {
      throw new BadRequestException('medidoEn debe ser una fecha ISO8601 valida');
    }

    const lectura = this.sensoresRepo.lecturaRepo(manager).create({
      sensorId: sensor.id,
      loteId: sensor.loteId,
      valor: dto.valor,
      unidad: dto.unidad ?? sensor.unidadMedida,
      calidadSenal: dto.calidadSenal ?? null,
      origen: dto.origen,
      medidoEn,
      userId,
      clientLocalId: dto.clientLocalId ?? null,
    });

    const saved = await this.sensoresRepo.lecturaRepo(manager).save(lectura);

    if (!sensor.ultimaLecturaEn || medidoEn >= sensor.ultimaLecturaEn) {
      sensor.ultimaLecturaEn = medidoEn;
      await this.sensoresRepo.sensorRepo(manager).save(sensor);
    }

    return saved;
  }

  private async findAccessibleSensor(
    sensorId: string,
    userId: string,
    userRole: string,
    manager?: EntityManager,
  ): Promise<Sensor> {
    const sensor = await this.sensoresRepo.findSensorById(sensorId, manager);

    if (!sensor) {
      throw new NotFoundException(`Sensor ${sensorId} no encontrado`);
    }

    if (userRole !== UserRole.ADMINISTRADOR && sensor.userId !== userId) {
      throw new ForbiddenException('No tienes acceso a este sensor');
    }

    return sensor;
  }

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
      throw new ForbiddenException('El lote no pertenece al usuario autenticado');
    }
  }

  private buildBatchSummary(results: BatchLecturaSensorResultDto[]): Record<string, number> {
    return results.reduce(
      (summary, item) => {
        summary.total += 1;
        summary[item.status] = (summary[item.status] ?? 0) + 1;
        return summary;
      },
      { total: 0, created: 0, duplicate: 0, error: 0 } as Record<string, number>,
    );
  }

  private errorMessage(error: unknown): string {
    if (
      error instanceof BadRequestException ||
      error instanceof NotFoundException ||
      error instanceof ForbiddenException
    ) {
      const response = error.getResponse();

      if (typeof response === 'object' && response && 'message' in response) {
        const message = (response as { message?: string | string[] }).message;
        return Array.isArray(message) ? message.join('; ') : String(message);
      }

      return error.message;
    }

    if (error instanceof Error) {
      return error.message;
    }

    return 'Error desconocido al registrar lectura de sensor';
  }
}
