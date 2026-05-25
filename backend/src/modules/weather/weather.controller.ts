import { Controller, Get, Param, ParseUUIDPipe, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiResponse, ApiTags } from '@nestjs/swagger';

import { CurrentUser, JwtPayload } from '@/common/decorators/current-user.decorator';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';

import { WeatherQueryDto } from './dto/weather-query.dto';
import { WeatherResponseDto } from './dto/weather-response.dto';
import { WeatherLoteService } from './weather-lote.service';
import { WeatherService } from './weather.service';

/**
 * Controller del modulo de clima (Sprint 6).
 *
 * Expone clima actual + pronostico extendido, por coordenadas o por lote.
 * Todos los endpoints requieren autenticacion JWT.
 */
@ApiTags('Weather')
@Controller('weather')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class WeatherController {
  constructor(
    private readonly weatherService: WeatherService,
    private readonly weatherLoteService: WeatherLoteService,
  ) {}

  @Get('current')
  @ApiOperation({
    summary: 'Clima actual + pronostico por coordenadas',
    description:
      'Devuelve clima actual y pronostico extendido para una ubicacion. ' +
      'Usa cache resiliente: si Open-Meteo no responde, sirve el ultimo dato guardado.',
  })
  @ApiQuery({
    name: 'dias',
    required: false,
    type: Number,
    description: 'Dias de pronostico (1-7).',
  })
  @ApiResponse({ status: 200, type: WeatherResponseDto })
  getCurrent(
    @Query() query: WeatherQueryDto,
    @Query('dias') dias?: number,
  ): Promise<WeatherResponseDto> {
    return this.weatherService.getWeather(query.lat, query.lon, dias ? Number(dias) : 5);
  }

  @Get('lote/:loteId')
  @ApiOperation({
    summary: 'Clima de un lote especifico',
    description:
      'Devuelve el clima de un lote usando sus coordenadas registradas. ' +
      'Valida que el lote pertenezca al usuario autenticado.',
  })
  @ApiQuery({
    name: 'dias',
    required: false,
    type: Number,
    description: 'Dias de pronostico (1-7).',
  })
  @ApiResponse({ status: 200, type: WeatherResponseDto })
  getForLote(
    @CurrentUser() user: JwtPayload,
    @Param('loteId', ParseUUIDPipe) loteId: string,
    @Query('dias') dias?: number,
  ): Promise<WeatherResponseDto> {
    return this.weatherLoteService.getWeatherForLote(loteId, user, dias ? Number(dias) : 5);
  }
}
