import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class WeatherService {
  private readonly logger = new Logger(WeatherService.name);
  private readonly baseUrl = 'https://api.open-meteo.com/v1/forecast';

  constructor(private readonly httpService: HttpService) {}

  async getCurrentTemperature(lat: number, lon: number): Promise<{ temperature: string }> {
    try {
      const url = `${this.baseUrl}?latitude=${lat}&longitude=${lon}&current_weather=true`;
      const response = await firstValueFrom(this.httpService.get(url));
      
      if (response.data && response.data.current_weather) {
        const temp = response.data.current_weather.temperature;
        return { temperature: `${Math.round(temp)}°C` };
      }
      return { temperature: '--°C' };
    } catch (error) {
      this.logger.error(`Error fetching weather for lat:${lat}, lon:${lon}`, (error as any).stack);
      return { temperature: '--°C' };
    }
  }
}
