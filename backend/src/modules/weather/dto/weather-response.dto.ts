import { ApiProperty } from '@nestjs/swagger';

/**
 * Clima actual de una ubicacion.
 */
export class WeatherActualDto {
  @ApiProperty({ example: 31.4, description: 'Temperatura actual en grados Celsius.' })
  temperatura!: number;

  @ApiProperty({ example: 'C', description: 'Unidad de temperatura.' })
  unidadTemperatura!: string;

  @ApiProperty({ example: 65, description: 'Probabilidad de lluvia en la hora actual (%).' })
  probabilidadLluvia!: number;

  @ApiProperty({ example: 14.2, description: 'Velocidad del viento en km/h.' })
  viento!: number;

  @ApiProperty({
    example: 72,
    description: 'Humedad relativa del aire (%). Puede ser null si la API no la entrega.',
    nullable: true,
  })
  humedadRelativa!: number | null;

  @ApiProperty({
    example: 0.28,
    description:
      'Humedad volumetrica del suelo a 0-1 cm (m3/m3) segun Open-Meteo. ' +
      'null si la API no la entrega.',
    nullable: true,
  })
  humedadSuelo!: number | null;
}

/**
 * Pronostico de un dia.
 */
export class WeatherDiaDto {
  @ApiProperty({ example: '2026-05-25', description: 'Fecha del pronostico (YYYY-MM-DD).' })
  fecha!: string;

  @ApiProperty({ example: 33.1, description: 'Temperatura maxima del dia (Celsius).' })
  tempMax!: number;

  @ApiProperty({ example: 24.5, description: 'Temperatura minima del dia (Celsius).' })
  tempMin!: number;

  @ApiProperty({ example: 80, description: 'Probabilidad maxima de lluvia del dia (%).' })
  probabilidadLluvia!: number;

  @ApiProperty({ example: 12.4, description: 'Precipitacion total esperada (mm).' })
  precipitacionMm!: number;
}

/**
 * Respuesta completa del modulo de clima.
 */
export class WeatherResponseDto {
  @ApiProperty({ example: 11.24, description: 'Latitud consultada.' })
  latitud!: number;

  @ApiProperty({ example: -74.2, description: 'Longitud consultada.' })
  longitud!: number;

  @ApiProperty({ type: WeatherActualDto })
  actual!: WeatherActualDto;

  @ApiProperty({ type: [WeatherDiaDto], description: 'Pronostico extendido por dias.' })
  pronostico!: WeatherDiaDto[];

  @ApiProperty({
    example: '2026-05-24T11:00:00.000Z',
    description: 'Momento en que se obtuvo el dato desde la fuente.',
  })
  obtenidoEn!: string;

  @ApiProperty({
    example: 'open-meteo',
    description:
      "Origen del dato: 'open-meteo' si es fresco desde la API, " +
      "'cache' si la API no respondio y se sirvio el ultimo dato guardado.",
  })
  fuente!: 'open-meteo' | 'cache';

  @ApiProperty({
    example: false,
    description: 'true si el dato proviene de cache porque la API externa no respondio.',
  })
  desdeCacheFallback!: boolean;
}
