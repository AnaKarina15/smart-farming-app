import { ApiProperty } from '@nestjs/swagger';

import { Lote } from '../entities/lote.entity';

export class LoteResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty()
  nombre!: string;

  @ApiProperty({ required: false, nullable: true })
  descripcion!: string | null;

  @ApiProperty()
  superficieHectareas!: number;

  @ApiProperty({
    required: false,
    nullable: true,
    description: '@deprecated: nombre legacy del cultivo (string). Usar cultivoActualId.',
  })
  cultivoActual!: string | null;

  @ApiProperty({
    format: 'uuid',
    required: false,
    nullable: true,
    description: 'FK al catalogo de cultivos',
  })
  cultivoActualId!: string | null;

  @ApiProperty({
    format: 'uuid',
    required: false,
    nullable: true,
    description: 'FK al catalogo de municipios del Magdalena',
  })
  municipioId!: string | null;

  @ApiProperty({ required: false, nullable: true })
  latitud!: number | null;

  @ApiProperty({ required: false, nullable: true })
  longitud!: number | null;

  @ApiProperty()
  estado!: string;

  @ApiProperty({ format: 'uuid' })
  propietarioId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  static fromEntity(lote: Lote): LoteResponseDto {
    const dto = new LoteResponseDto();
    dto.id = lote.id;
    dto.nombre = lote.nombre;
    dto.descripcion = lote.descripcion;
    dto.superficieHectareas = Number(lote.superficieHectareas);
    dto.cultivoActual = lote.cultivoActual;
    dto.cultivoActualId = lote.cultivoActualId;
    dto.municipioId = lote.municipioId;
    dto.latitud = lote.latitud !== null ? Number(lote.latitud) : null;
    dto.longitud = lote.longitud !== null ? Number(lote.longitud) : null;
    dto.estado = lote.estado;
    dto.propietarioId = lote.propietarioId;
    dto.createdAt = lote.createdAt;
    dto.updatedAt = lote.updatedAt;
    return dto;
  }
}
