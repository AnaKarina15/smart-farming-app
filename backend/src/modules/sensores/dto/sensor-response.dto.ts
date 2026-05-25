import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

import { EstadoSensor, Sensor, TipoSensor } from '../entities/sensor.entity';

export class SensorResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty()
  nombre!: string;

  @ApiProperty({ enum: TipoSensor })
  tipo!: TipoSensor;

  @ApiPropertyOptional({ nullable: true })
  identificadorFisico!: string | null;

  @ApiProperty({ format: 'uuid' })
  loteId!: string;

  @ApiProperty({ format: 'uuid' })
  userId!: string;

  @ApiProperty({ enum: EstadoSensor })
  estado!: EstadoSensor;

  @ApiProperty()
  unidadMedida!: string;

  @ApiPropertyOptional({ nullable: true })
  ultimaLecturaEn!: string | null;

  @ApiProperty()
  createdAt!: string;

  @ApiProperty()
  updatedAt!: string;

  static fromEntity(entity: Sensor): SensorResponseDto {
    return {
      id: entity.id,
      nombre: entity.nombre,
      tipo: entity.tipo,
      identificadorFisico: entity.identificadorFisico,
      loteId: entity.loteId,
      userId: entity.userId,
      estado: entity.estado,
      unidadMedida: entity.unidadMedida,
      ultimaLecturaEn: entity.ultimaLecturaEn
        ? new Date(entity.ultimaLecturaEn).toISOString()
        : null,
      createdAt: new Date(entity.createdAt).toISOString(),
      updatedAt: new Date(entity.updatedAt).toISOString(),
    };
  }
}
