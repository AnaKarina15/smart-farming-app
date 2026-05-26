import { ApiProperty } from '@nestjs/swagger';

import { Siembra } from '../../siembras/entities/siembra.entity';
import { Lote } from '../entities/lote.entity';

export class LoteSiembraResumenDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ format: 'uuid', required: false, nullable: true })
  cultivoId!: string | null;

  @ApiProperty({ required: false, nullable: true })
  cultivoNombre!: string | null;

  @ApiProperty({ required: false, nullable: true })
  cultivoOtro!: string | null;

  @ApiProperty({ required: false, nullable: true })
  variedad!: string | null;

  @ApiProperty()
  fecha!: Date;

  static fromEntity(siembra: Siembra): LoteSiembraResumenDto {
    const dto = new LoteSiembraResumenDto();
    dto.id = siembra.id;
    dto.cultivoId = siembra.cultivoId;
    dto.cultivoNombre = siembra.cultivo?.nombre ?? siembra.cultivoOtro ?? null;
    dto.cultivoOtro = siembra.cultivoOtro;
    dto.variedad = siembra.variedad;
    dto.fecha = siembra.fecha;
    return dto;
  }
}

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

  @ApiProperty({
    format: 'uuid',
    required: false,
    nullable: true,
    description: 'FK al catalogo de tipos de suelo',
  })
  tipoSueloId!: string | null;

  @ApiProperty({ required: false, nullable: true })
  latitud!: number | null;

  @ApiProperty({ required: false, nullable: true })
  longitud!: number | null;

  @ApiProperty()
  estado!: string;

  @ApiProperty({
    required: false,
    nullable: true,
    description: 'Nombre del cultivo de la ultima siembra registrada para mostrar en cards.',
  })
  siembraActualNombre!: string | null;

  @ApiProperty({
    type: LoteSiembraResumenDto,
    required: false,
    nullable: true,
    description: 'Resumen de la ultima siembra asociada al lote.',
  })
  ultimaSiembra!: LoteSiembraResumenDto | null;

  @ApiProperty({ format: 'uuid' })
  propietarioId!: string;

  @ApiProperty({ required: false, nullable: true })
  propietarioNombre!: string | null;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  static fromEntity(lote: Lote, ultimaSiembra?: Siembra | null): LoteResponseDto {
    const dto = new LoteResponseDto();
    dto.id = lote.id;
    dto.nombre = lote.nombre;
    dto.descripcion = lote.descripcion;
    dto.superficieHectareas = Number(lote.superficieHectareas);
    dto.cultivoActual = lote.cultivoActual;
    dto.cultivoActualId = lote.cultivoActualId;
    dto.municipioId = lote.municipioId;
    dto.tipoSueloId = lote.tipoSueloId;
    dto.latitud = lote.latitud !== null ? Number(lote.latitud) : null;
    dto.longitud = lote.longitud !== null ? Number(lote.longitud) : null;
    dto.estado = lote.estado;
    dto.ultimaSiembra = ultimaSiembra ? LoteSiembraResumenDto.fromEntity(ultimaSiembra) : null;
    dto.siembraActualNombre =
      dto.ultimaSiembra?.cultivoNombre ?? dto.ultimaSiembra?.cultivoOtro ?? lote.cultivoActual;
    dto.propietarioId = lote.propietarioId;
    dto.propietarioNombre = lote.propietario?.nombreCompleto ?? null;
    dto.createdAt = lote.createdAt;
    dto.updatedAt = lote.updatedAt;
    return dto;
  }
}
