import { ApiProperty } from '@nestjs/swagger';

import { Riego } from '../entities/riego.entity';

export class RiegoResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ format: 'uuid' })
  loteId!: string;

  @ApiProperty({ description: 'Nombre del lote (JOIN con lotes)' })
  loteNombre!: string;

  @ApiProperty()
  tipo!: string;

  @ApiProperty({ required: false, nullable: true })
  duracionMinutos!: number | null;

  @ApiProperty({ required: false, nullable: true })
  cantidadLitros!: number | null;

  @ApiProperty()
  fecha!: Date;

  @ApiProperty({ required: false, nullable: true })
  humedad!: number | null;

  @ApiProperty({ required: false, nullable: true })
  observaciones!: string | null;

  @ApiProperty({ format: 'uuid' })
  userId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  static fromEntity(r: Riego): RiegoResponseDto {
    const dto = new RiegoResponseDto();
    dto.id = r.id;
    dto.loteId = r.loteId;
    dto.loteNombre = r.lote?.nombre ?? '';
    dto.tipo = r.tipo;
    dto.duracionMinutos = r.duracionMinutos !== null ? Number(r.duracionMinutos) : null;
    dto.cantidadLitros = r.cantidadLitros !== null ? Number(r.cantidadLitros) : null;
    dto.fecha = r.fecha;
    dto.humedad = r.humedad !== null ? Number(r.humedad) : null;
    dto.observaciones = r.observaciones;
    dto.userId = r.userId;
    dto.createdAt = r.createdAt;
    dto.updatedAt = r.updatedAt;
    return dto;
  }
}
