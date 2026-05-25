import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

import { LecturaSensor, OrigenLecturaSensor } from '../entities/lectura-sensor.entity';

export class LecturaSensorResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ format: 'uuid' })
  sensorId!: string;

  @ApiProperty({ format: 'uuid' })
  loteId!: string;

  @ApiProperty()
  valor!: number;

  @ApiProperty()
  unidad!: string;

  @ApiPropertyOptional({ nullable: true })
  calidadSenal!: number | null;

  @ApiProperty({ enum: OrigenLecturaSensor })
  origen!: OrigenLecturaSensor;

  @ApiProperty()
  medidoEn!: string;

  @ApiProperty({ format: 'uuid' })
  userId!: string;

  @ApiPropertyOptional({ nullable: true })
  clientLocalId!: string | null;

  @ApiProperty()
  createdAt!: string;

  static fromEntity(entity: LecturaSensor): LecturaSensorResponseDto {
    return {
      id: entity.id,
      sensorId: entity.sensorId,
      loteId: entity.loteId,
      valor: Number(entity.valor),
      unidad: entity.unidad,
      calidadSenal: entity.calidadSenal,
      origen: entity.origen,
      medidoEn: new Date(entity.medidoEn).toISOString(),
      userId: entity.userId,
      clientLocalId: entity.clientLocalId,
      createdAt: new Date(entity.createdAt).toISOString(),
    };
  }
}

export class BatchLecturaSensorResultDto {
  @ApiProperty({ example: 'lecturas_sensor:123' })
  clientLocalId!: string | null;

  @ApiProperty({ format: 'uuid' })
  sensorId!: string;

  @ApiPropertyOptional({ format: 'uuid' })
  lecturaId?: string;

  @ApiProperty({ enum: ['created', 'duplicate', 'error'] })
  status!: 'created' | 'duplicate' | 'error';

  @ApiPropertyOptional()
  error?: string;
}
