import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';

import { JwtPayload } from '@/common/decorators/current-user.decorator';
import { EstadoTerreno } from '@/modules/estado-terreno/entities/estado-terreno.entity';
import { Fertilizacion } from '@/modules/fertilizacion/entities/fertilizacion.entity';
import { Hallazgo } from '@/modules/hallazgos/entities/hallazgo.entity';
import { Observacion } from '@/modules/observaciones/entities/observacion.entity';
import { Riego } from '@/modules/riego/entities/riego.entity';
import { Siembra } from '@/modules/siembras/entities/siembra.entity';
import { Tratamiento } from '@/modules/tratamientos/entities/tratamiento.entity';
import { UserRole } from '@/modules/users/entities/user-role.enum';

import { CreateLoteDto } from './dto/create-lote.dto';
import { LoteHistoryItemDto, LoteHistoryResponseDto } from './dto/lote-history-response.dto';
import { LoteResponseDto } from './dto/lote-response.dto';
import { UpdateLoteDto } from './dto/update-lote.dto';
import { Lote } from './entities/lote.entity';
import { LotesRepository } from './lotes.repository';

const SUPERFICIE_MAXIMA_TOTAL = 5;

@Injectable()
export class LotesService {
  constructor(
    private readonly lotesRepo: LotesRepository,
    @InjectRepository(Siembra)
    private readonly siembrasRepo: Repository<Siembra>,
    @InjectRepository(Riego)
    private readonly riegoRepo: Repository<Riego>,
    @InjectRepository(Fertilizacion)
    private readonly fertilizacionRepo: Repository<Fertilizacion>,
    @InjectRepository(Hallazgo)
    private readonly hallazgosRepo: Repository<Hallazgo>,
    @InjectRepository(Tratamiento)
    private readonly tratamientosRepo: Repository<Tratamiento>,
    @InjectRepository(Observacion)
    private readonly observacionesRepo: Repository<Observacion>,
    @InjectRepository(EstadoTerreno)
    private readonly estadoTerrenoRepo: Repository<EstadoTerreno>,
  ) {}

  async create(propietarioId: string, dto: CreateLoteDto): Promise<LoteResponseDto> {
    const lote = await this.lotesRepo.create({ ...dto, propietarioId });
    return LoteResponseDto.fromEntity(lote, null);
  }

  /**
   * Lista TODOS los lotes del sistema (solo admin debe llamar esto).
   */
  async findAll(): Promise<LoteResponseDto[]> {
    const lotes = await this.lotesRepo.findAll();
    return this.mapLotesWithUltimaSiembra(lotes);
  }

  async findAllByPropietario(propietarioId: string): Promise<LoteResponseDto[]> {
    const lotes = await this.lotesRepo.findByPropietario(propietarioId);
    return this.mapLotesWithUltimaSiembra(lotes);
  }

  async findOne(id: string, propietarioId: string): Promise<LoteResponseDto> {
    const lote = await this.assertOwnership(id, propietarioId);
    return LoteResponseDto.fromEntity(lote, await this.findUltimaSiembra(lote.id));
  }

  /**
   * Admin puede ver cualquier lote sin restriccion de propiedad.
   */
  async findOneAdmin(id: string): Promise<LoteResponseDto> {
    const lote = await this.lotesRepo.findById(id);
    if (!lote) {
      throw new NotFoundException(`Lote con id ${id} no encontrado`);
    }
    return LoteResponseDto.fromEntity(lote, await this.findUltimaSiembra(lote.id));
  }

  async update(
    id: string,
    userId: string,
    dto: UpdateLoteDto,
    userRole: UserRole,
  ): Promise<LoteResponseDto> {
    // Admin bypasea verificacion de ownership
    if (userRole === UserRole.ADMINISTRADOR) {
      const lote = await this.lotesRepo.findById(id);
      if (!lote) {
        throw new NotFoundException(`Lote con id ${id} no encontrado`);
      }
    } else {
      await this.assertOwnership(id, userId);
    }

    await this.lotesRepo.update(id, dto);
    const updated = await this.lotesRepo.findById(id);
    return LoteResponseDto.fromEntity(updated!, await this.findUltimaSiembra(id));
  }

  async remove(id: string, userId: string, userRole: UserRole): Promise<void> {
    // Admin bypasea verificacion de ownership
    if (userRole !== UserRole.ADMINISTRADOR) {
      await this.assertOwnership(id, userId);
    } else {
      const lote = await this.lotesRepo.findById(id);
      if (!lote) {
        throw new NotFoundException(`Lote con id ${id} no encontrado`);
      }
    }
    await this.lotesRepo.delete(id);
  }

