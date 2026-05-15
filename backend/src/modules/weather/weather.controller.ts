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
    return this.weatherService.getCurrentTemperature(lat, lon);
  }
}
