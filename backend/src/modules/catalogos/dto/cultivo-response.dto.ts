import { ApiProperty } from '@nestjs/swagger';

import { Cultivo } from '../entities/cultivo.entity';

export class CultivoResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ example: 'Maiz' })
  nombre!: string;

  @ApiProperty({ example: 'Zea mays', nullable: true })
  nombreCientifico!: string | null;

  @ApiProperty({ example: 'cereal' })
  categoria!: string;

  @ApiProperty({ example: 'transitorio' })
  cicloVegetativo!: string;

  @ApiProperty({ example: 120, nullable: true })
  diasCosecha!: number | null;

  @ApiProperty({ example: 55000, nullable: true })
  densidadSiembraPorHa!: number | null;

  @ApiProperty({ nullable: true })
  descripcion!: string | null;

  @ApiProperty({ example: true })
  activo!: boolean;

  static fromEntity(entity: Cultivo): CultivoResponseDto {
    return {
      id: entity.id,
      nombre: entity.nombre,
      nombreCientifico: entity.nombreCientifico,
      categoria: entity.categoria,
      cicloVegetativo: entity.cicloVegetativo,
      diasCosecha: entity.diasCosecha,
      densidadSiembraPorHa: entity.densidadSiembraPorHa,
      descripcion: entity.descripcion,
      activo: entity.activo,
    };
  }
}
