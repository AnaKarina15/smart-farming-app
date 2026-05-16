import { ApiProperty } from '@nestjs/swagger';

import { Municipio } from '../entities/municipio.entity';

export class MunicipioResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ example: '47001' })
  codigoDane!: string;

  @ApiProperty({ example: 'Santa Marta' })
  nombre!: string;

  @ApiProperty({ example: 'Norte', nullable: true })
  subregion!: string | null;

  @ApiProperty({ example: 11.2408, nullable: true })
  latitud!: number | null;

  @ApiProperty({ example: -74.199, nullable: true })
  longitud!: number | null;

  @ApiProperty({ example: true })
  activo!: boolean;

  static fromEntity(entity: Municipio): MunicipioResponseDto {
    return {
      id: entity.id,
      codigoDane: entity.codigoDane,
      nombre: entity.nombre,
      subregion: entity.subregion,
      latitud: entity.latitud !== null ? Number(entity.latitud) : null,
      longitud: entity.longitud !== null ? Number(entity.longitud) : null,
      activo: entity.activo,
    };
  }
}
