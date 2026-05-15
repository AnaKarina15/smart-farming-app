import { Controller, Get, Query } from '@nestjs/common';
import { WeatherService } from './weather.service';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';

@ApiTags('Weather')
@Controller('weather')
export class WeatherController {
  constructor(private readonly weatherService: WeatherService) {}

  @Get('current')
  @ApiOperation({ summary: 'Get current temperature by coordinates' })
  @ApiQuery({ name: 'lat', type: Number, required: true })
  @ApiQuery({ name: 'lon', type: Number, required: true })
  async getCurrentWeather(
    @Query('lat') lat: number,
    @Query('lon') lon: number,
  ) {
    return this.weatherService.getWeatherData(lat, lon);
  }

  @Get('sensor/humidity')
  async getSoilHumiditySensorData() {
    // Simulamos lectura de sensor: 68% y tendencia de 24 horas
    const history = Array.from({ length: 24 }, () => Math.floor(Math.random() * 20) + 50); // Valores entre 50 y 70
    return {
      connected: true,
      currentValue: 68,
      history24h: history,
    };
  }
}
