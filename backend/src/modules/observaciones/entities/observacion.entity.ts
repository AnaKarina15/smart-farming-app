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
 * Entidad Observacion - notas libres del productor sobre el lote.
 *
 * A diferencia de Hallazgo (que es fitosanitario y tiene severidad/plaga),
 * Observacion es un cajon de notas generales: clima, comportamiento de
 * animales, visitas, eventos, recordatorios, etc.
 *
 * Reglas:
 * - descripcion es obligatoria.
 * - tipo es opcional (clima, fauna, evento, recordatorio, otro).
 * - userId siempre del JWT.
 */
@Entity('observaciones')
@Index(['loteId'])
@Index(['userId'])
@Index(['fecha'])
export class Observacion {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  loteId!: string;

  @ManyToOne(() => Lote, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'loteId' })
  lote!: Lote;

  @Column({ type: 'text' })
  descripcion!: string;

  /**
   * Categoria libre: clima | fauna | evento | recordatorio | otro
   */
  @Column({ type: 'varchar', length: 50, nullable: true })
  tipo!: string | null;

  @Column({ type: 'timestamp with time zone' })
  fecha!: Date;

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
