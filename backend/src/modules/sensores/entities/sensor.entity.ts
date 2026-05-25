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

export enum TipoSensor {
  HUMEDAD_SUELO = 'humedad_suelo',
  TEMPERATURA = 'temperatura',
  PH_SUELO = 'ph_suelo',
  LUZ = 'luz',
  OTRO = 'otro',
}

export enum EstadoSensor {
  ACTIVO = 'activo',
  INACTIVO = 'inactivo',
  SIN_EMPAREJAR = 'sin_emparejar',
}

@Entity('sensores')
@Index(['loteId'])
@Index(['userId'])
@Index(['tipo'])
@Index(['identificadorFisico'], {
  unique: true,
  where: '"identificadorFisico" IS NOT NULL',
})
export class Sensor {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 100 })
  nombre!: string;

  @Column({ type: 'enum', enum: TipoSensor })
  tipo!: TipoSensor;

  @Column({ type: 'varchar', length: 120, nullable: true })
  identificadorFisico!: string | null;

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

  @Column({ type: 'enum', enum: EstadoSensor, default: EstadoSensor.SIN_EMPAREJAR })
  estado!: EstadoSensor;

  @Column({ type: 'varchar', length: 30 })
  unidadMedida!: string;

  @Column({ type: 'timestamp with time zone', nullable: true })
  ultimaLecturaEn!: Date | null;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;

  @DeleteDateColumn({ type: 'timestamp with time zone', nullable: true })
  deletedAt!: Date | null;
}
