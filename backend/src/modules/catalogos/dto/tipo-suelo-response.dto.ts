import { ApiProperty } from '@nestjs/swagger';

import { TipoSuelo } from '../entities/tipo-suelo.entity';

export class TipoSueloResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ example: 'Franco arenoso' })
  nombre!: string;

  @ApiProperty({ example: 'franco_arenoso' })
  clase!: string;

  @ApiProperty({ example: 'moderado' })
  drenaje!: string;

  @ApiProperty({ example: 20.5, nullable: true })
  retencionHumedadPct!: number | null;

  @ApiProperty({ example: 6.5, nullable: true })
  phTipico!: number | null;

  @ApiProperty({ nullable: true })
  cultivosRecomendados!: string | null;

  @ApiProperty({ nullable: true })
  descripcion!: string | null;

  @ApiProperty({ example: true })
  activo!: boolean;

  static fromEntity(entity: TipoSuelo): TipoSueloResponseDto {
    return {
      id: entity.id,
      nombre: entity.nombre,
      clase: entity.clase,
      drenaje: entity.drenaje,
      retencionHumedadPct:
        entity.retencionHumedadPct !== null ? Number(entity.retencionHumedadPct) : null,
      phTipico: entity.phTipico !== null ? Number(entity.phTipico) : null,
      cultivosRecomendados: entity.cultivosRecomendados,
      descripcion: entity.descripcion,
      activo: entity.activo,
    };
  }
}
