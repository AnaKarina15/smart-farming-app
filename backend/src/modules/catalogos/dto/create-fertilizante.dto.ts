import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsIn,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export const TIPOS_FERTILIZANTE = [
  'nitrogenado',
  'fosfatado',
  'potasico',
  'compuesto',
  'organico',
  'enmienda',
] as const;

export const PRESENTACIONES_FERTILIZANTE = [
  'solido_granulado',
  'solido_polvo',
  'liquido',
  'foliar',
] as const;

export class CreateFertilizanteDto {
  @ApiProperty({ example: 'Urea 46%' })
  @IsString()
  @MaxLength(100)
  nombre!: string;

  @ApiProperty({ enum: TIPOS_FERTILIZANTE, example: 'nitrogenado' })
  @IsIn([...TIPOS_FERTILIZANTE])
  tipo!: string;

  @ApiPropertyOptional({ example: '46-0-0' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  @Matches(/^\d{1,2}-\d{1,2}-\d{1,2}$/, {
    message: 'composicionNpk debe tener formato N-P-K (ej: 15-15-15)',
  })
  composicionNpk?: string;

  @ApiProperty({ enum: PRESENTACIONES_FERTILIZANTE, example: 'solido_granulado' })
  @IsIn([...PRESENTACIONES_FERTILIZANTE])
  presentacion!: string;

  @ApiPropertyOptional({ example: 250 })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  @Max(99999.99)
  dosisRecomendadaKgHa?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  descripcion?: string;
}
