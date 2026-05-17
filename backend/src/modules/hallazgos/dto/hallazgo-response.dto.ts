import { ApiProperty } from '@nestjs/swagger';

import { Hallazgo } from '../entities/hallazgo.entity';

export class HallazgoResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ format: 'uuid' })
  loteId!: string;

  @ApiProperty({ description: 'Nombre del lote (JOIN con lotes)' })
  loteNombre!: string;

  @ApiProperty({ format: 'uuid', required: false, nullable: true })
  plagaId!: string | null;

  @ApiProperty({
    required: false,
    nullable: true,
    description: 'Nombre de la plaga (JOIN con plagas)',
  })
  plagaNombre!: string | null;

  @ApiProperty({ required: false, nullable: true })
  plagaOtro!: string | null;

  @ApiProperty()
  severidad!: string;

  @ApiProperty({ required: false, nullable: true })
  descripcion!: string | null;

  @ApiProperty({ required: false, nullable: true })
  fotoPath!: string | null;

  @ApiProperty()
  fecha!: Date;

  @ApiProperty({ format: 'uuid' })
  userId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  static fromEntity(h: Hallazgo): HallazgoResponseDto {
    const dto = new HallazgoResponseDto();
    dto.id = h.id;
    dto.loteId = h.loteId;
    dto.loteNombre = h.lote?.nombre ?? '';
    dto.plagaId = h.plagaId;
    dto.plagaNombre = h.plaga?.nombre ?? null;
    dto.plagaOtro = h.plagaOtro;
    dto.severidad = h.severidad;
    dto.descripcion = h.descripcion;
    dto.fotoPath = h.fotoPath;
    dto.fecha = h.fecha;
    dto.userId = h.userId;
    dto.createdAt = h.createdAt;
    dto.updatedAt = h.updatedAt;
    return dto;
  }
}
