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

import { Hallazgo } from '../../hallazgos/entities/hallazgo.entity';
import { Lote } from '../../lotes/entities/lote.entity';
import { User } from '../../users/entities/user.entity';

/**
 * Entidad Tratamiento - registra la aplicacion de un producto fitosanitario.
 *
 * Puede asociarse opcionalmente a un Hallazgo (cuando se trata una plaga
 * detectada) o ser independiente (mantenimiento preventivo).
 *
 * Reglas:
 * - producto es obligatorio (nombre comercial o generico del agroquimico).
 * - userId siempre del JWT.
 * - Si se asocia a un hallazgo, este debe pertenecer al mismo lote.
 */
@Entity('tratamientos')
@Index(['loteId'])
@Index(['userId'])
@Index(['fecha'])
export class Tratamiento {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  loteId!: string;

  @ManyToOne(() => Lote, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'loteId' })
  lote!: Lote;

  /**
   * FK opcional al Hallazgo que motiva el tratamiento.
   */
  @Column({ type: 'uuid', nullable: true })
  hallazgoId!: string | null;

  @ManyToOne(() => Hallazgo, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'hallazgoId' })
  hallazgo!: Hallazgo | null;

  /**
   * Nombre del producto aplicado (comercial o generico).
   * Se mantiene como texto libre porque no hay un catalogo formal
   * de agroquimicos en este Sprint.
   */
  @Column({ type: 'varchar', length: 150 })
  producto!: string;

  @Column({ type: 'numeric', precision: 12, scale: 2, nullable: true })
  dosis!: number | null;

  @Column({ type: 'varchar', length: 30, nullable: true })
  unidad!: string | null;

  @Column({ type: 'varchar', length: 50, nullable: true })
  metodoAplicacion!: string | null;

  @Column({ type: 'timestamp with time zone' })
  fecha!: Date;

  @Column({ type: 'text', nullable: true })
  observaciones!: string | null;

  @Column({ type: 'uuid' })
  userId!: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user!: User;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;

  @DeleteDateColumn({ type: 'timestamp with time zone', nullable: true })
  deletedAt!: Date | null;
}
