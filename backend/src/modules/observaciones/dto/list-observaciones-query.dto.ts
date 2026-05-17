import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, IsUUID, Max, Min } from 'class-validator';

import { TIPOS_OBSERVACION } from './create-observacion.dto';

export class ListObservacionesQueryDto {
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

  @ApiPropertyOptional({ format: 'uuid', description: 'Filtrar por lote especifico' })
  @IsOptional()
  @IsUUID()
  loteId?: string;

  @ApiPropertyOptional({
    enum: TIPOS_OBSERVACION,
    description: 'Filtrar por categoria',
  })
  @IsOptional()
  @IsIn([...TIPOS_OBSERVACION])
  tipo?: string;
}
