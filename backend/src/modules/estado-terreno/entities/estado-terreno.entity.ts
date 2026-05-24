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
import { Siembra } from '../../siembras/entities/siembra.entity';
import { TipoSuelo } from '../../catalogos/entities/tipo-suelo.entity';

/**
 * Entidad EstadoTerreno - registra la caracterización y condición física del suelo del lote.
 *
 * Mapea:
 * - loteId (CASCADE)
 * - siembraId (SET NULL) - opcional si el lote no tiene siembra
 * - estado (limpio, arado, maleza, estable, erosionado, etc.)
 * - tipoSueloId (SET NULL) - catalogo de suelos
 * - notas/observaciones adicionales
 * - userId
 */
@Entity('estado_terreno')
@Index(['loteId'])
@Index(['userId'])
@Index(['createdAt'])
export class EstadoTerreno {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  loteId!: string;

  @ManyToOne(() => Lote, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'loteId' })
  lote!: Lote;

  @Column({ type: 'uuid', nullable: true })
  siembraId!: string | null;

  @ManyToOne(() => Siembra, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'siembraId' })
  siembra!: Siembra | null;

  @Column({ type: 'varchar', length: 50 })
  estado!: string;

  @Column({ type: 'uuid', nullable: true })
  tipoSueloId!: string | null;

  @ManyToOne(() => TipoSuelo, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'tipoSueloId' })
  tipoSuelo!: TipoSuelo | null;

  @Column({ type: 'text', nullable: true })
  notas!: string | null;

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
