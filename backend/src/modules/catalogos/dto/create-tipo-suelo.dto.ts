import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsNumber, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';

export const CLASES_SUELO = [
  'arenoso',
  'franco_arenoso',
  'franco',
  'franco_arcilloso',
  'arcilloso',
  'limoso',
  'aluvial',
  'organico',
  'vertisol',
] as const;

export const DRENAJES_SUELO = ['rapido', 'moderado', 'lento', 'nulo'] as const;

export class CreateTipoSueloDto {
  @ApiProperty({ example: 'Franco arenoso' })
  @IsString()
  @MaxLength(50)
  nombre!: string;

  @ApiProperty({ enum: CLASES_SUELO, example: 'franco_arenoso' })
  @IsIn([...CLASES_SUELO])
  clase!: string;

  @ApiProperty({ enum: DRENAJES_SUELO, example: 'moderado' })
  @IsIn([...DRENAJES_SUELO])
  drenaje!: string;

  @ApiPropertyOptional({ example: 20.5 })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 1 })
  @Min(0)
  @Max(100)
  retencionHumedadPct?: number;

  @ApiPropertyOptional({ example: 6.5 })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 1 })
  @Min(0)
  @Max(14)
  phTipico?: number;

  @ApiPropertyOptional({ example: 'maiz, yuca, platano' })
  @IsOptional()
  @IsString()
  cultivosRecomendados?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  descripcion?: string;
}
