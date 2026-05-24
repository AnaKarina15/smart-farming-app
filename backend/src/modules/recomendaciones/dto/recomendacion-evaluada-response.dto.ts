import { ApiProperty } from '@nestjs/swagger';

import { ReglaResponseDto } from './regla-response.dto';

/**
 * Una recomendacion evaluada por el motor: es una Regla que MATCHEO
 * con el contexto del lote, lista para mostrarse al productor.
 *
 * Incluye:
 * - La regla completa (con producto, dosis, fuente cientifica, etc.)
 * - El motivo del match (ej: "Hallazgo de Sigatoka severidad alta detectado hace 2 dias")
 * - Datos contextuales del lote que dispararon la regla
 */
export class RecomendacionEvaluadaResponseDto {
  @ApiProperty({ type: () => ReglaResponseDto })
  regla!: ReglaResponseDto;

  @ApiProperty({
    description: 'Razon por la que esta regla aplica al lote (legible)',
    example: 'Hallazgo de Sigatoka negra con severidad alta detectado el 2026-05-15',
  })
  motivoMatch!: string;

  @ApiProperty({
    description: 'Etiqueta de prioridad para UI',
    example: 'ALTA PRIORIDAD',
  })
  etiquetaPrioridad!: string;

  @ApiProperty({
    description: 'Color sugerido para badge en frontend',
    example: '#D32F2F',
  })
  colorPrioridad!: string;
}
