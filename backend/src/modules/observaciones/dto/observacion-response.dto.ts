import { ApiProperty } from '@nestjs/swagger';

import { Observacion } from '../entities/observacion.entity';

export class ObservacionResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ format: 'uuid' })
  loteId!: string;

  @ApiProperty({ description: 'Nombre del lote (JOIN con lotes)' })
  loteNombre!: string;

  @ApiProperty()
  descripcion!: string;

  @ApiProperty({ required: false, nullable: true })
  tipo!: string | null;

  @ApiProperty()
  fecha!: Date;

  @ApiProperty({ format: 'uuid' })
  userId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  static fromEntity(o: Observacion): ObservacionResponseDto {
    const dto = new ObservacionResponseDto();
    dto.id = o.id;
    dto.loteId = o.loteId;
    dto.loteNombre = o.lote?.nombre ?? '';
    dto.descripcion = o.descripcion;
    dto.tipo = o.tipo;
    dto.fecha = o.fecha;
    dto.userId = o.userId;
    dto.createdAt = o.createdAt;
    dto.updatedAt = o.updatedAt;
    return dto;
  }
}
