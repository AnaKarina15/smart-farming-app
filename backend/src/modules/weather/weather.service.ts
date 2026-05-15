import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class WeatherService {
  private readonly logger = new Logger(WeatherService.name);
  private readonly baseUrl = 'https://api.open-meteo.com/v1/forecast';

  constructor(private readonly httpService: HttpService) {}

  async getWeatherData(lat: number, lon: number): Promise<{ temperature: string; rainProbability: string }> {
    try {
      const url = `${this.baseUrl}?latitude=${lat}&longitude=${lon}&current_weather=true&hourly=precipitation_probability&forecast_days=1`;
      const response = await firstValueFrom(this.httpService.get(url));
      
      let temperature = '--°C';
      let rainProbability = '--%';

      if (response.data) {
        if (response.data.current_weather) {
          temperature = `${Math.round(response.data.current_weather.temperature)}°C`;
        }
        
        if (response.data.hourly && response.data.hourly.precipitation_probability) {
          // Tomamos la probabilidad de la hora actual (índice 0 para el pronóstico de hoy)
          const prob = response.data.hourly.precipitation_probability[0];
          rainProbability = `${prob}%`;
        }
      }

      return { temperature, rainProbability };
    } catch (error) {
      this.logger.error(`Error fetching weather data for lat:${lat}, lon:${lon}`, (error as any).stack);
      return { temperature: '--°C', rainProbability: '--%' };
    }
  }
}
