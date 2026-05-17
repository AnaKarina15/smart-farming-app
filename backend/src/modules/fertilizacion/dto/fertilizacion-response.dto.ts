import { ApiProperty } from '@nestjs/swagger';

import { Fertilizacion } from '../entities/fertilizacion.entity';

export class FertilizacionResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ format: 'uuid' })
  loteId!: string;

  @ApiProperty({ description: 'Nombre del lote (JOIN con lotes)' })
  loteNombre!: string;

  @ApiProperty({ format: 'uuid', required: false, nullable: true })
  fertilizanteId!: string | null;

  @ApiProperty({
    required: false,
    nullable: true,
    description: 'Nombre del fertilizante (JOIN con fertilizantes)',
  })
  fertilizanteNombre!: string | null;

  @ApiProperty({ required: false, nullable: true })
  fertilizanteOtro!: string | null;

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

  static fromEntity(f: Fertilizacion): FertilizacionResponseDto {
    const dto = new FertilizacionResponseDto();
    dto.id = f.id;
    dto.loteId = f.loteId;
    dto.loteNombre = f.lote?.nombre ?? '';
    dto.fertilizanteId = f.fertilizanteId;
    dto.fertilizanteNombre = f.fertilizante?.nombre ?? null;
    dto.fertilizanteOtro = f.fertilizanteOtro;
    dto.dosis = f.dosis !== null ? Number(f.dosis) : null;
    dto.unidad = f.unidad;
    dto.metodoAplicacion = f.metodoAplicacion;
    dto.fecha = f.fecha;
    dto.observaciones = f.observaciones;
    dto.userId = f.userId;
    dto.createdAt = f.createdAt;
    dto.updatedAt = f.updatedAt;
    return dto;
  }
}
