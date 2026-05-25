import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { JwtPayload } from '@/common/decorators/current-user.decorator';
import { Lote } from '@/modules/lotes/entities/lote.entity';
import { UserRole } from '@/modules/users/entities/user-role.enum';

import { WeatherResponseDto } from './dto/weather-response.dto';
import { WeatherService } from './weather.service';

/**
 * Resuelve el clima de un lote a partir de sus coordenadas.
 * Valida que el lote pertenezca al usuario autenticado (admin ve todos).
 */
@Injectable()
export class WeatherLoteService {
  constructor(
    private readonly weatherService: WeatherService,
    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,
  ) {}

  async getWeatherForLote(loteId: string, user: JwtPayload, dias = 5): Promise<WeatherResponseDto> {
    const lote = await this.lotesRepo.findOne({ where: { id: loteId } });

    if (!lote) {
      throw new NotFoundException(`Lote ${loteId} no encontrado`);
    }

    if (user.role !== UserRole.ADMINISTRADOR && lote.propietarioId !== user.sub) {
      throw new ForbiddenException('El lote no pertenece al usuario autenticado');
    }

    if (lote.latitud === null || lote.longitud === null) {
      throw new NotFoundException(
        'El lote no tiene coordenadas registradas. Asigne ubicacion al lote para consultar su clima.',
      );
    }

    return this.weatherService.getWeather(Number(lote.latitud), Number(lote.longitud), dias);
  }
}
