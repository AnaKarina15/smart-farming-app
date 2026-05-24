import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

import { Lote } from '../../lotes/entities/lote.entity';
import { User } from '../../users/entities/user.entity';

import { DecisionRecomendacion } from './decision-recomendacion.enum';
import { Regla } from './regla.entity';

/**
 * Audit log: registra cuando una recomendacion fue mostrada al productor
 * y que decidio hacer con ella (aplicar, ignorar, aplicar diferente).
 *
 * Cumple el marco etico AgroField: cada sugerencia tiene trazabilidad
 * completa. Si el productor pierde un cultivo, podemos saber exactamente
 * que regla se aplico y de donde viene su fuente cientifica.
 *
 * NO tiene soft-delete: es un audit log, debe ser inmutable.
 */
@Entity('recomendaciones_aplicadas')
@Index(['reglaId'])
@Index(['loteId'])
@Index(['userId'])
@Index(['decision'])
export class RecomendacionAplicada {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  reglaId!: string;

  @ManyToOne(() => Regla, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'reglaId' })
  regla!: Regla;

  @Column({ type: 'uuid' })
  loteId!: string;

  @ManyToOne(() => Lote, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'loteId' })
  lote!: Lote;

  @Column({ type: 'uuid' })
  userId!: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user!: User;

  /**
   * Decision tomada por el productor.
   * - aplicada: aplico la recomendacion como se sugiere
   * - ignorada: decidio no aplicarla
   * - aplicada_diferente: aplico algo similar pero no exacto
   */
  @Column({ type: 'varchar', length: 30 })
  decision!: DecisionRecomendacion;

  @Column({ type: 'text', nullable: true })
  notaProductor!: string | null;

  /**
   * Cuando el motor sugirio la recomendacion.
   */
  @Column({ type: 'timestamp with time zone' })
  fechaSugerida!: Date;

  /**
   * Cuando el productor tomo la decision.
   */
  @Column({ type: 'timestamp with time zone' })
  fechaDecision!: Date;

  /**
   * Llenado posterior por el productor: "la plaga se controlo", etc.
   * Pantalla evaluation_screen.dart del frontend pasa este campo.
   */
  @Column({ type: 'text', nullable: true })
  resultadoObservado!: string | null;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;
}
