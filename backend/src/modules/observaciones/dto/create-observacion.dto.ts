import { ApiProperty } from '@nestjs/swagger';
import {
  IsDateString,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
} from 'class-validator';

/**
 * Categorias de observacion sugeridas (no obligatorias).
 */
export const TIPOS_OBSERVACION = [
  'clima', // condiciones climaticas notables
  'fauna', // visita de animales (aves, ganado, etc.)
  'evento', // visita tecnica, capacitacion
  'recordatorio', // pendiente para una proxima labor
  'general', // nota libre
  'otro',
] as const;

export class CreateObservacionDto {
  @ApiProperty({ format: 'uuid', description: 'ID del lote al que pertenece la observacion' })
  @IsUUID()
  @IsNotEmpty()
  loteId!: string;

  @ApiProperty({
    example: 'Lluvia fuerte de 1 hora afecto el sector norte',
    description: 'Texto libre de la observacion',
    maxLength: 2000,
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(2000)
  descripcion!: string;

  @ApiProperty({
    enum: TIPOS_OBSERVACION,
    required: false,
    example: 'clima',
    description: 'Categoria opcional de la observacion',
  })
  @IsOptional()
  @IsString()
  @IsIn([...TIPOS_OBSERVACION])
  tipo?: string;

  @ApiProperty({
    example: '2026-05-17T14:00:00Z',
    description: 'Fecha de la observacion (ISO 8601)',
  })
  @IsDateString()
  fecha!: string;
}
