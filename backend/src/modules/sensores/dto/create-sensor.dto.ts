import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

import { EstadoSensor, TipoSensor } from '../entities/sensor.entity';

export class CreateSensorDto {
  @ApiProperty({ example: 'Sensor humedad suelo lote norte', maxLength: 100 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nombre!: string;

  @ApiProperty({ enum: TipoSensor, example: TipoSensor.HUMEDAD_SUELO })
  @IsEnum(TipoSensor)
  tipo!: TipoSensor;

  @ApiPropertyOptional({ example: 'A4:C1:38:00:11:22', maxLength: 120 })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  identificadorFisico?: string;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  loteId!: string;

  @ApiPropertyOptional({ enum: EstadoSensor, example: EstadoSensor.ACTIVO })
  @IsOptional()
  @IsEnum(EstadoSensor)
  estado?: EstadoSensor;

  @ApiProperty({ example: '%', maxLength: 30 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(30)
  unidadMedida!: string;
}
