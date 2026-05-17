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
import { Lote } from '../../lotes/entities/lote.entity';
import { User } from '../../users/entities/user.entity';

/**
 * Entidad Siembra - registra cuando un productor siembra en un lote.
 *
 * Reglas de negocio:
 * - Debe asociarse a un Lote del propietario (validacion en service).
 * - Debe especificar cultivoId O cultivoOtro (uno de los dos obligatorio).
 * - userId siempre del JWT, nunca del body.
 */
@Entity('siembras')
@Index(['loteId'])
@Index(['userId'])
@Index(['fecha'])
export class Siembra {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  loteId!: string;

  @ManyToOne(() => Lote, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'loteId' })
  lote!: Lote;

  /**
   * FK al catalogo de cultivos. Opcional si el productor escribe "Otros".
   */
  @Column({ type: 'uuid', nullable: true })
  cultivoId!: string | null;

  @ManyToOne(() => Cultivo, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'cultivoId' })
  cultivo!: Cultivo | null;

  /**
   * Escape valve: cultivo no listado en el catalogo.
   * Se usa solo cuando cultivoId es null.
   */
  @Column({ type: 'varchar', length: 100, nullable: true })
  cultivoOtro!: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true })
  variedad!: string | null;

  @Column({ type: 'timestamp with time zone' })
  fecha!: Date;

  @Column({ type: 'numeric', precision: 12, scale: 2, nullable: true })
  cantidadSemillas!: number | null;

  @Column({ type: 'varchar', length: 30, nullable: true })
  unidad!: string | null;

  @Column({ type: 'numeric', precision: 6, scale: 2, nullable: true })
  distanciaEntreFilas!: number | null;

  @Column({ type: 'numeric', precision: 6, scale: 2, nullable: true })
  distanciaEntrePlantas!: number | null;

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
