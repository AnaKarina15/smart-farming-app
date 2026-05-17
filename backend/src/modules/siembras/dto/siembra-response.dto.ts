import { ApiProperty } from '@nestjs/swagger';

import { Siembra } from '../entities/siembra.entity';

/**
 * DTO de respuesta para Siembra.
 *
 * Incluye loteNombre y cultivoNombre (calculados con JOIN), util para que
 * el frontend muestre informacion sin tener que cruzar con catalogos.
 */
export class SiembraResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ format: 'uuid' })
  loteId!: string;

  @ApiProperty({ description: 'Nombre del lote (JOIN con lotes)' })
  loteNombre!: string;

  @ApiProperty({ format: 'uuid', required: false, nullable: true })
  cultivoId!: string | null;

  @ApiProperty({
    required: false,
    nullable: true,
    description: 'Nombre del cultivo (JOIN con cultivos)',
  })
  cultivoNombre!: string | null;

  @ApiProperty({ required: false, nullable: true })
  cultivoOtro!: string | null;

  @ApiProperty({ required: false, nullable: true })
  variedad!: string | null;

  @ApiProperty()
  fecha!: Date;

  @ApiProperty({ required: false, nullable: true })
  cantidadSemillas!: number | null;

  @ApiProperty({ required: false, nullable: true })
  unidad!: string | null;

  @ApiProperty({ required: false, nullable: true })
  distanciaEntreFilas!: number | null;

  @ApiProperty({ required: false, nullable: true })
  distanciaEntrePlantas!: number | null;

  @ApiProperty({ required: false, nullable: true })
  observaciones!: string | null;

  @ApiProperty({ format: 'uuid' })
  userId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  static fromEntity(s: Siembra): SiembraResponseDto {
    const dto = new SiembraResponseDto();
    dto.id = s.id;
    dto.loteId = s.loteId;
    dto.loteNombre = s.lote?.nombre ?? '';
    dto.cultivoId = s.cultivoId;
    dto.cultivoNombre = s.cultivo?.nombre ?? null;
    dto.cultivoOtro = s.cultivoOtro;
    dto.variedad = s.variedad;
    dto.fecha = s.fecha;
    dto.cantidadSemillas = s.cantidadSemillas !== null ? Number(s.cantidadSemillas) : null;
    dto.unidad = s.unidad;
    dto.distanciaEntreFilas = s.distanciaEntreFilas !== null ? Number(s.distanciaEntreFilas) : null;
    dto.distanciaEntrePlantas =
      s.distanciaEntrePlantas !== null ? Number(s.distanciaEntrePlantas) : null;
    dto.observaciones = s.observaciones;
    dto.userId = s.userId;
    dto.createdAt = s.createdAt;
    dto.updatedAt = s.updatedAt;
    return dto;
  }
}
