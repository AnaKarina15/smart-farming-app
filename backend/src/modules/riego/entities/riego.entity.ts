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

import { Lote } from '../../lotes/entities/lote.entity';
import { User } from '../../users/entities/user.entity';

/**
 * Entidad Riego - registra un evento de riego en un lote.
 *
 * Tipos comunes: goteo, aspersion, manual, gravedad, microaspersion.
 */
@Entity('riego')
@Index(['loteId'])
@Index(['userId'])
@Index(['fecha'])
export class Riego {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  loteId!: string;

  @ManyToOne(() => Lote, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'loteId' })
  lote!: Lote;

  @Column({ type: 'varchar', length: 50 })
  tipo!: string;

  @Column({ type: 'numeric', precision: 10, scale: 2, nullable: true })
  duracionMinutos!: number | null;

  @Column({ type: 'numeric', precision: 12, scale: 2, nullable: true })
  cantidadLitros!: number | null;

  @Column({ type: 'timestamp with time zone' })
  fecha!: Date;

  /**
   * Humedad porcentual medida en campo (0-100).
   */
  @Column({ type: 'numeric', precision: 5, scale: 2, nullable: true })
  humedad!: number | null;

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
