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

import { User } from '../../users/entities/user.entity';

/**
 * Registro tecnico de idempotencia para operaciones recibidas desde clientes offline.
 *
 * No representa una entidad de negocio del dominio agricola; mantiene la relacion
 * localId -> serverId para que un dispositivo pueda reintentar un batch sin crear
 * duplicados cuando hay cortes de conectividad rural.
 */
@Entity('sync_operations')
@Index(['userId'])
@Index(['resourceType'])
@Index(['serverId'])
@Index(['userId', 'idempotencyKey'], { unique: true })
export class SyncOperation {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  userId!: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user!: User;

  @Column({ type: 'varchar', length: 50 })
  resourceType!: string;

  @Column({ type: 'varchar', length: 120 })
  localId!: string;

  /**
   * Key normalizada: resourceType:localId. Evita colisiones cuando SQLite usa
   * IDs enteros independientes por tabla local.
   */
  @Column({ type: 'varchar', length: 180 })
  idempotencyKey!: string;

  @Column({ type: 'uuid', nullable: true })
  serverId!: string | null;

  @Column({ type: 'varchar', length: 20 })
  operation!: string;

  @Column({ type: 'varchar', length: 20 })
  status!: string;

  @Column({ type: 'text', nullable: true })
  error!: string | null;

  @Column({ type: 'timestamp with time zone', nullable: true })
  clientUpdatedAt!: Date | null;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;
}
