import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsDateString, IsEnum, IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';

import { DecisionRecomendacion } from '../entities/decision-recomendacion.enum';

/**
 * DTO que envia el frontend cuando el productor toma una decision
 * sobre una recomendacion (aplicar, ignorar, aplicar diferente).
 */
export class AplicarRecomendacionDto {
  @ApiProperty({ format: 'uuid', description: 'ID del lote sobre el que aplica' })
  @IsUUID()
  @IsNotEmpty()
  loteId!: string;

  @ApiProperty({
    enum: DecisionRecomendacion,
    description: 'Decision tomada por el productor',
  })
  @IsEnum(DecisionRecomendacion)
  decision!: DecisionRecomendacion;

  @ApiPropertyOptional({
    description: 'Nota libre del productor (ej: "lo aplique a la mitad de la dosis")',
  })
  @IsOptional()
  @IsString()
  notaProductor?: string;

  @ApiProperty({
    description: 'Fecha cuando el motor sugirio la recomendacion (ISO 8601)',
    example: '2026-05-17T10:00:00Z',
  })
  @IsDateString()
  fechaSugerida!: string;

  @ApiPropertyOptional({
    description: 'Resultado observado por el productor (se puede actualizar despues)',
  })
  @IsOptional()
  @IsString()
  resultadoObservado?: string;
}