  /**
   * Estadisticas globales de lotes (admin).
   */
  async getStats(): Promise<{
    totalLotes: number;
    superficieTotalHectareas: number;
    promedioPorProductor: number;
  }> {
    const lotes = await this.lotesRepo.findAll();
    const totalLotes = lotes.length;
    const superficieTotalHectareas = lotes.reduce(
      (sum, l) => sum + Number(l.superficieHectareas),
      0,
    );
    const propietariosUnicos = new Set(lotes.map((l) => l.propietarioId)).size;
    const promedioPorProductor = propietariosUnicos > 0 ? totalLotes / propietariosUnicos : 0;

    return {
      totalLotes,
      superficieTotalHectareas: Math.round(superficieTotalHectareas * 100) / 100,
      promedioPorProductor: Math.round(promedioPorProductor * 100) / 100,
    };
  }

  async getHistorialLote(
    id: string,
    user: JwtPayload,
  ): Promise<LoteHistoryResponseDto> {
    if (user.role === UserRole.ADMINISTRADOR) {
      const lote = await this.lotesRepo.findById(id);
      if (!lote) {
        throw new NotFoundException(`Lote con id ${id} no encontrado`);
      }
    } else {
      await this.assertOwnership(id, user.sub);
    }

    const data = await this.buildHistorial([id], user);
    return {
      scope: 'lote',
      loteId: id,
      total: data.length,
      generatedAt: new Date(),
      data,
    };
  }

  async getHistorialGlobal(user: JwtPayload): Promise<LoteHistoryResponseDto> {
    const lotes =
      user.role === UserRole.ADMINISTRADOR
        ? await this.lotesRepo.findAll()
        : await this.lotesRepo.findByPropietario(user.sub);
    const loteIds = lotes.map((lote) => lote.id);
    const data = await this.buildHistorial(loteIds, user);

    return {
      scope: 'global',
      loteId: null,
      total: data.length,
      generatedAt: new Date(),
      data,
    };
  }

  private async assertOwnership(id: string, propietarioId: string): Promise<Lote> {
    const lote = await this.lotesRepo.findById(id);
    if (!lote) {
      throw new NotFoundException(`Lote con id ${id} no encontrado`);
    }
    if (lote.propietarioId !== propietarioId) {
      throw new ForbiddenException('No tienes permiso para acceder a este lote');
    }
    return lote;
  }

  private async mapLotesWithUltimaSiembra(lotes: Lote[]): Promise<LoteResponseDto[]> {
    const loteIds = lotes.map((lote) => lote.id);
    const ultimasSiembras = await this.findUltimasSiembrasPorLote(loteIds);
    return lotes.map((lote) => LoteResponseDto.fromEntity(lote, ultimasSiembras.get(lote.id)));
  }

  private async findUltimaSiembra(loteId: string): Promise<Siembra | null> {
    return this.siembrasRepo.findOne({
      where: { loteId },
      relations: ['cultivo'],
      order: { fecha: 'DESC', createdAt: 'DESC' },
    });
  }

  private async findUltimasSiembrasPorLote(loteIds: string[]): Promise<Map<string, Siembra>> {
    const result = new Map<string, Siembra>();
    if (loteIds.length === 0) return result;

    const siembras = await this.siembrasRepo.find({
      where: { loteId: In(loteIds) },
      relations: ['cultivo'],
      order: { fecha: 'DESC', createdAt: 'DESC' },
    });

    for (const siembra of siembras) {
      if (!result.has(siembra.loteId)) {
        result.set(siembra.loteId, siembra);
      }
    }

    return result;
  }

