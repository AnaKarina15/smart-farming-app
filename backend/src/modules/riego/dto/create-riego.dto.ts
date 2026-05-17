import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDateString,
  IsIn,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

/**
 * Tipos validos de riego.
 * Si el frontend manda otro valor, falla validacion.
 */
export const TIPOS_RIEGO = [
  'goteo',
  'aspersion',
  'microaspersion',
  'gravedad',
  'manual',
  'inundacion',
] as const;

export class CreateRiegoDto {
  @ApiProperty({ format: 'uuid', description: 'ID del lote a regar' })
  @IsUUID()
  @IsNotEmpty()
  loteId!: string;

  @ApiProperty({
    enum: TIPOS_RIEGO,
    example: 'goteo',
    description: 'Tipo de sistema de riego usado',
  })
  @IsString()
  @IsIn([...TIPOS_RIEGO])
  tipo!: string;

  @ApiProperty({ required: false, example: 45, description: 'Duracion en minutos' })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Type(() => Number)
  duracionMinutos?: number;

  @ApiProperty({ required: false, example: 500, description: 'Cantidad total en litros' })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Type(() => Number)
  cantidadLitros?: number;

  @ApiProperty({
    example: '2026-05-16T06:30:00Z',
    description: 'Fecha y hora del riego (ISO 8601)',
  })
  @IsDateString()
  fecha!: string;

  @ApiProperty({
    required: false,
    example: 65.5,
    minimum: 0,
    maximum: 100,
    description: 'Humedad porcentual medida en campo (0-100)',
  })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Max(100)
  @Type(() => Number)
  humedad?: number;

  @ApiProperty({ required: false, maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  observaciones?: string;
}
