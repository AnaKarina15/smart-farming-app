import { ForbiddenException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';

import { Hallazgo } from '../hallazgos/entities/hallazgo.entity';
import { Lote } from '../lotes/entities/lote.entity';
import { Riego } from '../riego/entities/riego.entity';
import { Siembra } from '../siembras/entities/siembra.entity';
import { UserRole } from '../users/entities/user-role.enum';

import { AplicarRecomendacionDto } from './dto/aplicar-recomendacion.dto';
import { CreateReglaDto } from './dto/create-regla.dto';
import { ListReglasQueryDto } from './dto/list-reglas-query.dto';
import { RecomendacionEvaluadaResponseDto } from './dto/recomendacion-evaluada-response.dto';
import { ReglaResponseDto } from './dto/regla-response.dto';
import { UpdateReglaDto } from './dto/update-regla.dto';
import { DecisionRecomendacion } from './entities/decision-recomendacion.enum';
import { Estacion } from './entities/estacion.enum';
import { FaseAgronomica } from './entities/fase-agronomica.enum';
import { RecomendacionAplicada } from './entities/recomendacion-aplicada.entity';
import { Regla } from './entities/regla.entity';
import { RecomendacionesRepository } from './recomendaciones.repository';
import { ContextoClimaticoService } from './contexto-climatico.service';

/**
 * Service del Sistema Experto de Recomendaciones (Sprint 4).
 *
 * Responsabilidades:
 * 1. CRUD del catalogo de reglas (admin)
 * 2. Motor de evaluacion: matchea reglas contra el contexto del lote
 * 3. Audit log de recomendaciones aplicadas
 *
 * Marco etico:
 * - El motor SUGIERE, el productor DECIDE.
 * - Cada decision queda en recomendaciones_aplicadas.
 * - Reglas con fuente cientifica obligatoria (validado en DTO).
 */
@Injectable()
export class RecomendacionesService {
  private readonly logger = new Logger(RecomendacionesService.name);

  // Severidades ordenadas (para comparacion "minima")
  private readonly NIVEL_SEVERIDAD: Record<string, number> = {
    baja: 1,
    media: 2,
    alta: 3,
    critica: 4,
  };

  constructor(
    private readonly repo: RecomendacionesRepository,
    @InjectRepository(Lote)
    private readonly lotesRepo: Repository<Lote>,
    @InjectRepository(Siembra)
    private readonly siembrasRepo: Repository<Siembra>,
    @InjectRepository(Hallazgo)
    private readonly hallazgosRepo: Repository<Hallazgo>,
    @InjectRepository(Riego)
    private readonly riegosRepo: Repository<Riego>,
    private readonly contextoClimaticoService: ContextoClimaticoService,
  ) {}

  // ════════════════════════════════════════════════════════════
  // CRUD DE REGLAS (admin)
  // ════════════════════════════════════════════════════════════

  async createRegla(dto: CreateReglaDto): Promise<ReglaResponseDto> {
    // Verificar que el codigo no exista (entre reglas no eliminadas)
    const existente = await this.repo.reglas.findOne({
      where: { codigo: dto.codigo },
    });
    if (existente) {
      throw new ForbiddenException(`Ya existe una regla con codigo ${dto.codigo}`);
    }

    const entity = this.repo.reglas.create({
      codigo: dto.codigo,
      nombre: dto.nombre,
      descripcion: dto.descripcion ?? null,
      tipoRecomendacion: dto.tipoRecomendacion,
      cultivoId: dto.cultivoId ?? null,
      plagaId: dto.plagaId ?? null,
      tipoSueloId: dto.tipoSueloId ?? null,
      faseAgronomica: dto.faseAgronomica ?? null,
      severidadMinima: dto.severidadMinima ?? null,
      estacion: dto.estacion ?? null,
      diasSinRiegoMinimo: dto.diasSinRiegoMinimo ?? null,
      diasDesdeSiembraMinimo: dto.diasDesdeSiembraMinimo ?? null,
      diasDesdeSiembraMaximo: dto.diasDesdeSiembraMaximo ?? null,
      humedadMaxima: dto.humedadMaxima ?? null,
      humedadMinima: dto.humedadMinima ?? null,
      accionSugerida: dto.accionSugerida,
      productoSugerido: dto.productoSugerido ?? null,
      fertilizanteSugeridoId: dto.fertilizanteSugeridoId ?? null,
      dosisRecomendada: dto.dosisRecomendada ?? null,
      unidadRecomendada: dto.unidadRecomendada ?? null,
      metodoAplicacion: dto.metodoAplicacion ?? null,
      frecuenciaDias: dto.frecuenciaDias ?? null,
      prioridad: dto.prioridad ?? 3,
      fuenteCientifica: dto.fuenteCientifica,
      activa: dto.activa ?? true,
      notas: dto.notas ?? null,
    });

    const saved = await this.repo.reglas.save(entity);
    return this.findReglaById(saved.id);
  }

  async findAllReglas(query: ListReglasQueryDto): Promise<{
    data: ReglaResponseDto[];
    total: number;
    page: number;
    limit: number;
  }> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const qb = this.repo.reglas
      .createQueryBuilder('regla')
      .leftJoinAndSelect('regla.cultivo', 'cultivo')
      .leftJoinAndSelect('regla.plaga', 'plaga')
      .leftJoinAndSelect('regla.tipoSuelo', 'tipoSuelo')
      .leftJoinAndSelect('regla.fertilizanteSugerido', 'fertilizante')
      .orderBy('regla.prioridad', 'DESC')
      .addOrderBy('regla.codigo', 'ASC')
      .skip(skip)
      .take(limit);

    if (query.tipoRecomendacion) {
      qb.andWhere('regla.tipoRecomendacion = :tipo', { tipo: query.tipoRecomendacion });
    }
    if (query.cultivoId) {
      qb.andWhere('regla.cultivoId = :cultivoId', { cultivoId: query.cultivoId });
    }
    if (query.plagaId) {
      qb.andWhere('regla.plagaId = :plagaId', { plagaId: query.plagaId });
    }
    if (query.activa !== undefined) {
      qb.andWhere('regla.activa = :activa', { activa: query.activa });
    }
    if (query.search) {
      qb.andWhere('(regla.codigo ILIKE :search OR regla.nombre ILIKE :search)', {
        search: `%${query.search}%`,
      });
    }

    const [items, total] = await qb.getManyAndCount();
    return {
      data: items.map(ReglaResponseDto.fromEntity),
      total,
      page,
      limit,
    };
  }

  async findReglaById(id: string): Promise<ReglaResponseDto> {
    const regla = await this.repo.reglas.findOne({
      where: { id },
      relations: ['cultivo', 'plaga', 'tipoSuelo', 'fertilizanteSugerido'],
    });
    if (!regla) {
      throw new NotFoundException(`Regla ${id} no encontrada`);
    }
    return ReglaResponseDto.fromEntity(regla);
  }

  async updateRegla(id: string, dto: UpdateReglaDto): Promise<ReglaResponseDto> {
    const regla = await this.repo.reglas.findOne({ where: { id } });
    if (!regla) {
      throw new NotFoundException(`Regla ${id} no encontrada`);
    }
    Object.assign(regla, dto);
    await this.repo.reglas.save(regla);
    return this.findReglaById(id);
  }

  async removeRegla(id: string): Promise<void> {
    const regla = await this.repo.reglas.findOne({ where: { id } });
    if (!regla) {
      throw new NotFoundException(`Regla ${id} no encontrada`);
    }
    await this.repo.reglas.softDelete(id);
  }

  // ════════════════════════════════════════════════════════════
  // MOTOR DE EVALUACION DE RECOMENDACIONES
  // ════════════════════════════════════════════════════════════

  /**
   * Evalua todas las reglas activas contra el contexto de un lote
   * y devuelve las recomendaciones aplicables ordenadas por prioridad.
   *
   * Esta es la operacion mas importante del Sprint 4.
   */
  async evaluarRecomendacionesParaLote(
    loteId: string,
    userId: string,
    userRole: string,
  ): Promise<RecomendacionEvaluadaResponseDto[]> {
    // 1. Cargar contexto del lote
    const lote = await this.lotesRepo.findOne({
      where: { id: loteId },
      relations: ['cultivo'],
    });
    if (!lote) {
      throw new NotFoundException(`Lote ${loteId} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && lote.propietarioId !== userId) {
      throw new ForbiddenException('No tienes acceso a este lote');
    }

    // 2. Cargar contexto agronomico del lote
    const contexto = await this.cargarContextoDelLote(loteId, lote);
    this.logger.debug(`Contexto lote ${loteId}: ${JSON.stringify(contexto)}`);

    // 3. Cargar todas las reglas activas
    const reglasActivas = await this.repo.reglas.find({
      where: { activa: true, deletedAt: IsNull() },
      relations: ['cultivo', 'plaga', 'tipoSuelo', 'fertilizanteSugerido'],
    });

    // 4. Evaluar cada regla contra el contexto
    const recomendaciones: RecomendacionEvaluadaResponseDto[] = [];
    for (const regla of reglasActivas) {
      const match = this.evaluarRegla(regla, contexto);
      if (match.aplica) {
        recomendaciones.push({
          regla: ReglaResponseDto.fromEntity(regla),
          motivoMatch: match.motivo,
          etiquetaPrioridad: this.etiquetaPorPrioridad(regla.prioridad),
          colorPrioridad: this.colorPorPrioridad(regla.prioridad),
        });
      }
    }

    // 5. Ordenar por prioridad DESC
    recomendaciones.sort((a, b) => b.regla.prioridad - a.regla.prioridad);

    this.logger.log(
      `Lote ${loteId}: ${recomendaciones.length} de ${reglasActivas.length} reglas matchearon`,
    );

    return recomendaciones;
  }

  // ════════════════════════════════════════════════════════════
  // AUDIT LOG: aplicar/ignorar recomendacion
  // ════════════════════════════════════════════════════════════

  async aplicarRecomendacion(
    reglaId: string,
    dto: AplicarRecomendacionDto,
    userId: string,
    userRole: string,
  ): Promise<{ id: string; createdAt: Date }> {
    // Verificar regla
    const regla = await this.repo.reglas.findOne({ where: { id: reglaId } });
    if (!regla) {
      throw new NotFoundException(`Regla ${reglaId} no encontrada`);
    }

    // Verificar lote y propietario
    const lote = await this.lotesRepo.findOne({ where: { id: dto.loteId } });
    if (!lote) {
      throw new NotFoundException(`Lote ${dto.loteId} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && lote.propietarioId !== userId) {
      throw new ForbiddenException('El lote no te pertenece');
    }

    const entity = this.repo.aplicadas.create({
      reglaId,
      loteId: dto.loteId,
      userId,
      decision: dto.decision,
      notaProductor: dto.notaProductor ?? null,
      fechaSugerida: new Date(dto.fechaSugerida),
      fechaDecision: new Date(),
      resultadoObservado: dto.resultadoObservado ?? null,
    });
    const saved = await this.repo.aplicadas.save(entity);

    this.logger.log(
      `Recomendacion ${regla.codigo} -> decision=${dto.decision} por user=${userId} en lote=${dto.loteId}`,
    );

    return { id: saved.id, createdAt: saved.createdAt };
  }

  /**
   * Obtiene el historial de recomendaciones aplicadas para un lote.
   */
  async historialDelLote(
    loteId: string,
    userId: string,
    userRole: string,
  ): Promise<RecomendacionAplicada[]> {
    const lote = await this.lotesRepo.findOne({ where: { id: loteId } });
    if (!lote) {
      throw new NotFoundException(`Lote ${loteId} no encontrado`);
    }
    if (userRole !== UserRole.ADMINISTRADOR && lote.propietarioId !== userId) {
      throw new ForbiddenException('No tienes acceso a este lote');
    }

    return this.repo.aplicadas.find({
      where: { loteId },
      relations: ['regla'],
      order: { createdAt: 'DESC' },
    });
  }

  // ════════════════════════════════════════════════════════════
  // ─── Helpers privados ───────────────────────────────────────
  // ════════════════════════════════════════════════════════════

  /**
   * Construye el contexto agronomico de un lote para evaluar reglas.
   */
  private async cargarContextoDelLote(loteId: string, lote: Lote): Promise<ContextoLote> {
    // Ultima siembra del lote
    const ultimaSiembra = await this.siembrasRepo.findOne({
      where: { loteId },
      order: { fecha: 'DESC' },
    });

    // Hallazgos del lote (los abiertos = ultimos 30 dias, asumimos vigentes)
    const treintaDiasAtras = new Date();
    treintaDiasAtras.setDate(treintaDiasAtras.getDate() - 30);
    const hallazgos = await this.hallazgosRepo
      .createQueryBuilder('h')
      .leftJoinAndSelect('h.plaga', 'plaga')
      .where('h.loteId = :loteId', { loteId })
      .andWhere('h.fecha >= :fecha', { fecha: treintaDiasAtras })
      .orderBy('h.fecha', 'DESC')
      .getMany();

    // Ultimo riego
    const ultimoRiego = await this.riegosRepo.findOne({
      where: { loteId },
      order: { fecha: 'DESC' },
    });

    const ahora = new Date();
    const diasSinRiego = ultimoRiego
      ? Math.floor((ahora.getTime() - ultimoRiego.fecha.getTime()) / (1000 * 60 * 60 * 24))
      : null;

    const diasDesdeSiembra = ultimaSiembra
      ? Math.floor((ahora.getTime() - ultimaSiembra.fecha.getTime()) / (1000 * 60 * 60 * 24))
      : null;

    const fase = this.calcularFaseAgronomica(lote.cultivoActualId, diasDesdeSiembra);
    const contextoClimatico = await this.contextoClimaticoService.getContextoParaLote(loteId);
    const estacion = contextoClimatico.estacionInferida ?? this.calcularEstacionActual(ahora);

    return {
      cultivoId: lote.cultivoActualId,
      tipoSueloId: (lote as any).tipoSueloId ?? null,
      hallazgos,
      diasDesdeSiembra,
      diasSinRiego,
      faseAgronomica: fase,
      estacion,
      humedadActual: contextoClimatico.humedadSuelo ?? ultimoRiego?.humedad ?? null,
    };
  }

  /**
   * Evalua si una regla aplica al contexto del lote.
   * Devuelve si aplica y el motivo legible del match.
   */
  private evaluarRegla(regla: Regla, ctx: ContextoLote): { aplica: boolean; motivo: string } {
    const razones: string[] = [];

    // ── Cultivo ──
    if (regla.cultivoId) {
      if (!ctx.cultivoId || regla.cultivoId !== ctx.cultivoId) {
        return { aplica: false, motivo: '' };
      }
      if (regla.cultivo) razones.push(`cultivo ${regla.cultivo.nombre}`);
    }

    // ── Plaga ── (debe haber hallazgo con esa plaga)
    if (regla.plagaId) {
      const hallazgoConPlaga = ctx.hallazgos.find((h) => h.plagaId === regla.plagaId);
      if (!hallazgoConPlaga) {
        return { aplica: false, motivo: '' };
      }

      // Si la regla tiene severidad minima, validar
      if (regla.severidadMinima) {
        const nivelHallazgo = this.NIVEL_SEVERIDAD[hallazgoConPlaga.severidad] ?? 0;
        const nivelMinimo = this.NIVEL_SEVERIDAD[regla.severidadMinima] ?? 0;
        if (nivelHallazgo < nivelMinimo) {
          return { aplica: false, motivo: '' };
        }
      }

      const nombrePlaga = hallazgoConPlaga.plaga?.nombre ?? 'plaga registrada';
      razones.push(`Hallazgo de ${nombrePlaga} con severidad ${hallazgoConPlaga.severidad}`);
    }

    // ── Tipo Suelo ──
    if (regla.tipoSueloId) {
      if (!ctx.tipoSueloId || regla.tipoSueloId !== ctx.tipoSueloId) {
        return { aplica: false, motivo: '' };
      }
    }

    // ── Fase agronomica ──
    if (regla.faseAgronomica) {
      if (ctx.faseAgronomica !== regla.faseAgronomica) {
        return { aplica: false, motivo: '' };
      }
      razones.push(`fase ${regla.faseAgronomica}`);
    }

    // ── Estacion ──
    if (regla.estacion && regla.estacion !== ctx.estacion) {
      return { aplica: false, motivo: '' };
    }
    if (regla.estacion) razones.push(`estacion ${regla.estacion}`);

    // ── Dias sin riego ──
    if (regla.diasSinRiegoMinimo !== null && regla.diasSinRiegoMinimo !== undefined) {
      if (ctx.diasSinRiego === null || ctx.diasSinRiego < regla.diasSinRiegoMinimo) {
        return { aplica: false, motivo: '' };
      }
      razones.push(`${ctx.diasSinRiego} dias sin riego`);
    }

    // ── Dias desde siembra (rango) ──
    if (regla.diasDesdeSiembraMinimo !== null && regla.diasDesdeSiembraMinimo !== undefined) {
      if (ctx.diasDesdeSiembra === null || ctx.diasDesdeSiembra < regla.diasDesdeSiembraMinimo) {
        return { aplica: false, motivo: '' };
      }
    }
    if (regla.diasDesdeSiembraMaximo !== null && regla.diasDesdeSiembraMaximo !== undefined) {
      if (ctx.diasDesdeSiembra === null || ctx.diasDesdeSiembra > regla.diasDesdeSiembraMaximo) {
        return { aplica: false, motivo: '' };
      }
    }
    if (
      ctx.diasDesdeSiembra !== null &&
      (regla.diasDesdeSiembraMinimo || regla.diasDesdeSiembraMaximo)
    ) {
      razones.push(`siembra de hace ${ctx.diasDesdeSiembra} dias`);
    }

    // ── Humedad ──
    if (regla.humedadMaxima !== null && regla.humedadMaxima !== undefined) {
      if (ctx.humedadActual === null || ctx.humedadActual > regla.humedadMaxima) {
        return { aplica: false, motivo: '' };
      }
      razones.push(`humedad ${ctx.humedadActual}%`);
    }
    if (regla.humedadMinima !== null && regla.humedadMinima !== undefined) {
      if (ctx.humedadActual === null || ctx.humedadActual < regla.humedadMinima) {
        return { aplica: false, motivo: '' };
      }
    }

    // ✅ Todas las condiciones de la regla pasaron
    const motivo = razones.length > 0 ? razones.join(', ') : 'Regla general aplicable';
    return {
      aplica: true,
      motivo: motivo.charAt(0).toUpperCase() + motivo.slice(1),
    };
  }

  /**
   * Calcula la fase agronomica actual basada en dias desde siembra.
   *
   * Estos rangos son aproximados y genericos. Se pueden refinar por cultivo
   * en futuras iteraciones (cada cultivo tiene su propio cronograma).
   */
  private calcularFaseAgronomica(
    cultivoId: string | null,
    diasDesdeSiembra: number | null,
  ): FaseAgronomica | null {
    if (!cultivoId || diasDesdeSiembra === null) return null;

    // Aproximacion estandar (puede afinarse por cultivo en Sprint posterior)
    if (diasDesdeSiembra < 0) return FaseAgronomica.PREPARACION;
    if (diasDesdeSiembra <= 7) return FaseAgronomica.SIEMBRA;
    if (diasDesdeSiembra <= 21) return FaseAgronomica.GERMINACION;
    if (diasDesdeSiembra <= 60) return FaseAgronomica.CRECIMIENTO_VEGETATIVO;
    if (diasDesdeSiembra <= 75) return FaseAgronomica.PRE_FLORACION;
    if (diasDesdeSiembra <= 100) return FaseAgronomica.FLORACION;
    if (diasDesdeSiembra <= 130) return FaseAgronomica.FRUCTIFICACION;
    if (diasDesdeSiembra <= 160) return FaseAgronomica.MADURACION;
    if (diasDesdeSiembra <= 180) return FaseAgronomica.COSECHA;
    return FaseAgronomica.POST_COSECHA;
  }

  /**
   * Calcula la estacion climatica del Magdalena segun el mes.
   *
   * Patron climatico Caribe colombiano (aprox):
   * - Diciembre - Marzo: Seca
   * - Abril, Noviembre: Transicion
   * - Mayo - Octubre: Lluviosa
   */
  private calcularEstacionActual(fecha: Date): Estacion {
    const mes = fecha.getMonth() + 1; // 1-12
    if (mes >= 12 || mes <= 3) return Estacion.SECA;
    if (mes === 4 || mes === 11) return Estacion.TRANSICION;
    return Estacion.LLUVIOSA;
  }

  /**
   * Etiqueta de prioridad legible para la UI.
   * Coincide con los textos que ya usa active_alerts_screen.dart en el frontend.
   */
  private etiquetaPorPrioridad(prioridad: number): string {
    switch (prioridad) {
      case 5:
        return 'CRITICA';
      case 4:
        return 'ALTA PRIORIDAD';
      case 3:
        return 'NORMAL';
      case 2:
        return 'MONITOREAR';
      case 1:
      default:
        return 'INFORMATIVA';
    }
  }

  /**
   * Color sugerido para badges en el frontend.
   */
  private colorPorPrioridad(prioridad: number): string {
    switch (prioridad) {
      case 5:
        return '#7B1FA2'; // purpura
      case 4:
        return '#D32F2F'; // rojo
      case 3:
        return '#F57C00'; // naranja
      case 2:
        return '#FBC02D'; // amarillo
      case 1:
      default:
        return '#388E3C'; // verde
    }
  }
}

// ════════════════════════════════════════════════════════════
// Tipos internos
// ════════════════════════════════════════════════════════════

/**
 * Snapshot del estado agronomico de un lote en un momento dado.
 * Lo construye cargarContextoDelLote() y lo consume evaluarRegla().
 */
interface ContextoLote {
  cultivoId: string | null;
  tipoSueloId: string | null;
  hallazgos: Hallazgo[];
  diasDesdeSiembra: number | null;
  diasSinRiego: number | null;
  faseAgronomica: FaseAgronomica | null;
  estacion: Estacion;
  humedadActual: number | null;
}
