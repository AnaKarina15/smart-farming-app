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
 * Niveles de severidad estandarizados.
 */
export const SEVERIDADES = ['baja', 'media', 'alta', 'critica'] as const;

export class CreateHallazgoDto {
  @ApiProperty({ format: 'uuid', description: 'ID del lote donde se observo el hallazgo' })
  @IsUUID()
  @IsNotEmpty()
  loteId!: string;

  @ApiProperty({
    format: 'uuid',
    required: false,
    description: 'ID de la plaga del catalogo. Si no se envia, usar plagaOtro.',
  })
  @IsOptional()
  @IsUUID()
  plagaId?: string;

  @ApiProperty({
    required: false,
    maxLength: 100,
    description: 'Plaga o problema no listado (escape valve)',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  plagaOtro?: string;

  @ApiProperty({
    enum: SEVERIDADES,
    example: 'media',
    description: 'Severidad observada del hallazgo',
  })
  @IsString()
  @IsIn([...SEVERIDADES])
  severidad!: string;

  @ApiProperty({ required: false, description: 'Descripcion detallada del hallazgo' })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  descripcion?: string;

  @ApiProperty({
    required: false,
    maxLength: 500,
    description: 'Ruta o URL de la foto del hallazgo',
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  fotoPath?: string;

  @ApiProperty({ example: '2026-05-16T09:00:00Z', description: 'Fecha del hallazgo (ISO 8601)' })
  @IsDateString()
  fecha!: string;
}
