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

import { Plaga } from '../../catalogos/entities/plaga.entity';
import { Lote } from '../../lotes/entities/lote.entity';
import { User } from '../../users/entities/user.entity';

/**
 * Entidad Hallazgo - registra el descubrimiento de una plaga o problema
 * fitosanitario en un lote.
 *
 * Reglas:
 * - Debe especificar plagaId O plagaOtro.
 * - severidad es obligatoria (baja/media/alta/critica).
 * - userId siempre del JWT.
 */
@Entity('hallazgos')
@Index(['loteId'])
@Index(['userId'])
@Index(['fecha'])
@Index(['severidad'])
export class Hallazgo {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  loteId!: string;

  @ManyToOne(() => Lote, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'loteId' })
  lote!: Lote;

  @Column({ type: 'uuid', nullable: true })
  plagaId!: string | null;

  @ManyToOne(() => Plaga, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'plagaId' })
  plaga!: Plaga | null;

  /**
   * Escape valve: plaga o problema no listado en el catalogo.
   */
  @Column({ type: 'varchar', length: 100, nullable: true })
  plagaOtro!: string | null;

  /**
   * Severidad observada: baja | media | alta | critica.
   */
  @Column({ type: 'varchar', length: 20 })
  severidad!: string;

  @Column({ type: 'text', nullable: true })
  descripcion!: string | null;

  /**
   * Ruta de la foto del hallazgo. El upload de la imagen no se maneja aqui;
   * el frontend puede enviar la ruta de su almacenamiento local o un URL.
   */
  @Column({ type: 'varchar', length: 500, nullable: true })
  fotoPath!: string | null;

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
