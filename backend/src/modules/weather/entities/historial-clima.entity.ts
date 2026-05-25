import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';

import { Lote } from '../../lotes/entities/lote.entity';

@Entity('historial_clima')
@Index(['loteId', 'fecha'], { unique: true })
@Index(['loteId'])
export class HistorialClima {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  loteId!: string;

  @ManyToOne(() => Lote, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'loteId' })
  lote!: Lote;

  @Column({ type: 'date' })
  fecha!: string;

  @Column({ type: 'numeric', precision: 6, scale: 2 })
  temperatura!: number;

  @Column({ type: 'numeric', precision: 5, scale: 2 })
  probabilidadLluvia!: number;

  @Column({ type: 'numeric', precision: 8, scale: 2 })
  precipitacionMm!: number;

  @Column({ type: 'numeric', precision: 6, scale: 3, nullable: true })
  humedadSuelo!: number | null;

  @Column({ type: 'numeric', precision: 6, scale: 2, nullable: true })
  humedadRelativa!: number | null;

  @Column({ type: 'numeric', precision: 6, scale: 2 })
  viento!: number;

  @Column({ type: 'varchar', length: 50, default: 'open-meteo' })
  fuente!: string;

  @Column({ type: 'timestamp with time zone' })
  registradoEn!: Date;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;
}
