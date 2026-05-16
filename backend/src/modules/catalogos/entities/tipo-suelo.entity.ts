import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * Tipo de suelo segun clasificacion textural FAO/USDA.
 *
 * Determina drenaje, retencion de humedad y cultivos aptos.
 * El sistema experto usa el tipo de suelo para emitir
 * recomendaciones de riego y fertilizacion contextualizadas.
 */
@Entity('tipos_suelo')
@Index(['nombre'], { unique: true, where: '"deletedAt" IS NULL' })
export class TipoSuelo {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 50 })
  nombre!: string;

  /**
   * Clase textural simplificada.
   * Valores: arenoso | franco_arenoso | franco | franco_arcilloso | arcilloso | limoso
   */
  @Column({ type: 'varchar', length: 30 })
  clase!: string;

  /**
   * Capacidad de drenaje.
   * Valores: rapido | moderado | lento | nulo
   */
  @Column({ type: 'varchar', length: 20 })
  drenaje!: string;

  /**
   * Capacidad de retencion de humedad (%).
   * Influye en frecuencia de riego.
   */
  @Column({ type: 'numeric', precision: 4, scale: 1, nullable: true })
  retencionHumedadPct!: number | null;

  /**
   * pH tipico del suelo (escala 0-14).
   * Determina disponibilidad de nutrientes.
   */
  @Column({ type: 'numeric', precision: 3, scale: 1, nullable: true })
  phTipico!: number | null;

  /**
   * Cultivos recomendados (nombres separados por coma).
   * Util para que el productor sepa que sembrar segun su suelo.
   */
  @Column({ type: 'text', nullable: true })
  cultivosRecomendados!: string | null;

  @Column({ type: 'text', nullable: true })
  descripcion!: string | null;

  @Column({ type: 'boolean', default: true })
  activo!: boolean;

  @DeleteDateColumn({ type: 'timestamp with time zone', nullable: true })
  deletedAt!: Date | null;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;
}