  private async buildHistorial(loteIds: string[], user: JwtPayload): Promise<LoteHistoryItemDto[]> {
    if (loteIds.length === 0) return [];

    const where = this.historyWhere(loteIds, user);
    const [
      siembras,
      riegos,
      fertilizaciones,
      hallazgos,
      tratamientos,
      observaciones,
      estadosTerreno,
    ] = await Promise.all([
      this.siembrasRepo.find({
        where,
        relations: ['lote', 'cultivo'],
        order: { fecha: 'DESC', createdAt: 'DESC' },
      }),
      this.riegoRepo.find({
        where,
        relations: ['lote'],
        order: { fecha: 'DESC', createdAt: 'DESC' },
      }),
      this.fertilizacionRepo.find({
        where,
        relations: ['lote', 'fertilizante'],
        order: { fecha: 'DESC', createdAt: 'DESC' },
      }),
      this.hallazgosRepo.find({
        where,
        relations: ['lote', 'plaga'],
        order: { fecha: 'DESC', createdAt: 'DESC' },
      }),
      this.tratamientosRepo.find({
        where,
        relations: ['lote', 'hallazgo'],
        order: { fecha: 'DESC', createdAt: 'DESC' },
      }),
      this.observacionesRepo.find({
        where,
        relations: ['lote'],
        order: { fecha: 'DESC', createdAt: 'DESC' },
      }),
      this.estadoTerrenoRepo.find({
        where,
        relations: ['lote'],
        order: { createdAt: 'DESC' },
      }),
    ]);

    const items = [
      ...siembras.map((s) =>
        this.historyItem('siembras', s, s.fecha, `Siembra: ${s.cultivo?.nombre ?? s.cultivoOtro ?? 'Sin cultivo'}`, {
          cultivoId: s.cultivoId,
          cultivoNombre: s.cultivo?.nombre ?? null,
          cultivoOtro: s.cultivoOtro,
          variedad: s.variedad,
          cantidadSemillas: s.cantidadSemillas !== null ? Number(s.cantidadSemillas) : null,
          unidad: s.unidad,
        }),
      ),
      ...riegos.map((r) =>
        this.historyItem('riego', r, r.fecha, `Riego: ${r.tipo}`, {
          tipo: r.tipo,
          duracionMinutos: r.duracionMinutos !== null ? Number(r.duracionMinutos) : null,
          cantidadLitros: r.cantidadLitros !== null ? Number(r.cantidadLitros) : null,
          humedad: r.humedad !== null ? Number(r.humedad) : null,
        }),
      ),
      ...fertilizaciones.map((f) =>
        this.historyItem(
          'fertilizacion',
          f,
          f.fecha,
          `Fertilizacion: ${f.fertilizante?.nombre ?? f.fertilizanteOtro ?? 'Sin insumo'}`,
          {
            fertilizanteId: f.fertilizanteId,
            fertilizanteNombre: f.fertilizante?.nombre ?? null,
            fertilizanteOtro: f.fertilizanteOtro,
            dosis: f.dosis !== null ? Number(f.dosis) : null,
            unidad: f.unidad,
            metodoAplicacion: f.metodoAplicacion,
          },
        ),
      ),
      ...hallazgos.map((h) =>
        this.historyItem(
          'hallazgos',
          h,
          h.fecha,
          `Hallazgo: ${h.plaga?.nombre ?? h.plagaOtro ?? h.severidad}`,
          {
            plagaId: h.plagaId,
            plagaNombre: h.plaga?.nombre ?? null,
            plagaOtro: h.plagaOtro,
            severidad: h.severidad,
            descripcion: h.descripcion,
            fotoPath: h.fotoPath,
          },
        ),
      ),
      ...tratamientos.map((t) =>
        this.historyItem('tratamientos', t, t.fecha, `Tratamiento: ${t.producto}`, {
          hallazgoId: t.hallazgoId,
          hallazgoSeveridad: t.hallazgo?.severidad ?? null,
          producto: t.producto,
          dosis: t.dosis !== null ? Number(t.dosis) : null,
          unidad: t.unidad,
          metodoAplicacion: t.metodoAplicacion,
          observaciones: t.observaciones,
        }),
      ),
      ...observaciones.map((o) =>
        this.historyItem('observaciones', o, o.fecha, 'Observacion de campo', {
          tipo: o.tipo,
          descripcion: o.descripcion,
        }),
      ),
      ...estadosTerreno.map((e) =>
        this.historyItem('estado-terreno', e, e.createdAt, `Estado del terreno: ${e.estado}`, {
          siembraId: e.siembraId,
          tipoSueloId: e.tipoSueloId,
          estado: e.estado,
          notas: e.notas,
        }),
      ),
    ];

    return items.sort((a, b) => b.fecha.getTime() - a.fecha.getTime());
  }

  private historyWhere(loteIds: string[], user: JwtPayload) {
    const base = { loteId: In(loteIds) };
    if (user.role === UserRole.ADMINISTRADOR) return base;
    return { ...base, userId: user.sub };
  }

  private historyItem(
    resourceType: string,
    entity: {
      id: string;
      loteId: string;
      lote?: Lote;
      createdAt: Date;
      updatedAt: Date;
    },
    fecha: Date,
    titulo: string,
    payload: Record<string, unknown>,
  ): LoteHistoryItemDto {
    return {
      id: entity.id,
      resourceType,
      loteId: entity.loteId,
      loteNombre: entity.lote?.nombre ?? '',
      titulo,
      fecha,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      payload,
    };
  }
}
