import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDateString,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
} from 'class-validator';

/**
 * DTO para crear una Siembra.
 *
 * Reglas:
 * - loteId obligatorio.
 * - cultivoId O cultivoOtro: al menos uno (validado en service).
 * - userId NO se acepta aqui, se toma del JWT.
 * - loteNombre que pueda enviar el frontend es ignorado (se calcula con JOIN).
 */
export class CreateSiembraDto {
  @ApiProperty({ format: 'uuid', description: 'ID del lote donde se siembra' })
  @IsUUID()
  @IsNotEmpty()
  loteId!: string;

  @ApiProperty({
    format: 'uuid',
    required: false,
    description: 'ID del cultivo del catalogo. Si no se envia, usar cultivoOtro.',
  })
  @IsOptional()
  @IsUUID()
  cultivoId?: string;

  @ApiProperty({
    required: false,
    maxLength: 100,
    description: 'Cultivo no listado en el catalogo (escape valve)',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  cultivoOtro?: string;

  @ApiProperty({ required: false, maxLength: 100, example: 'Hibrido Tropical' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  variedad?: string;

  @ApiProperty({ example: '2026-05-16T10:00:00Z', description: 'Fecha de siembra (ISO 8601)' })
  @IsDateString()
  fecha!: string;

  @ApiProperty({ required: false, example: 5.5 })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Type(() => Number)
  cantidadSemillas?: number;

  @ApiProperty({ required: false, maxLength: 30, example: 'kg' })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  unidad?: string;

  @ApiProperty({ required: false, example: 0.8, description: 'Metros entre filas' })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Type(() => Number)
  distanciaEntreFilas?: number;

  @ApiProperty({ required: false, example: 0.25, description: 'Metros entre plantas' })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Type(() => Number)
  distanciaEntrePlantas?: number;

  @ApiProperty({ required: false, description: 'Notas adicionales del productor' })
  @IsOptional()
  @IsString()
  observaciones?: string;
}
