import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

import { Estacion } from '../entities/estacion.enum';
import { FaseAgronomica } from '../entities/fase-agronomica.enum';
import { TipoRecomendacion } from '../entities/tipo-recomendacion.enum';

const SEVERIDADES_VALIDAS = ['baja', 'media', 'alta', 'critica'];

export class CreateReglaDto {
  // ─── Identificacion ───
  @ApiProperty({
    example: 'R-RIEGO-001',
    description: 'Codigo unico de la regla. Formato: R-{CATEGORIA}-{NNN}',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  codigo!: string;

  @ApiProperty({ example: 'Banano sin riego en estacion seca' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  nombre!: string;

  @ApiPropertyOptional({ description: 'Descripcion ampliada de la regla' })
  @IsOptional()
  @IsString()
  descripcion?: string;

  // ─── Categoria ───
  @ApiProperty({ enum: TipoRecomendacion, example: TipoRecomendacion.RIEGO })
  @IsEnum(TipoRecomendacion)
  tipoRecomendacion!: TipoRecomendacion;

  // ─── Condiciones IF (todas opcionales) ───
  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  cultivoId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  plagaId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  tipoSueloId?: string;

  @ApiPropertyOptional({ enum: FaseAgronomica })
  @IsOptional()
  @IsEnum(FaseAgronomica)
  faseAgronomica?: FaseAgronomica;

  @ApiPropertyOptional({
    enum: SEVERIDADES_VALIDAS,
    description: 'Severidad minima del hallazgo para activar la regla',
  })
  @IsOptional()
  @IsIn(SEVERIDADES_VALIDAS)
  severidadMinima?: string;

  @ApiPropertyOptional({ enum: Estacion })
  @IsOptional()
  @IsEnum(Estacion)
  estacion?: Estacion;

  @ApiPropertyOptional({ description: 'Dispara si lote lleva >= X dias sin riego' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  diasSinRiegoMinimo?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  diasDesdeSiembraMinimo?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  diasDesdeSiembraMaximo?: number;

  @ApiPropertyOptional({ description: 'Humedad maxima del lote (0-100)' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(100)
  humedadMaxima?: number;

  @ApiPropertyOptional({ description: 'Humedad minima del lote (0-100)' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(100)
  humedadMinima?: number;

  // ─── Accion THEN ───
  @ApiProperty({ description: 'Descripcion en lenguaje natural de la accion sugerida' })
  @IsString()
  @IsNotEmpty()
  accionSugerida!: string;

  @ApiPropertyOptional({ example: 'Mancozeb 80% WP' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  productoSugerido?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  fertilizanteSugeridoId?: string;

  @ApiPropertyOptional({ example: 2.5 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  dosisRecomendada?: number;

  @ApiPropertyOptional({ example: 'kg/ha' })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  unidadRecomendada?: string;

  @ApiPropertyOptional({ example: 'aspersion foliar' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  metodoAplicacion?: string;

  @ApiPropertyOptional({ example: 14, description: 'Repetir cada X dias' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  frecuenciaDias?: number;

  // ─── Metadatos ───
  @ApiPropertyOptional({ minimum: 1, maximum: 5, default: 3 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(5)
  prioridad?: number;

  @ApiProperty({
    example: 'ICA Resolucion 092771/2021',
    description: 'Cita de la fuente cientifica. OBLIGATORIA.',
  })
  @IsString()
  @IsNotEmpty()
  fuenteCientifica!: string;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  activa?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notas?: string;
}
