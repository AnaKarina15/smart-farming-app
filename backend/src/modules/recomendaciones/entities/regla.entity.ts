import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

import { Cultivo } from '../../catalogos/entities/cultivo.entity';
import { Fertilizante } from '../../catalogos/entities/fertilizante.entity';
import { Plaga } from '../../catalogos/entities/plaga.entity';
import { TipoSuelo } from '../../catalogos/entities/tipo-suelo.entity';

import { Estacion } from './estacion.enum';
import { FaseAgronomica } from './fase-agronomica.enum';
import { TipoRecomendacion } from './tipo-recomendacion.enum';

/**
 * Entidad Regla - sistema experto agronomico AgroField (Sprint 4).
 *
 * Estructura IF-THEN:
 * - Condiciones IF: cultivoId, plagaId, faseAgronomica, severidad, etc.
 *   (TODAS opcionales; cuando son null, no filtran)
 * - Accion THEN: accionSugerida + producto + dosis + metodo + frecuencia
 *
 * Marco etico:
 * - fuenteCientifica es OBLIGATORIA (defendible academicamente)
 * - El admin puede activar/desactivar reglas sin redeploy
 * - Soft-delete preserva historial
 */
@Entity('reglas')
@Index(['tipoRecomendacion'])
@Index(['cultivoId'])
@Index(['plagaId'])
@Index(['activa'])
@Index(['prioridad'])
@Index(['codigo'], { unique: true, where: '"deletedAt" IS NULL' })
export class Regla {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  // ─── Identificacion ───────────────────────────────────────
  /**
   * Codigo unico legible. Formato: R-{CATEGORIA}-{NNN}.
   * Ej: R-RIEGO-001, R-FERT-005, R-PLAGA-012
   */
  @Column({ type: 'varchar', length: 50 })
  codigo!: string;

  @Column({ type: 'varchar', length: 200 })
  nombre!: string;

  @Column({ type: 'text', nullable: true })
  descripcion!: string | null;

  // ─── Categoria ────────────────────────────────────────────
  @Column({
    type: 'varchar',
    length: 40,
    enum: TipoRecomendacion,
  })
  tipoRecomendacion!: TipoRecomendacion;

  // ─── Condiciones IF (todas opcionales) ────────────────────
  @Column({ type: 'uuid', nullable: true })
  cultivoId!: string | null;

  @ManyToOne(() => Cultivo, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'cultivoId' })
  cultivo!: Cultivo | null;

  @Column({ type: 'uuid', nullable: true })
  plagaId!: string | null;

  @ManyToOne(() => Plaga, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'plagaId' })
  plaga!: Plaga | null;

  @Column({ type: 'uuid', nullable: true })
  tipoSueloId!: string | null;

  @ManyToOne(() => TipoSuelo, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'tipoSueloId' })
  tipoSuelo!: TipoSuelo | null;

  @Column({ type: 'varchar', length: 40, nullable: true })
  faseAgronomica!: FaseAgronomica | null;

  /**
   * Severidad MINIMA requerida del hallazgo para activar la regla.
   * Ej: 'media' -> activa para media, alta y critica.
   */
  @Column({ type: 'varchar', length: 20, nullable: true })
  severidadMinima!: string | null;

  @Column({ type: 'varchar', length: 20, nullable: true })
  estacion!: Estacion | null;

  @Column({ type: 'int', nullable: true })
  diasSinRiegoMinimo!: number | null;

  @Column({ type: 'int', nullable: true })
  diasDesdeSiembraMinimo!: number | null;

  @Column({ type: 'int', nullable: true })
  diasDesdeSiembraMaximo!: number | null;

  @Column({ type: 'numeric', precision: 5, scale: 2, nullable: true })
  humedadMaxima!: number | null;

  @Column({ type: 'numeric', precision: 5, scale: 2, nullable: true })
  humedadMinima!: number | null;

  // ─── Accion THEN ──────────────────────────────────────────
  @Column({ type: 'text' })
  accionSugerida!: string;

  @Column({ type: 'varchar', length: 200, nullable: true })
  productoSugerido!: string | null;

  @Column({ type: 'uuid', nullable: true })
  fertilizanteSugeridoId!: string | null;

  @ManyToOne(() => Fertilizante, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'fertilizanteSugeridoId' })
  fertilizanteSugerido!: Fertilizante | null;

  @Column({ type: 'numeric', precision: 12, scale: 2, nullable: true })
  dosisRecomendada!: number | null;

  @Column({ type: 'varchar', length: 30, nullable: true })
  unidadRecomendada!: string | null;

  @Column({ type: 'varchar', length: 40, nullable: true })
  metodoAplicacion!: string | null;

  @Column({ type: 'int', nullable: true })
  frecuenciaDias!: number | null;

  // ─── Metadatos ────────────────────────────────────────────
  /**
   * 1 = baja, 2 = monitorear, 3 = normal, 4 = importante, 5 = critica.
   * El motor ordena las recomendaciones devueltas por prioridad DESC.
   */
  @Column({ type: 'int', default: 3 })
  prioridad!: number;

  /**
   * OBLIGATORIA. Cita de la fuente cientifica/oficial de la regla.
   * Ej: "ICA Resolucion 092771/2021", "AGROSAVIA - Manual yuca Caribe 2018".
   */
  @Column({ type: 'text' })
  fuenteCientifica!: string;

  @Column({ type: 'boolean', default: true })
  activa!: boolean;

  @Column({ type: 'text', nullable: true })
  notas!: string | null;

  // ─── Timestamps ───────────────────────────────────────────
  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;

  @DeleteDateColumn({ type: 'timestamp with time zone', nullable: true })
  deletedAt!: Date | null;
}
