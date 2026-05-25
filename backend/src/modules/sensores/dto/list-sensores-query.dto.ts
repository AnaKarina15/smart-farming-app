import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsUUID, Max, Min } from 'class-validator';

import { EstadoSensor, TipoSensor } from '../entities/sensor.entity';

export class ListSensoresQueryDto {
  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  loteId?: string;

  @ApiPropertyOptional({ enum: TipoSensor })
  @IsOptional()
  @IsEnum(TipoSensor)
  tipo?: TipoSensor;

  @ApiPropertyOptional({ enum: EstadoSensor })
  @IsOptional()
  @IsEnum(EstadoSensor)
  estado?: EstadoSensor;

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
}
