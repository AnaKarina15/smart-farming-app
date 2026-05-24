import { ApiProperty } from '@nestjs/swagger';
import { EstadoTerreno } from '../entities/estado-terreno.entity';

export class EstadoTerrenoResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ format: 'uuid' })
  loteId!: string;

  @ApiProperty({ description: 'Nombre del lote (JOIN con lotes)' })
  loteNombre!: string;

  @ApiProperty({ format: 'uuid', required: false, nullable: true })
  siembraId!: string | null;

  @ApiProperty()
  estado!: string;

  @ApiProperty({ format: 'uuid', required: false, nullable: true })
  tipoSueloId!: string | null;

  @ApiProperty({ required: false, nullable: true })
  notas!: string | null;

  @ApiProperty({ format: 'uuid' })
  userId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  static fromEntity(e: EstadoTerreno): EstadoTerrenoResponseDto {
    const dto = new EstadoTerrenoResponseDto();
    dto.id = e.id;
    dto.loteId = e.loteId;
    dto.loteNombre = e.lote?.nombre ?? '';
    dto.siembraId = e.siembraId;
    dto.estado = e.estado;
    dto.tipoSueloId = e.tipoSueloId;
    dto.notas = e.notas;
    dto.userId = e.userId;
    dto.createdAt = e.createdAt;
    dto.updatedAt = e.updatedAt;
    return dto;
  }
}
