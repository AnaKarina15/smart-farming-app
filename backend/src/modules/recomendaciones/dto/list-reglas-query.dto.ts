import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { IsBoolean, IsEnum, IsInt, IsOptional, IsString, IsUUID, Max, Min } from 'class-validator';

import { TipoRecomendacion } from '../entities/tipo-recomendacion.enum';

export class ListReglasQueryDto {
  @ApiPropertyOptional({ minimum: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ minimum: 1, maximum: 100, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @ApiPropertyOptional({ enum: TipoRecomendacion })
  @IsOptional()
  @IsEnum(TipoRecomendacion)
  tipoRecomendacion?: TipoRecomendacion;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  cultivoId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  plagaId?: string;

  @ApiPropertyOptional({ description: 'Filtrar por activas (default true)' })
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  activa?: boolean;

  @ApiPropertyOptional({ description: 'Buscar por codigo o nombre' })
  @IsOptional()
  @IsString()
  search?: string;
}
