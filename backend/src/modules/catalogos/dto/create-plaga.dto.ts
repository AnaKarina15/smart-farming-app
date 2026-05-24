import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

export const TIPOS_PLAGA = [
  'insecto',
  'hongo',
  'bacteria',
  'virus',
  'maleza',
  'nematodo',
  'acaro',
  'otro',
] as const;

export const SEVERIDADES_PLAGA = ['baja', 'media', 'alta', 'critica'] as const;

export class CreatePlagaDto {
  @ApiProperty({ example: 'Gusano cogollero' })
  @IsString()
  @MaxLength(100)
  nombre!: string;

  @ApiPropertyOptional({ example: 'Spodoptera frugiperda' })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  nombreCientifico?: string;

  @ApiProperty({ enum: TIPOS_PLAGA, example: 'insecto' })
  @IsIn([...TIPOS_PLAGA])
  tipo!: string;

  @ApiProperty({ enum: SEVERIDADES_PLAGA, example: 'alta' })
  @IsIn([...SEVERIDADES_PLAGA])
  severidadTipica!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  sintomas?: string;

  @ApiPropertyOptional({ example: 'maiz, sorgo, arroz' })
  @IsOptional()
  @IsString()
  cultivosAfectados?: string;
}
