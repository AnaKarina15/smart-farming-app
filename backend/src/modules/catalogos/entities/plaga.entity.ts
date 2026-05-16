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
 * Plaga o enfermedad que afecta a los cultivos del Magdalena.
 *
 * Incluye insectos, hongos, bacterias, virus, malezas y nematodos.
 * El sistema experto usa este catalogo para emitir alertas
 * fitosanitarias contextualizadas al cultivo del productor.
 */
@Entity('plagas')
@Index(['nombreCientifico'], { unique: true, where: '"deletedAt" IS NULL' })
@Index(['nombre'], { unique: true, where: '"deletedAt" IS NULL' })
export class Plaga {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 100 })
  nombre!: string;

  @Column({ type: 'varchar', length: 150, nullable: true })
  nombreCientifico!: string | null;

  /**
   * Tipo de plaga.
   * Valores: insecto | hongo | bacteria | virus | maleza | nematodo | acaro
   */
  @Column({ type: 'varchar', length: 30 })
  tipo!: string;

  /**
   * Severidad tipica del dano que causa.
   * Valores: baja | media | alta | critica
   */
  @Column({ type: 'varchar', length: 20 })
  severidadTipica!: string;

  /**
   * Sintomas observables a campo, util para diagnostico.
   * Texto descriptivo que el productor puede leer y comparar.
   */
  @Column({ type: 'text', nullable: true })
  sintomas!: string | null;

  /**
   * Cultivos hospederos (nombres separados por coma).
   * Ej: 'maiz, sorgo, arroz'. Se usa para alertas cruzadas.
   */
  @Column({ type: 'text', nullable: true })
  cultivosAfectados!: string | null;

  @Column({ type: 'boolean', default: true })
  activo!: boolean;

  @DeleteDateColumn({ type: 'timestamp with time zone', nullable: true })
  deletedAt!: Date | null;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;
}
