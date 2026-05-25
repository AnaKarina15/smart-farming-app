import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDateString,
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

import { OrigenLecturaSensor } from '../entities/lectura-sensor.entity';

export class CreateLecturaSensorDto {
  @ApiProperty({ example: 42.5, description: 'Valor medido por el sensor.' })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 3 })
  valor!: number;

  @ApiPropertyOptional({ example: '%', maxLength: 30 })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  unidad?: string;

  @ApiPropertyOptional({ minimum: 0, maximum: 100, example: 87 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(100)
  calidadSenal?: number;

  @ApiProperty({ enum: OrigenLecturaSensor, example: OrigenLecturaSensor.MANUAL })
  @IsEnum(OrigenLecturaSensor)
  origen!: OrigenLecturaSensor;

  @ApiProperty({ example: '2026-05-25T08:30:00.000Z' })
  @IsDateString()
  medidoEn!: string;

  @ApiPropertyOptional({
    example: 'lecturas_sensor:123',
    description: 'ID local estable para idempotencia en sincronizacion offline.',
    maxLength: 150,
  })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  clientLocalId?: string;
}
