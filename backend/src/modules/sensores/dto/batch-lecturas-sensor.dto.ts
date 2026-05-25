import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  ValidateNested,
} from 'class-validator';

import { CreateLecturaSensorDto } from './create-lectura-sensor.dto';

export class BatchLecturaSensorItemDto extends CreateLecturaSensorDto {
  @ApiProperty({ format: 'uuid', description: 'Sensor al que pertenece la lectura.' })
  @IsUUID()
  sensorId!: string;
}

export class BatchLecturasSensorDto {
  @ApiPropertyOptional({ example: 'android-installation-id', maxLength: 120 })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  deviceId?: string;

  @ApiProperty({ type: [BatchLecturaSensorItemDto], minItems: 1, maxItems: 200 })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(200)
  @ValidateNested({ each: true })
  @Type(() => BatchLecturaSensorItemDto)
  items!: BatchLecturaSensorItemDto[];
}
