import { ApiProperty } from '@nestjs/swagger';

import { Plaga } from '../entities/plaga.entity';

export class PlagaResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ example: 'Gusano cogollero' })
  nombre!: string;

  @ApiProperty({ example: 'Spodoptera frugiperda', nullable: true })
  nombreCientifico!: string | null;

  @ApiProperty({ example: 'insecto' })
  tipo!: string;

  @ApiProperty({ example: 'alta' })
  severidadTipica!: string;

  @ApiProperty({ nullable: true })
  sintomas!: string | null;

  @ApiProperty({ example: 'maiz, sorgo, arroz', nullable: true })
  cultivosAfectados!: string | null;

  @ApiProperty({ example: true })
  activo!: boolean;

  static fromEntity(entity: Plaga): PlagaResponseDto {
    return {
      id: entity.id,
      nombre: entity.nombre,
      nombreCientifico: entity.nombreCientifico,
      tipo: entity.tipo,
      severidadTipica: entity.severidadTipica,
      sintomas: entity.sintomas,
      cultivosAfectados: entity.cultivosAfectados,
      activo: entity.activo,
    };
  }
}
