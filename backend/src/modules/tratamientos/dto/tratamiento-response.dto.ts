import { ApiProperty } from '@nestjs/swagger';

import { Tratamiento } from '../entities/tratamiento.entity';

export class TratamientoResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ format: 'uuid' })
  loteId!: string;

  @ApiProperty({ description: 'Nombre del lote (JOIN con lotes)' })
  loteNombre!: string;

  @ApiProperty({ format: 'uuid', required: false, nullable: true })
  hallazgoId!: string | null;

  @ApiProperty({
    required: false,
    nullable: true,
    description: 'Severidad del hallazgo asociado (JOIN, si aplica)',
  })
  hallazgoSeveridad!: string | null;

  @ApiProperty()
  producto!: string;

  @ApiProperty({ required: false, nullable: true })
  dosis!: number | null;

  @ApiProperty({ required: false, nullable: true })
  unidad!: string | null;

  @ApiProperty({ required: false, nullable: true })
  metodoAplicacion!: string | null;

  @ApiProperty()
  fecha!: Date;

  @ApiProperty({ required: false, nullable: true })
  observaciones!: string | null;

  @ApiProperty({ format: 'uuid' })
  userId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  static fromEntity(t: Tratamiento): TratamientoResponseDto {
    const dto = new TratamientoResponseDto();
    dto.id = t.id;
    dto.loteId = t.loteId;
    dto.loteNombre = t.lote?.nombre ?? '';
    dto.hallazgoId = t.hallazgoId;
    dto.hallazgoSeveridad = t.hallazgo?.severidad ?? null;
    dto.producto = t.producto;
    dto.dosis = t.dosis !== null ? Number(t.dosis) : null;
    dto.unidad = t.unidad;
    dto.metodoAplicacion = t.metodoAplicacion;
    dto.fecha = t.fecha;
    dto.observaciones = t.observaciones;
    dto.userId = t.userId;
    dto.createdAt = t.createdAt;
    dto.updatedAt = t.updatedAt;
    return dto;
  }
}
