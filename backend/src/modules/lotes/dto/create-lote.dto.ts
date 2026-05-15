import { ApiProperty } from '@nestjs/swagger';
import {
  IsLatitude,
  IsLongitude,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

/**
 * DTO para crear un Lote.
 *
 * Restriccion de negocio: superficie maxima 5 hectareas (Fase 1).
 */
export class CreateLoteDto {
  @ApiProperty({ example: 'Lote Norte', maxLength: 100 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nombre!: string;

  @ApiProperty({ example: 'Sector norte de la finca', required: false, maxLength: 200 })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  descripcion?: string;

  @ApiProperty({
    example: 2.5,
    minimum: 0.01,
    maximum: 5,
    description: 'Superficie en hectareas (maximo 5 segun el contexto del proyecto)',
  })
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  @Max(5, { message: 'La superficie no puede exceder 5 hectareas' })
  superficieHectareas!: number;

  @ApiProperty({ example: 'Maiz', required: false, maxLength: 100 })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  cultivoActual?: string;

  @ApiProperty({ example: 11.2408, required: false })
  @IsOptional()
  @IsLatitude()
  latitud?: number;

  @ApiProperty({ example: -74.199, required: false })
  @IsOptional()
  @IsLongitude()
  longitud?: number;
}
