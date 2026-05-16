import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsInt, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';

export const CATEGORIAS_CULTIVO = [
  'cereal',
  'frutal',
  'hortaliza',
  'leguminosa',
  'tuberculo',
  'comercial',
  'forraje',
] as const;

export const CICLOS_VEGETATIVOS = ['transitorio', 'permanente'] as const;

export class CreateCultivoDto {
  @ApiProperty({ example: 'Maiz' })
  @IsString()
  @MaxLength(100)
  nombre!: string;

  @ApiPropertyOptional({ example: 'Zea mays' })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  nombreCientifico?: string;

  @ApiProperty({ enum: CATEGORIAS_CULTIVO, example: 'cereal' })
  @IsIn([...CATEGORIAS_CULTIVO])
  categoria!: string;

  @ApiProperty({ enum: CICLOS_VEGETATIVOS, example: 'transitorio' })
  @IsIn([...CICLOS_VEGETATIVOS])
  cicloVegetativo!: string;

  @ApiPropertyOptional({ example: 120 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(3650)
  diasCosecha?: number;

  @ApiPropertyOptional({ example: 55000 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(1000000)
  densidadSiembraPorHa?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  descripcion?: string;
}
