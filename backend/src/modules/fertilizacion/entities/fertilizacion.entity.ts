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

import { Fertilizante } from '../../catalogos/entities/fertilizante.entity';
import { Lote } from '../../lotes/entities/lote.entity';
import { User } from '../../users/entities/user.entity';

/**
 * Entidad Fertilizacion - registra una aplicacion de fertilizante en un lote.
 *
 * Reglas:
 * - Debe especificar fertilizanteId O fertilizanteOtro.
 * - userId siempre del JWT.
 */
@Entity('fertilizacion')
@Index(['loteId'])
@Index(['userId'])
@Index(['fecha'])
export class Fertilizacion {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  loteId!: string;

  @ManyToOne(() => Lote, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'loteId' })
  lote!: Lote;

  @Column({ type: 'uuid', nullable: true })
  fertilizanteId!: string | null;

  @ManyToOne(() => Fertilizante, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'fertilizanteId' })
  fertilizante!: Fertilizante | null;

  /**
   * Escape valve: fertilizante no listado en el catalogo.
   */
  @Column({ type: 'varchar', length: 100, nullable: true })
  fertilizanteOtro!: string | null;

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
