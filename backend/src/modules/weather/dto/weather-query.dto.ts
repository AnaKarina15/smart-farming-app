import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsLatitude, IsLongitude, IsNotEmpty } from 'class-validator';

/**
 * Query para consultar clima por coordenadas explicitas.
 */
export class WeatherQueryDto {
  @ApiProperty({
    example: 11.2408,
    description: 'Latitud en grados decimales (-90 a 90).',
  })
  @Type(() => Number)
  @IsLatitude()
  @IsNotEmpty()
  lat!: number;

  @ApiProperty({
    example: -74.199,
    description: 'Longitud en grados decimales (-180 a 180).',
  })
  @Type(() => Number)
  @IsLongitude()
  @IsNotEmpty()
  lon!: number;
}
