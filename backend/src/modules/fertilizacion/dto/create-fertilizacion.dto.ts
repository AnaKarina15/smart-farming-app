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
 * Metodos de aplicacion comunes en agricultura del Magdalena.
 */
export const METODOS_APLICACION = [
  'edafica', // al suelo
  'foliar', // hojas
  'fertirriego', // disuelto en agua de riego
  'banda', // banda lateral
  'voleo', // distribucion manual amplia
  'localizada', // localizada en planta
] as const;

export class CreateFertilizacionDto {
  @ApiProperty({ format: 'uuid', description: 'ID del lote fertilizado' })
  @IsUUID()
  @IsNotEmpty()
  loteId!: string;

  @ApiProperty({
    format: 'uuid',
    required: false,
    description: 'ID del fertilizante del catalogo. Si no se envia, usar fertilizanteOtro.',
  })
  @IsOptional()
  @IsUUID()
  fertilizanteId?: string;

  @ApiProperty({
    required: false,
    maxLength: 100,
    description: 'Fertilizante no listado (escape valve)',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  fertilizanteOtro?: string;

  @ApiProperty({ required: false, example: 50, description: 'Dosis aplicada' })
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
    enum: METODOS_APLICACION,
    required: false,
    example: 'edafica',
    description: 'Metodo de aplicacion',
  })
  @IsOptional()
  @IsString()
  @IsIn([...METODOS_APLICACION])
  metodoAplicacion?: string;

  @ApiProperty({ example: '2026-05-16T08:00:00Z', description: 'Fecha de aplicacion' })
  @IsDateString()
  fecha!: string;

  @ApiProperty({ required: false, maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  observaciones?: string;
}
