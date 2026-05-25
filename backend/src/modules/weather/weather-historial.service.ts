import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Between, LessThanOrEqual, MoreThanOrEqual, Repository } from 'typeorm';

import { JwtPayload } from '@/common/decorators/current-user.decorator';
import { Lote } from '@/modules/lotes/entities/lote.entity';
import { UserRole } from '@/modules/users/entities/user-role.enum';

import { WeatherResponseDto } from './dto/weather-response.dto';
import { WeatherHistorialQueryDto } from './dto/weather-historial-query.dto';
import { HistorialClima } from './entities/historial-clima.entity';

@Injectable()
export class WeatherHistorialService {
  constructor(
    @InjectRepository(HistorialClima)
    private readonly historialRepo: Repository<HistorialClima>,

    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,
  ) {}

  async registrarConsultaLote(loteId: string, weather: WeatherResponseDto): Promise<void> {
    const hoy = new Date().toISOString().slice(0, 10);
    const primerPronostico = weather.pronostico?.[0];

    const existing = await this.historialRepo.findOne({
      where: { loteId, fecha: hoy },
    });

    const data: Partial<HistorialClima> = {
      loteId,
      fecha: hoy,
      temperatura: weather.actual.temperatura,
      probabilidadLluvia:
        primerPronostico?.probabilidadLluvia ?? weather.actual.probabilidadLluvia ?? 0,
      precipitacionMm: primerPronostico?.precipitacionMm ?? 0,
      humedadSuelo: weather.actual.humedadSuelo,
      humedadRelativa: weather.actual.humedadRelativa,
      viento: weather.actual.viento,
      fuente: weather.fuente,
      registradoEn: new Date(weather.obtenidoEn),
    };

    const entity = existing ? Object.assign(existing, data) : this.historialRepo.create(data);

    await this.historialRepo.save(entity);
  }

  async findHistorialLote(
    loteId: string,
    user: JwtPayload,
    query: WeatherHistorialQueryDto,
  ): Promise<HistorialClima[]> {
    const lote = await this.lotesRepo.findOne({ where: { id: loteId } });

    if (!lote) {
      throw new NotFoundException(`Lote ${loteId} no encontrado`);
    }

    if (user.role !== UserRole.ADMINISTRADOR && lote.propietarioId !== user.sub) {
      throw new ForbiddenException('El lote no pertenece al usuario autenticado');
    }

    let fechaWhere: any = undefined;

    if (query.desde && query.hasta) {
      fechaWhere = Between(query.desde.slice(0, 10), query.hasta.slice(0, 10));
    } else if (query.desde) {
      fechaWhere = MoreThanOrEqual(query.desde.slice(0, 10));
    } else if (query.hasta) {
      fechaWhere = LessThanOrEqual(query.hasta.slice(0, 10));
    }

    return this.historialRepo.find({
      where: fechaWhere ? { loteId, fecha: fechaWhere } : { loteId },
      order: { fecha: 'DESC' },
    });
  }

  async findUltimoHistorial(loteId: string): Promise<HistorialClima | null> {
    return this.historialRepo.findOne({
      where: { loteId },
      order: { fecha: 'DESC' },
    });
  }

  async llovioEnUltimosDias(loteId: string, dias: number): Promise<boolean> {
    const desde = new Date();
    desde.setDate(desde.getDate() - dias);

    const count = await this.historialRepo
      .createQueryBuilder('h')
      .where('h.loteId = :loteId', { loteId })
      .andWhere('h.fecha >= :desde', { desde: desde.toISOString().slice(0, 10) })
      .andWhere('h.precipitacionMm > 0')
      .getCount();

    return count > 0;
  }
}
