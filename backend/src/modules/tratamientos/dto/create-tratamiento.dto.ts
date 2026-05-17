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
  MaxLength,
  Min,
} from 'class-validator';

/**
 * Metodos de aplicacion comunes para tratamientos fitosanitarios.
 */
export const METODOS_APLICACION_TRATAMIENTO = [
  'foliar',
  'edafica',
  'fumigacion',
  'inyeccion',
  'trampa',
  'biologico',
  'manual',
] as const;

export class CreateTratamientoDto {
  @ApiProperty({ format: 'uuid', description: 'ID del lote donde se aplica el tratamiento' })
  @IsUUID()
  @IsNotEmpty()
  loteId!: string;

  @ApiProperty({
    format: 'uuid',
    required: false,
    description: 'ID del hallazgo asociado (si el tratamiento responde a una plaga detectada)',
  })
  @IsOptional()
  @IsUUID()
  hallazgoId?: string;

  @ApiProperty({
    example: 'Mancozeb 80% WP',
    maxLength: 150,
    description: 'Nombre del producto aplicado (comercial o generico)',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(150)
  producto!: string;

  @ApiProperty({ required: false, example: 2.5, description: 'Dosis aplicada' })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Type(() => Number)
  dosis?: number;

  @ApiProperty({ required: false, maxLength: 30, example: 'kg/ha' })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  unidad?: string;

  @ApiProperty({
    enum: METODOS_APLICACION_TRATAMIENTO,
    required: false,
    example: 'foliar',
    description: 'Metodo de aplicacion del tratamiento',
  })
  @IsOptional()
  @IsString()
  @IsIn([...METODOS_APLICACION_TRATAMIENTO])
  metodoAplicacion?: string;

  @ApiProperty({ example: '2026-05-16T10:00:00Z', description: 'Fecha de aplicacion' })
  @IsDateString()
  fecha!: string;

  @ApiProperty({ required: false, maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  observaciones?: string;
}
