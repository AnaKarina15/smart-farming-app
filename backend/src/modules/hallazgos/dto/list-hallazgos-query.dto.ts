import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, IsUUID, Max, Min } from 'class-validator';

import { SEVERIDADES } from './create-hallazgo.dto';

export class ListHallazgosQueryDto {
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
    enum: SEVERIDADES,
    description: 'Filtrar por severidad',
  })
  @IsOptional()
  @IsIn([...SEVERIDADES])
  severidad?: string;
}
