import { ApiProperty } from '@nestjs/swagger';

import { Fertilizante } from '../entities/fertilizante.entity';

export class FertilizanteResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ example: 'Urea 46%' })
  nombre!: string;

  @ApiProperty({ example: 'nitrogenado' })
  tipo!: string;

  @ApiProperty({ example: '46-0-0', nullable: true })
  composicionNpk!: string | null;

  @ApiProperty({ example: 'solido_granulado' })
  presentacion!: string;

  @ApiProperty({ example: 250, nullable: true })
  dosisRecomendadaKgHa!: number | null;

  @ApiProperty({ nullable: true })
  descripcion!: string | null;

  @ApiProperty({ example: true })
  activo!: boolean;

  static fromEntity(entity: Fertilizante): FertilizanteResponseDto {
    return {
      id: entity.id,
      nombre: entity.nombre,
      tipo: entity.tipo,
      composicionNpk: entity.composicionNpk,
      presentacion: entity.presentacion,
      dosisRecomendadaKgHa:
        entity.dosisRecomendadaKgHa !== null ? Number(entity.dosisRecomendadaKgHa) : null,
      descripcion: entity.descripcion,
      activo: entity.activo,
    };
  }
}
